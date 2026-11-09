# -*- coding: utf-8 -*-
"""Shared resolution and SQL helpers for every v4 emitter.

Every emitter reads the FROZEN plan and this module; none of them re-decides a grouping, a join
path or a key slot. One place to change a rendering, one place to look for the rule a model
embodies.

WHAT THIS MODULE DECIDES, AND WHAT IT REFUSES TO DECIDE
-------------------------------------------------------
It decides RENDERING: model names, column names, the dedupe partition, the COALESCE order of a
sideways merge. It refuses to decide MEANING: which of several key slots is the real key, whether
two attributes with one name are one fact, what a satellite's grain is. Those go to refuse() and
appear in the register with whose call they are.
"""
import collections
import io
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import hcon_names as N                                             # noqa: E402
import hcon4_plan as P                                             # noqa: E402

PROJECT_ROOT = P.PROJECT_ROOT
MODELS = os.path.join(PROJECT_ROOT, "models")
REPORTS = P.REPORTS

# Run precedence for a sideways merge, carried from v3's BD6/R8 decision: the settled half wins.
# It is a VALUE choice and it fires -- the map has attributes supplied by more than one run -- so
# it is named here rather than left to whichever table the loop reached first.
RUN_RANK = {"opus_health_v2": 0, "opus_health_legacy_v4": 1, "opus_health_delta3": 2}
RUN_RANK_NOTE = ("R8 source precedence, carried from v3 (BD6 as corrected): v2 is the closed, "
                 "settled half, so v2 > legacy > delta3. Under the central-view rule this "
                 "precedence lives in the stitched view's COALESCE order, which is where a "
                 "sideways merge belongs, instead of in the satellite loader.")

# Models are generated. Anything in these trees is rewritten from empty on every run.
# The layers this build actually writes. reject_log/ and vault/refs/ are NOT here:
#   * reject_log -- v3 emitted rejections as SQL models. Under this architecture a rejection is a
#     REFUSAL, and refusals live in build_artifacts/reports/unresolved_register.json where they
#     can be counted and routed. An empty reject_log/ directory advertises a layer that does not
#     exist, which is a structure claiming more than it delivers.
#   * vault/refs -- data_7.js carries reference satellites, and this map's target track names NONE
#     of them. The number is in BUILD_STATUS.json under map_coverage; the gap is an item for the
#     modeller, not an empty directory.
LAYERS = ("staging", "stitched", "stage", "hub_feeds", "vault/hubs", "vault/links",
          "vault/satellites", "augmented", "assertions")

RX_SAFE = re.compile(r"^[a-z_][a-z0-9_]*$")

UNRESOLVED = []


def refuse(kind, obj, detail, whose_call, **extra):
    """One register, counted and written. Never a silent skip and never a fallback value.

    A fallback always produces a row, so it never produces an error -- which is why every
    unresolvable thing in this build becomes an entry here instead of a default.
    """
    rec = {"kind": kind, "object": obj, "detail": detail, "whose_call": whose_call}
    rec.update(extra)
    UNRESOLVED.append(rec)
    return rec


# ============================================================================ the frozen plan
def load_plan():
    with io.open(P.PLAN_PATH, encoding="utf-8") as fh:
        plan = json.load(fh)
    if plan.get("rule_token") != "CENTRAL_VIEW_RULE_GOVERNS":
        raise AssertionError("the plan on disk was not written by hcon4_plan.py")
    return plan


def slots_of(plan):
    """(table, hub) -> slot record, rebuilt from the plan's own serialised form."""
    out = {}
    for k, v in plan["key_slots"].items():
        t, h = k.split("|", 1)
        out[(t, h)] = v
    return out


# ============================================================================ names
def view_label(v):
    """A stitched view's model name. The ORDINAL carries injectivity; the rest is for a reader.

    Injectivity is not left to the label: two views can legitimately serve satellites whose names
    render the same stem, and a collision there would silently merge two views. The ordinal is
    assigned once in the plan and is unique by construction, so the name cannot collide even if
    the descriptive part does.
    """
    spine = (v["join_plan"]["spine_hub"] or "NOSPINE").replace("HUB_", "").lower()
    lead = (sorted(v["satellites"]) or sorted(v["links"]) or ["empty"])[0]
    lead = re.sub(r"^(SAT|REF|LNK)_", "", lead).lower()
    name = N.budget("stitch_%02d_%s__%s" % (v["ordinal"], spine, lead))
    if not RX_SAFE.match(name):
        raise AssertionError("stitched view name is not a safe model name: %r" % name)
    return name


def stage_label(v):
    return N.budget("stage_%02d_%s" % (v["ordinal"],
                                       (v["join_plan"]["spine_hub"] or "NOSPINE")
                                       .replace("HUB_", "").lower()))


def staging_label(table):
    return N.staging_model(table)


def hub_model(hub):
    return N.budget(hub.lower())


def hub_feed_model(hub, v):
    return N.budget("hf_%s__%02d" % (hub.lower(), v["ordinal"]))


def link_model(link):
    return N.budget(link.lower())


def sat_model(sat):
    return N.budget(sat.lower())


def bk_col(hub, exprs_index, operand_hint):
    """The staged business-key column for ONE key slot.

    The operand hint is in the name because a hub can carry several registries on one table and
    the hub namespace separates HUBS, not registries within a hub -- so the slot name is the only
    place the registry is visible. Where the hint cannot be rendered the slot INDEX is used, which
    is ugly but honest: it says "slot 2 of this hub on this table" and nothing more.
    """
    if operand_hint:
        return N.budget("%s_BK__%s" % (hub, operand_hint))
    return N.budget("%s_BK__SLOT%d" % (hub, exprs_index))


RX_IDENT_IN_EXPR = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\b")
SQL_WORDS = {"md5", "normalise", "upper", "lower", "nullif", "trim", "coalesce", "cast", "as",
             "varchar", "to_char", "concat", "case", "when", "then", "else", "end", "null",
             "select", "from", "where", "and", "or", "not", "is", "distinct", "lnk"}


def operand_hint(expr, hub):
    """Name the slot after the identifiers its expression actually uses.

    Read off the EXPRESSION, not off a label, because the label is what differs between the two
    provenances while the operands are what distinguish one registry from another. A literal
    prefix such as 'EMP:' is NOT an identifier and so does not reach the name; the columns do.
    """
    ids = [m.group(1) for m in RX_IDENT_IN_EXPR.finditer(expr or "")]
    ids = [i for i in ids if i.lower() not in SQL_WORDS and not i.upper().startswith("HUB_")
           and not i.upper().startswith("LNK_")]
    seen, keep = set(), []
    for i in ids:
        u = i.upper()
        if u not in seen:
            seen.add(u)
            keep.append(u)
    if not keep:
        return None
    hint = "_".join(keep[:4])
    return hint if N.RX_BARE_IDENT.match(hint) else None


# ============================================================================ map resolution
_CACHE = {}


def map_blocks():
    if "blocks" not in _CACHE:
        rows = P.load_map()
        _CACHE["rows"] = rows
        _CACHE["blocks"] = P.read_blocks(rows)
        runs = {}
        for r in rows:
            t = P.n(r.get("table_name"))
            if t:
                runs.setdefault(t, P.n(r.get("source_run")) or "opus_health_delta3")
        _CACHE["run_of"] = runs
        cols = collections.defaultdict(set)
        for r in rows:
            t, c = P.n(r.get("table_name")), P.n(r.get("column_name"))
            if t and c:
                cols[t].add(c)
        _CACHE["cols_of"] = cols
    return _CACHE["blocks"]


def run_of(table):
    map_blocks()
    return _CACHE["run_of"].get(table, "opus_health_delta3")


def cols_of(table):
    map_blocks()
    return sorted(_CACHE["cols_of"].get(table, ()))


def payload_index():
    """satellite -> [{table, column, attr, track, ...}], the attributes each satellite wants.

    BOTH satellite spellings are read on BOTH tracks, for the reason recorded in hcon4_plan: the
    augmentation track names its satellite in new_satellite or best_home_satellite and carries
    `satellite` on almost nothing. The track is kept on every entry so the ratified and proposed
    payloads never merge by accident.
    """
    if "payload" in _CACHE:
        return _CACHE["payload"]
    rows = P.load_map()
    map_blocks()
    pay = collections.defaultdict(list)
    for r in rows:
        t = P.n(r.get("table_name"))
        col = P.n(r.get("column_name"))
        for track in ("target", "augmentation"):
            o = r.get(track)
            if not isinstance(o, dict):
                continue
            sat = (P.n(o.get("satellite")) or P.n(o.get("new_satellite"))
                   or P.n(o.get("best_home_satellite")))
            attr = P.n(o.get("attribute")) or P.n(o.get("proposed_attribute"))
            if not (sat and attr and t and col):
                continue
            pay[sat].append({"table": t, "column": col, "attr": attr, "track": track,
                             "multi_active": P.n(o.get("multi_active")),
                             "child_key": P.n(o.get("child_key")),
                             "run": run_of(t)})
    _CACHE["payload"] = pay
    return pay


def model_grain(sat):
    """Grain comes from data_7.js, never from the map.

    The map carries multi_active on 690 blocks and delta 3 states grain of its own, but grain is a
    modeller's fact: a satellite made multi-active by a builder has had its primary key changed by
    a builder. Returns (hist, is_multi_active, childkey_declaration).
    """
    s = P.MODEL and next((x for x in P.MODEL["sats"] if x["code"] == sat.upper()), None)
    if s is None:
        s = next((x for x in P.MODEL.get("refs", []) if x["code"] == sat.upper()), None)
    if s is None:
        return None, False, None
    hist = P.n(s.get("hist"))
    return hist, "multi-active" in hist.lower(), P.n(s.get("childkey")) or None


def resolve_childkey_columns(sat, tables):
    """The child-key legs of a multi-active satellite, resolved to REAL columns of REAL tables.

    A leg that cannot be resolved to a column is REFUSED, never rendered: a wrong child key is
    unrecoverable after load, and rendering a leg name into SQL produces a column that cannot
    exist -- or worse, one that can. Returns (resolved, unresolved_legs).
    """
    hist, is_ma, decl = model_grain(sat)
    if not is_ma or not decl:
        return [], []
    legs = N.split_legs(decl)
    pay = payload_index().get(sat, [])
    resolved, missing = [], []
    for leg in legs:
        hit = [e for e in pay if e["attr"].strip().lower() == leg.strip().lower()
               and e["table"] in tables]
        if hit:
            resolved.append({"leg": leg, "table": hit[0]["table"], "column": hit[0]["column"]})
        else:
            missing.append(leg)
    return resolved, missing


# ============================================================================ SQL rendering
def q(col):
    """A column reference in emitted SQL. Lower-case, because staging lower-cases every name."""
    return N.assert_identifier(col.lower(), "column ref")


def render_slot(table, hub, slot, idx):
    """One key slot, as (column_name, sql_expression).

    A map expression is emitted VERBATIM -- separators and the inner coalesce of a content hash
    are not tidied, because a tidied key is a different key. A legacy-recovered slot is a bare
    column name and is rendered as a bare reference; it is NOT wrapped in the map's nullif/trim
    shape, because that would invent a normalisation legacy never applied and so a hash legacy
    never produced.
    """
    expr = slot["exprs"][idx]
    if slot["render"] == "verbatim":
        sql = expr
    elif slot["render"] == "bare_column":
        sql = q(expr)
    else:
        raise AssertionError("unknown slot render %r for %s/%s" % (slot["render"], table, hub))
    name = bk_col(hub, idx, operand_hint(expr, hub))
    return name, sql


def header(generator, lines):
    """A generated-file header. Apostrophes are stripped from the comment body centrally.

    An apostrophe inside a header comment ended 235 models in a sibling build with an unbalanced
    string literal, because the comment sits in the same file as SQL string literals and nothing
    downstream re-reads it. Stripping here is a rendering rule, which is why it lives in the
    renderer and not in each caller.
    """
    body = "\n".join("   " + l for l in lines)
    body = body.replace("'", "")
    return ("/* GENERATED by %s -- models are generated, never hand-edited.\n%s\n*/\n"
            % (generator, body))


def write(rel_path, sql):
    """Write one model, with the balance check that makes an unbalanced literal impossible."""
    if sql.count("'") % 2 != 0:
        raise AssertionError("UNBALANCED STRING LITERAL in %s" % rel_path)
    full = os.path.join(MODELS, rel_path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with io.open(full, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(sql)
    return rel_path


def wipe_models():
    """Rewrite from empty. Reproducibility is proved by DELETION, so the build must be able to
    reconstruct every model without reading one.

    Every .sql file is deleted rather than the directories being removed and recreated: this tree
    lives under OneDrive, which holds a handle on the directory and denies rmdir. Deleting the
    files gives the same guarantee -- nothing is read from a previous run -- and the count of what
    was removed is returned so the deletion is a measured fact, not an assumption.
    """
    removed = 0
    for layer in LAYERS:
        d = os.path.join(MODELS, *layer.split("/"))
        os.makedirs(d, exist_ok=True)
        for root, _dirs, files in os.walk(d):
            for f in files:
                if f.endswith(".sql"):
                    os.remove(os.path.join(root, f))
                    removed += 1
    left = sum(1 for layer in LAYERS
               for root, _d, files in os.walk(os.path.join(MODELS, *layer.split("/")))
               for f in files if f.endswith(".sql"))
    if left:
        raise AssertionError("wipe_models left %d .sql file(s) behind; the build would be "
                             "incremental, not reproducible" % left)
    return removed


# ====================================================== the contract between layers
# Downstream layers used to look for a column by GREPPING the upstream model text for
# "as <COL>". That is a proxy for "does this column exist", and it silently reported NO for
# every payload column, because the stage layer passes payload through as `src.*` and never
# aliases it. The result was a build that emitted 0 satellites and registered 133 of them as
# "payload entirely withheld" -- a false zero that looked exactly like a finding about the map.
#
# So each layer now DECLARES what it emits, and the next layer reads that declaration. A column
# is present because the layer that made it says so, not because a regex found a string.
def write_manifest(name, data):
    os.makedirs(REPORTS, exist_ok=True)
    with io.open(os.path.join(REPORTS, name), "w", encoding="utf-8") as fh:
        fh.write(json.dumps(data, indent=1, ensure_ascii=False, sort_keys=True) + "\n")


def read_manifest(name):
    path = os.path.join(REPORTS, name)
    if not os.path.exists(path):
        raise AssertionError(
            "manifest %s is missing. A downstream layer is running before the layer that declares "
            "what it emits, and guessing would reintroduce the grep-for-a-string defect." % name)
    with io.open(path, encoding="utf-8") as fh:
        return json.load(fh)


def write_register():
    os.makedirs(REPORTS, exist_ok=True)
    by_kind = collections.Counter(r["kind"] for r in UNRESOLVED)
    by_call = collections.Counter(r["whose_call"] for r in UNRESOLVED)
    out = {"count": len(UNRESOLVED), "by_kind": dict(sorted(by_kind.items())),
           "by_whose_call": dict(sorted(by_call.items())),
           "register_note": "Every entry is something this build REFUSED to resolve rather than "
                            "defaulting. A fallback always produces a row, so it never produces "
                            "an error; an entry here is the error a fallback would have hidden.",
           "entries": UNRESOLVED}
    with io.open(os.path.join(REPORTS, "unresolved_register.json"), "w", encoding="utf-8") as fh:
        fh.write(json.dumps(out, indent=1, ensure_ascii=False) + "\n")
    return out
