# -*- coding: utf-8 -*-
"""build_mtv2_spec.py -- the map becomes ONE spec artifact. Everything downstream reads the
spec; nothing downstream reads the map.

Written to build_artifacts/mtv2_spec.json (never into the mapper's bundle -- BUILD_RULES 9.1).

What it decides, and prints (BUILD_RULES 9.5 -- a generator prints what it DECIDED, not only what
it built; a decision visible only as a missing model is indistinguishable from a source gap):

  * which views get a cast, by whether they are on a walk -- never by whether they are in the map
  * every key slot per (view, hub, instance, expression), rendered through ONE render_key()
  * every satellite's ONE child-key leg set, and which rows do not supply it
  * which (view, satellite) feeders fan out per INSTANCE and therefore belong to the unpivot layer
  * which satellites are NOT built, and why, one reason and one count each
"""
import collections
import hashlib
import json
import os
import re
import sys

import mtv2_names as N
import mtv2_keyrules as K

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

PROFILE = N.PROFILE
MF = PROFILE["map_fields"]

SPEC_PATH = os.path.join(N.ARTIFACTS, "mtv2_spec.json")

# ---- the unbuilt ledger. Every skip prints a reason AND a count (BUILD_RULES 10 clause 2).
UNBUILT = []


def unbuilt(what, reason, routing, **extra):
    rec = {"what": what, "reason": reason, "routing": routing}
    rec.update(extra)
    UNBUILT.append(rec)
    return rec


NOTES = collections.Counter()


# --------------------------------------------------------------------------- inputs
# ============================================================ contracts asserted, not consumed
def assert_degenerate_contract(rows):
    """The map states, per key, which degeneration branch it falls into. This build does not
    BRANCH on that -- rejection is by SHAPE, which is what survives a map that keeps moving --
    but it does REFUSE a branch the bundle cannot exercise.

    rev 4: degenerate_value is JSON null on all 2344 blocks and degenerate_verdict is
    'null_on_blank_row' on all 2344. 'empty_on_blank_row' and 'constant_on_blank_row' have ZERO
    rows. Shipping a code path for either would be shipping an untested branch; encountering one
    means the map now contains a key this build's guard was never exercised against, so it stops.
    """
    verdicts = collections.Counter()
    value_types = collections.Counter()
    for r in rows:
        for blk in ("target", "augmentation"):
            rk = ((r.get(blk) or {}).get("resolved_key") or {})
            if "degenerate_verdict" not in rk:
                continue
            verdicts[rk["degenerate_verdict"]] += 1
            v = rk.get("degenerate_value", "<absent>")
            value_types["JSON_null" if v is None else
                        ("empty_string" if v == "" else
                         ("<absent>" if v == "<absent>" else "non_empty_string"))] += 1
    unexercised = {k: n for k, n in verdicts.items() if k != "null_on_blank_row"}
    if unexercised:
        raise SystemExit(
            "REFUSING TO BUILD: degenerate_verdict carries %s. Only 'null_on_blank_row' has rows "
            "in the bundle this build was written against, so any other branch is one this build "
            "has never been exercised on. Rejection stays by SHAPE; the map now says something "
            "the shape guard was not tested for, and guessing is not an option (BUILD_RULES 1.1)."
            % unexercised)
    non_null = {k: n for k, n in value_types.items() if k not in ("JSON_null", "<absent>")}
    return {"degenerate_verdict": dict(verdicts), "degenerate_value_types": dict(value_types),
            "branches_with_zero_rows": ["empty_on_blank_row", "constant_on_blank_row"],
            "degenerate_value_read_as_a_value": False,
            "non_null_degenerate_values": non_null,
            "note": "degenerate_value is NEVER read as a value or as a guard operand. It is "
                    "type-checked here and nothing else. degenerate_verdict is read ONCE, to "
                    "refuse an unexercised branch."}


def assert_keynorm_shapes(rows):
    """keynorm is HISTORY and no value in it is ever read. Its SHAPE is asserted because rev 4
    grew a third field-set and a reader that iterated by `stage` would silently skip 20 blocks
    (BUILD_RULES 1.5 -- sweep the set, never a named member)."""
    known = {frozenset(("stage", "class", "previous_expression")),
             frozenset(("stage", "class", "previous_expression", "reason")),
             frozenset(("previous_expression", "reason"))}
    shapes = collections.Counter()
    for r in rows:
        for blk in ("target", "augmentation"):
            kn = ((r.get(blk) or {}).get("resolved_key") or {}).get("keynorm")
            if not kn:
                continue
            shapes[frozenset(kn)] += 1
    unknown = {tuple(sorted(k)): n for k, n in shapes.items() if k not in known}
    if unknown:
        raise SystemExit(
            "REFUSING TO BUILD: keynorm carries %d field-set shape(s) this build does not "
            "recognise: %s. Nothing reads a keynorm value, but an unrecognised shape means the "
            "map grew a field nobody looked at -- the defect stage 1 exists to prevent "
            "(BUILD_RULES 2.2)." % (len(unknown), unknown))
    return {" + ".join(sorted(k)): n for k, n in shapes.items()}


def load_map():
    raw = json.loads(N.read_input(N.MAP_PATH))
    if N.MAP_ROW_CONTAINER not in raw:
        raise SystemExit("map has no %r container" % N.MAP_ROW_CONTAINER)
    # The map's own 'summary' block carried three mutually inconsistent censuses in this bundle.
    # columns[] is the source; summary is never read.
    return raw[N.MAP_ROW_CONTAINER]


def load_model():
    txt = N.read_input(N.CANON_JS)
    mdl = json.loads(txt[txt.index("{"):].rstrip().rstrip(";"))
    sats, links, hubs = {}, {}, {}
    for s in mdl["sats"]:
        sats[s["code"]] = {
            "parent": s["parent"],
            "childkey": (s.get("childkey") or "").strip(),
            "attrs": [a["n"] for a in s["attrs"]],
            "hist": s.get("hist"),
        }
    for l in mdl["links"]:
        links[l["code"]] = {"hubs": list(l.get("hubs") or [])}
    for h in mdl["hubs"]:
        hubs[h["code"]] = {"key": h.get("key")}
    return {"sats": sats, "links": links, "hubs": hubs}


def declared_legs(childkey):
    if not childkey:
        return []
    return [p.strip() for p in childkey.split("+") if p.strip()]



# ============================================================ BD13 negative control
PREFIX_LITERAL = re.compile(r"\A'([A-Z_]+:)'")


def prefix_split_probe(map_path):
    """(hub, source column) pairs keyed BOTH under a namespace prefix and bare, in one map.

    Derived from resolved_key.expression and resolved_key.source_columns only, so it runs
    against any map snapshot without the rest of the pipeline. This is the same rule the spec
    builder applies to rendered slots; running it on a second snapshot is what makes the live
    map's zero a JUDGED zero rather than an untested one.
    """
    with open(map_path, encoding="utf-8") as fh:
        rows = json.load(fh)[N.MAP_ROW_CONTAINER]
    seen = collections.defaultdict(lambda: collections.defaultdict(set))
    for r in rows:
        for blk in ("target", "augmentation"):
            rk = ((r.get(blk) or {}).get("resolved_key") or {})
            expr, hub = rk.get("expression"), rk.get("hub")
            if not expr or not hub:
                continue
            m = PREFIX_LITERAL.match(str(expr).strip())
            ns = m.group(1) if m else "(NO PREFIX)"
            for col in (rk.get("source_columns") or []):
                seen[hub][col].add(ns)
    # The hazard is ONE identifier in a namespaced space AND in the UNNAMESPACED one -- two hub
    # rows for one thing. Several DIFFERENT prefixes on one column is the opposite: it is
    # deliberate separation, and flagging it reported HUB_FINANCIAL_TRANSACTION's PARENT_KEY_HASH
    # under PAY:/POLPREM:/QUOTEPREM:, which is three transaction types correctly held apart.
    return sorted((hub, col, sorted(nss))
                  for hub, cols in seen.items()
                  for col, nss in cols.items()
                  if len(nss) > 1 and "(NO PREFIX)" in nss)


# ============================================ target.transformation: NEVER SILENTLY IGNORED
# The field carries FIVE contracts on this LOB and the map declares which. Only one is
# executable. This build reads the DECLARATION, never the value's shape.
#
# Testing the value refuses four real attributes: 7 rows begin 'derived:' and only 3 are
# executable. Test the SPECIFIC before the GENERAL -- the mapper's own classifier tripped on
# `code->decode (repository code ...)`, which contains `decode (`, so a general
# executable-pattern test run first classified prose as executable.
# BUILD_RULES 2.4: the map's field SPELLINGS come from the profile, never from this file's
# memory. Stage 0 recorded (stage1_field_knowledge_note) that this generator knew these three
# spellings before any profile declared them; rev 5 declares them, so they are read.
_TC = PROFILE["transformation_contract"]


def _leaf(path):
    """'columns[].target.transformation_kind' -> 'transformation_kind'."""
    return str(path).split(".")[-1]


TRANSFORMATION_FIELD = N.assert_field_not_read(_leaf(_TC["field"]), "transformation_contract")
TRANSFORMATION_KIND_FIELD = N.assert_field_not_read(_leaf(_TC["kind_field"]),
                                                    "transformation_contract")
BUILD_DIRECTIVE_FIELD = N.assert_field_not_read(_leaf(_TC["directive_field"]),
                                                "transformation_contract")

TRANSFORMATION_KINDS = {
    "executable_expression": "refuse",      # carries build_directive: true
    "derivation_note": "prose",
    "provenance_note": "prose",
    "reference_decode": "prose",
    "synonym_note": "prose",
}


def classify_transformation(body, where):
    """'refuse' | 'prose' | None, from the DECLARED kind and flag -- never from the value.

    A field that carries instructions and is read by nobody is the same defect class as a
    guard that cannot fire: both look exactly like the healthy case. An unrecognised kind
    STOPS the build rather than defaulting to prose.
    """
    kind = body.get(TRANSFORMATION_KIND_FIELD)
    directive = body.get(BUILD_DIRECTIVE_FIELD)
    if kind is None:
        if body.get(TRANSFORMATION_FIELD) in (None, ""):
            return None
        raise SystemExit(
            "REFUSING TO BUILD (%s): target.transformation is populated (%r) but carries no "
            "transformation_kind. This field is executable on this LOB; an unclassified "
            "value is not assumed to be prose (BUILD_RULES 2.2)."
            % (where, str(body.get(TRANSFORMATION_FIELD))[:140]))
    if kind not in TRANSFORMATION_KINDS:
        raise SystemExit(
            "REFUSING TO BUILD (%s): transformation_kind %r is not one this build "
            "recognises. Known: %s. Sweep the set, never a named member, and raise on a "
            "member you do not know (BUILD_RULES 1.5, 2.2)."
            % (where, kind, sorted(TRANSFORMATION_KINDS)))
    verdict = TRANSFORMATION_KINDS[kind]
    if bool(directive) != (verdict == "refuse"):
        raise SystemExit(
            "REFUSING TO BUILD (%s): transformation_kind=%r and build_directive=%r "
            "disagree. The map's own rule is 'executable_expression => "
            "build_directive=true'; two fields stating one fact must not diverge."
            % (where, kind, directive))
    return verdict


def ordinal_child_key_summary(ordinal_legs_seen):
    """DISTINCT ordinal-backed child keys, and the map rows behind them.

    Two true numbers have been quoted for one finding: the map carries 11 leg ROWS and the build
    emits ONE child-key column in ONE stage. Both are reported here, named, so neither can be
    read as the other (BUILD_RULES 11.8).
    """
    by = {}
    for o in ordinal_legs_seen:
        key = (o["satellite"], o["leg"], o["view"], tuple(o["columns"]))
        rec = by.setdefault(key, {"satellite": o["satellite"], "leg": o["leg"],
                                  "column": N.cdk_column(o["leg"]), "view": o["view"],
                                  "columns": list(o["columns"]), "map_rows": 0,
                                  "built": "as mapped (BUILD_RULES 5.7)",
                                  "routing": "modeller",
                                  "severity": "blocker"})
        rec["map_rows"] += 1
    return {
        "distinct": [by[k] for k in sorted(by)],
        "map_row_occurrences": len(ordinal_legs_seen),
        "rule": "BUILD_RULES 5.2 -- an ordinal is never a discriminator and a child-key leg "
                "needs hub-grade stability. A row inserted or removed renumbers the rest and "
                "re-attaches their history.",
        "detected_by": "SHAPE over the rendered source columns of every emitted child-key leg, "
                       "never by a name shape this build happens to use.",
    }


def measure_coverage(rows, row_field, tgt_field, model, satellites, unbuilt_records,
                     derived_refused):
    """Every MAPPED target (satellite, attribute) pair, and where it landed.

    The same population the shared gate's check 6 measures -- target rows with outcome=mapped
    whose satellite and attribute are canonical -- so the two cannot drift apart. What the gate
    cannot do is say WHY a pair did not land, and that is the whole difference between a refusal
    and novel silence (BUILD_RULES 8.1, 8.2).
    """
    # TARGET-track records only: the mapped population is the target track, and the augmented
    # SAT_AUG_* models are a different table with a different name.
    #
    # EMITTED, not merely recorded: gen_mtv2_vault.py declines a satellite whose payload is
    # empty, so a spec record with no payload is not a model and its child key reaches nothing.
    built = {s["satellite"]: s for s in satellites.values()
             if s["track"] == "target" and s["payload"]}
    refused = {(d["satellite"], d["attribute"]): d for d in derived_refused}

    covered, uncovered, pairs = 0, [], set()
    for row in rows:
        if row[row_field["outcome"]] != "mapped":
            continue
        body = row.get("target")
        if not body:
            continue
        sat = body.get(tgt_field["satellite"])
        attr = body.get(N.assert_field_not_read(tgt_field["attribute"], "measure_coverage"))
        if not sat or not attr:
            continue
        canon = model["sats"].get(sat)
        if not canon or attr not in canon["attrs"]:
            continue                      # check 3's population, not check 6's
        col = N.payload_column(attr)
        if (sat, col) in pairs:
            continue
        pairs.add((sat, col))
        rec = built.get(sat)
        if rec and col in rec["payload"]:
            covered += 1
            continue
        if rec and col in rec["cdk"]:
            reason = ("reaches the satellite as the CHILD KEY (src_cdk), not as a payload "
                      "column: a payload attribute may not share a name with a child-key leg "
                      "(BUILD_RULES 5.4). The value is in the vault; the gate counts only "
                      "src_payload")
            if (sat, attr) in refused:
                reason += ("; AND the map declares an executable derivation for it that this "
                           "build refuses rather than guesses -- the text is in mtv2_spec.json "
                           "census.derived_transformations_refused, not copied here")
            uncovered.append({
                "satellite": sat, "attribute": attr, "column": col, "class": "carried_as_cdk",
                "also_a_refused_build_directive": (sat, attr) in refused,
                "routing": "mapper", "reason": reason})
            continue
        if (sat, attr) in refused:
            uncovered.append({
                "satellite": sat, "attribute": attr, "column": col,
                "class": "build_directive_refused", "routing": "mapper",
                "reason": "the map declares an executable derivation this build does not "
                          "implement and will not guess; refused, never emitted raw "
                          "(BUILD_RULES 3.1, 5.6). The derivation text is in mtv2_spec.json "
                          "census.derived_transformations_refused"})
            continue
        if rec is None:
            why = None
            for u in unbuilt_records:
                if str(u.get("what") or "").startswith(sat):
                    why = u
                    break
            if why is None and sat in {s["satellite"] for s in satellites.values()}:
                why = {"reason": "the spec carries this satellite with a child key and an EMPTY "
                                 "payload -- every payload attribute collided with a child-key "
                                 "leg name (BUILD_RULES 5.4) -- so no model is written and the "
                                 "column reaches nothing on this track",
                       "routing": "mapper"}
            uncovered.append({
                "satellite": sat, "attribute": attr, "column": col,
                "class": "satellite_not_built",
                "routing": (why or {}).get("routing") or "mapper",
                "reason": (why or {}).get("reason")
                          or "the satellite is not built and the spec carries no reason -- "
                             "REPORTED, NOT GUESSED (BUILD_RULES 5.6)"})
            continue
        uncovered.append({
            "satellite": sat, "attribute": attr, "column": col, "class": "UNEXPLAINED",
            "routing": "mapper",
            "reason": "the satellite is built and this attribute is in neither its payload nor "
                      "its child key, and the build records no reason. REPORTED, NOT GUESSED"})
    unexplained = [u for u in uncovered if u["class"] == "UNEXPLAINED"]
    return {"total": covered + len(uncovered), "covered": covered,
            "uncovered": sorted(uncovered, key=lambda u: (u["satellite"], u["column"])),
            "by_class": dict(collections.Counter(u["class"] for u in uncovered)),
            "unexplained": len(unexplained),
            "note": "measured over the same population as the shared gate's check 6: target "
                    "rows with outcome=mapped whose satellite and attribute are canonical."}


def child_key_stability_for(satellite, rows):
    """The map's own child-key stability routing for `satellite`, as VERIFIED TOKENS.

    augmentation.child_key_stability carries `candidate_stable_key` as a mixed value -- a column
    name followed by an English gloss -- and `question_for_source` as a full sentence. Neither is
    copied into a model. The candidate is reduced to its leading bare identifier and that
    identifier is CHECKED against the real columns of the views this satellite feeds from; if it
    is not a real column it is not named at all. A caveat that names a column the source does not
    have is worse than a caveat that names none (BUILD_RULES 3.1, 3.3).
    """
    found = {}
    for row in rows:
        aug = row.get("augmentation")
        if not isinstance(aug, dict):
            continue
        blk = aug.get("child_key_stability")
        if not isinstance(blk, dict):
            continue
        # THE DECLARED SPELLINGS, from the profile -- never `satellite` and never `source_view`,
        # which are what this reader first guessed and which do not exist in this map. A reader on
        # a guessed spelling matches nothing and its silence reads as "the map says nothing"
        # (BUILD_RULES 2.4).
        _af = PROFILE["map_fields"]["augmentation"]
        _rf = PROFILE["map_fields"]["row"]
        names = {str(aug.get(_af["new_satellite"]) or ""),
                 str(aug.get(_af["existing_satellite"]) or "")}
        if satellite not in names:
            continue
        view = row.get(_rf["table"]) or ""
        cand = str(blk.get("candidate_stable_key") or "").strip()
        token = cand.split(" ", 1)[0].strip().upper() if cand else ""
        real = bool(token) and token in {str(c).upper() for c in K.columns_of(view)}
        rec = found.setdefault((str(blk.get("class") or ""), str(blk.get("token") or "")),
                               {"class_token": str(blk.get("class") or ""),
                                "ordinal_token": str(blk.get("token") or ""),
                                "disposition_token": str(blk.get("disposition") or "")
                                .split(" --")[0].strip(),
                                "candidate_stable_key_column": token if real else None,
                                "candidate_is_a_real_column_on_the_view": real,
                                "candidate_as_written_NOT_emitted": cand,
                                "map_rows": 0, "views": set()})
        rec["map_rows"] += 1
        rec["views"].add(view)
    out = []
    for rec in found.values():
        rec["views"] = sorted(rec["views"])
        out.append(rec)
    return out


def probe_patterns():
    """CLAUSE 7 for this module: every module-level pattern proved to fire and to stay silent, with
    coverage ASSERTED TOTAL. This module compiles one, and one unprobed pattern is still a zero
    nobody can read."""
    checks = [{
        "check": "PREFIX_LITERAL fires and declines",
        "result": "pass" if (bool(PREFIX_LITERAL.match("'RISK:'"))
                             and not PREFIX_LITERAL.match("'risk:'")
                             and not PREFIX_LITERAL.match("nullif(trim(X),'')")) else "fail",
        "detail": "fires on a real namespace prefix literal as the map writes it; silent on a "
                  "lower-case one and on real SQL. The lower-case silence is deliberate: a "
                  "namespace is an UPPER_SNAKE token in this map and matching loosely would "
                  "invent a second key space.",
        "pattern": "PREFIX_LITERAL"}]
    n = N.assert_pattern_coverage(sys.modules[__name__],
                                 [c["pattern"] for c in checks if c.get("pattern")],
                                 "build_mtv2_spec.py")
    checks.append({"check": "pattern coverage is TOTAL in build_mtv2_spec.py", "result": "pass",
                   "detail": "%d module-level pattern(s), probed for a fire AND a silence." % n,
                   "pattern": None})
    return checks


def collapse_trap_scope_reconciliation(rows):
    """CONSUMES collapse_traps_scope_A_18 and collapse_traps_scope_B_9.

    FOUR numbers have been published for "collapse traps" on this LOB -- 20, 18, 15 and 9 -- and
    they differ by SCOPE, not by fact: the map has been byte-identical throughout. This measures
    every scope explicitly, states the denominator beside each, and asserts the ONE relation that
    must hold between them (B is a subset of A). It does NOT assert equality against any single
    figure: an equality check against a differently-scoped number is a gate that fires on correct
    data, and such a gate gets switched off (BUILD_RULES 1.12, 11.8, BD16).

    Scope S0  one distinct rendered value across ALL rows, no minimum row count -> reproduces 20
    Scope A   S0 restricted to legs appearing on MORE THAN ONE ROW              -> the profile's 18
    Scope B   A restricted to legs appearing on MORE THAN ONE VIEW              -> the profile's 9
    """
    declared_a = list(PROFILE["collapse_traps_scope_A_18"])
    declared_b = list(PROFILE["collapse_traps_scope_B_9"])

    # The scope-A entries spell a pair as "SAT_X.Leg Name = 'value' (n rows, m views)". Only the
    # part before the FIRST ' = ' is a pair name; the tail is a rendered value that may itself
    # carry an equals sign. Split once, from the left, and never parse the tail (BUILD_RULES 3).
    def _pair(entry):
        return str(entry).split(" = ", 1)[0].strip()

    pairs_a = [_pair(e) for e in declared_a]
    pairs_b = [_pair(e) for e in declared_b]
    not_in_a = sorted(set(pairs_b) - set(pairs_a))
    if not_in_a:
        raise SystemExit(
            "REFUSING TO BUILD: collapse_traps_scope_B_9 names %d pair(s) absent from "
            "collapse_traps_scope_A_18: %s. B is declared as A plus a further restriction, so a "
            "member of B that is not in A means one of the two was measured wrong "
            "(BUILD_RULES 2.2)." % (len(not_in_a), ", ".join(not_in_a)))
    s0 = sorted(PROFILE["collapse_traps"])
    unknown_sats = sorted({p.split(".", 1)[0] for p in pairs_a}
                          - {str(t).split(".", 1)[0] for t in s0})
    if unknown_sats:
        raise SystemExit(
            "REFUSING TO BUILD: collapse_traps_scope_A_18 names satellite(s) absent from "
            "collapse_traps: %s. A scope list ranging outside the population it scopes cannot be "
            "reconciled with it (BUILD_RULES 2.2)." % ", ".join(unknown_sats))
    return {
        "question_answered": "how many (satellite, child-key leg) pairs render to a SINGLE "
                             "distinct value, and so discriminate nothing until data arrives",
        "scope_S0_all_rows": {
            "count": len(s0),
            "population": "(satellite, leg) pairs on build_profile.json collapse_traps",
            "note": "the widest scope -- one distinct rendered value across ALL rows, no minimum "
                    "row count. This is the scope that reproduces the figure 20 and the scope "
                    "this BUILD acts on: assert_not_only_traps() refuses or warns against exactly "
                    "this list."},
        "scope_A_more_than_one_row": {
            "count": len(pairs_a),
            "declared_by": "build_profile.json collapse_traps_scope_A_18",
            "denominator_note": "stage 0 states 58 (satellite, leg) pairs carrying a child-key leg "
                                "at all; an independent stage-2 sweep states 57. THE DIFFERENCE IS "
                                "IN THE DENOMINATOR, NOT THE NUMERATOR, and it is carried "
                                "unreconciled rather than split by this build, which acts on S0."},
        "scope_B_more_than_one_view": {
            "count": len(pairs_b),
            "declared_by": "build_profile.json collapse_traps_scope_B_9",
            "subset_of_A": True},
        "asserted": "scope B is a SUBSET of scope A (%d of %d), and every satellite named by "
                    "scope A is on the trap list this build acts on"
                    % (len(pairs_b), len(pairs_a)),
        "NOT_asserted": "equality against any one figure. 20, 18, 15 and 9 are each true of their "
                        "own stated scope over a byte-identical map (BD16).",
    }


def assert_component_kind_spelling_absent(rows):
    """CONSUMES component_kinds_field_note by RE-DERIVING its premise, never by trusting it.

    The note says the field literally named `kind` is ABSENT on all child_key_components elements
    and that the role is carried by `leg_backing`. A reader built on `kind` matches nothing,
    returns None on every leg, and the build reports a SOURCE gap for what is a reader defect.
    That is not a risk worth carrying on a note, so it is counted.
    """
    declared_field = PROFILE["component_kinds_field"]
    spellings = {}
    elements = 0
    for row in rows:
        for blk in ("target", "augmentation"):
            body = row.get(blk)
            if not isinstance(body, dict):
                continue
            for comp in (body.get("child_key_components") or []):
                if not isinstance(comp, dict):
                    continue
                elements += 1
                for k in comp:
                    spellings[k] = spellings.get(k, 0) + 1
    literal_kind = spellings.get("kind", 0)
    if literal_kind:
        raise SystemExit(
            "REFUSING TO BUILD: component_kinds_field_note states the spelling `kind` is ABSENT on "
            "every child_key_components element, but this build counts %d occurrence(s) over %d "
            "element(s). Two fields able to carry one role is a mapper question, not a reader "
            "default (BUILD_RULES 2.2, 1.5)." % (literal_kind, elements))
    if not spellings.get(declared_field):
        raise SystemExit(
            "REFUSING TO BUILD: the profile declares the component kind is carried by %r and this "
            "build finds ZERO elements carrying it over %d element(s). A reader bound to a "
            "spelling that does not occur returns None on every leg, and the gap reads as a "
            "SOURCE gap (BUILD_RULES 2.4)." % (declared_field, elements))
    return {"elements": elements,
            "kind_field_declared_by_the_profile": declared_field,
            "occurrences_of_the_declared_field": spellings[declared_field],
            "occurrences_of_the_literal_spelling_kind": literal_kind,
            "all_spellings_counted": dict(sorted(spellings.items())),
            "note": "re-derived by COUNTING the live map, never read from "
                    "component_kinds_field_note"}


def link_leg_census(leg_population, uncorroborated):
    """ONE population, four bindings, and the coverage limit each implies.

    Three numbers for LNK legs have been quoted on this project and all three are TRUE of
    DIFFERENT populations, which is why they have to be stated together:

      * legs_total -- every leg of every LNK call. The profile's grammar_lnk_census agrees.
      * named_hub  -- the map names a HUB_ for the leg. Its binding is checkable from the map.
      * named_hub + named_role -- legs carrying ANY name token. This is the build parser's
        `lnk_named_legs` and the profile's "named" count; the two agree.
      * positional -- no name at all. Bound by the link's hub order in data_7.js.

    The COVERAGE LIMIT is stated against the population it applies to: leg-equals-hub-key is
    verifiable only where the map names the hub. On every other leg the leg and the hub key are
    rendered by the same render_key() from the same slot, so they agree BY CONSTRUCTION and the
    audit cannot see a mis-binding.
    """
    by = collections.Counter(x["binding"] for x in leg_population)
    total = len(leg_population)
    named_any = sum(1 for x in leg_population if x["has_name_token"])
    not_named_for_a_hub = total - by["named_hub"]
    by_hub = collections.Counter(x["declared"] for x in leg_population
                                 if x["binding"] == "named_hub")
    by_sep = collections.Counter(x.get("name_separator") for x in leg_population
                                 if x["binding"] == "named_hub")
    unbound = len(uncorroborated) + by["literal"]
    return {
        "population": "%d legs over %d LNK( OCCURRENCES. Every figure below is over THIS "
                      "population unless it names another." % (total, K.PARSE_STATS["lnk_call_sites"]),
        "THE_THREE_QUESTIONS": {
            "1_names_a_hub": "does the MAP write a HUB_ name token before this leg? %d of %d DO, "
                             "%d do NOT. Swept over BOTH declared separators: %d named with '=' "
                             "and %d with ':'. AN EQUALS-ONLY READER MEASURES %d AND %d, which is "
                             "where the withdrawn '34 name a hub, 57 do not' comes from -- a "
                             "reader defect, not a map fact (BD15)."
                             % (by["named_hub"], total, not_named_for_a_hub,
                                by_sep.get("=", 0), by_sep.get(":", 0),
                                by_sep.get("=", 0), total - by_sep.get("=", 0)),
            "2_binds_to_a_hub": "does the leg's EXPRESSION also appear as a hub key resolved on "
                                "the SAME view? %d of %d do NOT -- %d carry no on-view hub key "
                                "with that expression and %d are pure literals with no hub to "
                                "bind to. A different question from naming, with a different "
                                "answer." % (unbound, total, len(uncorroborated), by["literal"]),
            "3_is_positional": "does the leg carry NO name token at all, so its hub comes from the "
                               "link's hub ORDER in data_7.js? %d of %d legs."
                               % (total - named_any, total),
        },
        "FIGURES_PUBLISHED_ON_THIS_PROJECT_AND_WHAT_EACH_ANSWERED": {
            "4": "WITHDRAWN. Legs that were BOTH positional AND uncorroborated -- a subset of a "
                 "subset, published as if it were the coverage limit, understating it by an order "
                 "of magnitude.",
            "34": "WITHDRAWN as a hub-naming count over this population. It is the count under an "
                  "EQUALS-ONLY name reader: the map names %d further leg(s) with ':' and the "
                  "profile's own grammar_lnk_census declares 9 colon-form call sites, so such a "
                  "reader contradicts a field it could have read." % by_sep.get(":", 0),
            "52": "NOT WITHDRAWN -- re-derived independently this run and CORRECT. It is the count "
                  "of legs naming NO hub over this %d-leg population. A handback withdrew it as "
                  "wrong; it is restated here as right, with its question named." % total,
            "57": "the LEG TOTAL of a DIFFERENT population -- the 30 distinct (view, expression) "
                  "call sites carry 57 legs, of which 34 name no hub. 57 and 34 are both true of "
                  "THAT population; presented as a split of %d they fuse two scopes." % total,
            "19": "NOT REPRODUCED, and NOT GUESSED AT. It is recorded in BUILD_STATUS.counts as "
                  "link_legs_not_bound_to_any_hub_by_name_or_expression_match -- a THIRD question, "
                  "crediting a NAME match as well as an expression match. This build measures "
                  "question 2 as %d unbound by EXPRESSION match (%d with no on-view hub key, %d "
                  "pure literals with no hub to bind to), which agrees with its own counters and "
                  "with an independent re-derivation. 19 is neither confirmed nor contradicted "
                  "here: its definition is not this one, and inventing a derivation that lands on "
                  "it would be the same error as the figures above."
                  % (unbound, len(uncorroborated), by["literal"]),
        },
        "named_for_a_hub_by_separator": {"equals": by_sep.get("=", 0),
                                         "colon": by_sep.get(":", 0)},
        "legs_total": total,
        "by_binding": dict(by),
        "named_for_a_hub": by["named_hub"],
        "named_for_a_hub_by_hub": dict(by_hub),
        "no_name_token_at_all": total - named_any,
        "named_for_a_non_hub_role": by["named_role"],
        "carrying_any_name_token": named_any,
        "positional_no_name_token": by["positional"],
        "literal_degenerate": by["literal"],
        "not_named_for_a_hub": not_named_for_a_hub,
        "uncorroborated_by_an_on_view_hub_key": len(uncorroborated),
        "uncorroborated_and_positional": sum(1 for x in uncorroborated if x.get("positional")),
        "reconciliation": {
            "build_parser_lnk_named_legs": named_any,
            "profile_grammar_lnk_census_legs_total": PROFILE["grammar_lnk_census"]["legs_total"],
            "note": "All three published figures are right about their own scope. The figure a "
                    "reader should quote for the COVERAGE LIMIT is not_named_for_a_hub, because "
                    "that is the population whose hub binding the map does not state. The "
                    "previously published figure counted only legs that were BOTH positional AND "
                    "uncorroborated, which is a subset of a subset and understated the limit by "
                    "an order of magnitude (BUILD_RULES 11.8).",
        },
        "coverage_limit": "the leg-equals-hub-key property is UNVERIFIABLE on the legs that name "
                          "no hub: leg and hub key come from one renderer and agree by "
                          "construction, so audit_mtv2_link_leg_divergence cannot see a "
                          "mis-bound leg there. It is verifiable only on the named legs.",
    }


def measure_expression_slots(rows):
    """Live expression slots, counted STRUCTURALLY over the map: one per resolved_key expression
    and one per child-key component expression, on both blocks. This is the population
    build_profile.json splits four ways in function_census_verified_per_slot."""
    n = 0
    for row in rows:
        for blk in ("target", "augmentation"):
            body = row.get(blk)
            if not body:
                continue
            rk = body.get("resolved_key") or {}
            if rk.get(MF["target.resolved_key"]["expression"]):
                n += 1
            for comp in (body.get("child_key_components") or []):
                if comp.get(K.LEG_EXPR_FIELD):
                    n += 1
    return n


def measure_transformation_contract(rows):
    """The transformation kind census and the build_directive population, measured over the
    container the profile names -- the TARGET block -- with the field spellings it declares."""
    kinds = collections.Counter()
    directives = 0
    for row in rows:
        body = row.get("target")
        if not body:
            continue
        if body.get(TRANSFORMATION_FIELD) not in (None, ""):
            kinds[body.get(TRANSFORMATION_KIND_FIELD)] += 1
        if body.get(BUILD_DIRECTIVE_FIELD):
            directives += 1
    return dict(kinds), directives


def crosscheck_profile(measured):
    """The five rev-5 profile keys this build CONSUMES, each checked against what the build
    itself measured. A profile that describes a different map than the one on disk is the
    silent failure BUILD_RULES 2.2 exists to stop, so a disagreement on an IDENTICALLY defined
    population is fatal and a disagreement on a differently scoped one is reported.

    `measured` is a dict of this build's own counts; nothing here is retyped from the profile.
    """
    out, fatal = [], []

    def cmp_(item, mine, theirs, population, fatal_on_mismatch):
        rec = {"item": item, "mine": mine, "profile": theirs, "population": population,
               "agrees": mine == theirs}
        if not rec["agrees"] and fatal_on_mismatch:
            fatal.append("%s: this build measures %r, build_profile.json states %r (%s)"
                         % (item, mine, theirs, population))
        out.append(rec)
        return rec

    slots = PROFILE["function_census_verified_per_slot"]
    per_slot_total = sum(v["slots"] for k, v in slots.items() if isinstance(v, dict)
                         and "slots" in v)
    cmp_("live expression slots", measured["expression_slots"], per_slot_total,
         "sum of function_census_verified_per_slot[*].slots over the four expression-bearing "
         "slots; the build counts the same four", True)

    fk = PROFILE["foreign_key_population"]
    cmp_("spine[FOREIGN_KEY] expression slots", measured["fk_hops"],
         fk["expression_slots_using_spine_FOREIGN_KEY"],
         "expression slots whose walk starts at FOREIGN_KEY", True)

    so = PROFILE["still_open_reconfirmed"]
    cmp_("child-key legs carrying the unresolved sentinel",
         measured["leg_unresolved_sentinel_refused"],
         so["leg_backing_unresolved_sentinel"]["occurrences"],
         "legs whose leg_backing is 'unresolved'; refused, never rendered", True)

    hro = PROFILE["hub_risk_object"]
    cmp_("HUB_RISK_OBJECT namespaces", sorted(measured["hub_risk_object_namespaces"]),
         sorted(hro["namespaces"]),
         "the namespace SET on the built key surface. The profile counts MAP ROWS and the build "
         "counts KEY SLOTS, so only the set is comparable", True)

    tc = PROFILE["transformation_contract"]
    cmp_("transformation_kind census", measured["transformation_kinds"], tc["kind_census"],
         "rows carrying a transformation, by declared kind", True)
    cmp_("rows carrying build_directive=true", measured["build_directive_rows"],
         tc["build_directive_true_rows"], "the executable rows this build REFUSES", True)

    if fatal:
        raise SystemExit(
            "REFUSING TO BUILD: build_profile.json and the map on disk disagree:\n  %s\n"
            "The profile is a machine-read artifact and gets the same suspicion as the map "
            "(BUILD_RULES 2.2, 3.4)." % "\n  ".join(fatal))
    return {"checked": out,
            "do_not_quote": PROFILE["foreign_key_population"]["do_not_quote_733_note"],
            "hub_risk_object_open": PROFILE["hub_risk_object"]["status_note"],
            "still_open": sorted(k for k in PROFILE["still_open_reconfirmed"]
                                 if isinstance(PROFILE["still_open_reconfirmed"][k], dict)
                                 and PROFILE["still_open_reconfirmed"][k].get("status") == "OPEN"),
            "gate_status_warns": (PROFILE["gate_status"]["validate_mapping"]["warn"]),
            "gate_status_blockers": (PROFILE["gate_status"]["validate_mapping"]["blockers"])}


def crosscheck_build_directives(found):
    """The bundle enumerates its executable rows in 20_build_directives.json. Compare, and
    REPORT a disagreement rather than preferring either source."""
    path = os.path.join(N.BUNDLE, "20_build_directives.json")
    if not os.path.exists(path):
        return {"file": None, "agreement": "file absent from the bundle",
                "mine": len(found), "theirs": None}
    doc = json.loads(N.read_input(path))
    theirs = {(d["table"], d["column"], d["target"]) for d in doc.get("directives", [])}
    mine = {(d["view"], d["source_column"], "%s.%s" % (d["satellite"], d["attribute"]))
            for d in found}
    return {"file": "20_build_directives.json", "rule": doc.get("rule"),
            "theirs": len(theirs), "mine": len(mine),
            "only_in_the_bundle": sorted("%s | %s | %s" % t for t in theirs - mine),
            "only_in_my_sweep": sorted("%s | %s | %s" % t for t in mine - theirs),
            "agreement": "IDENTICAL" if theirs == mine else
                         "DISAGREES -- reported, neither source preferred"}

# --------------------------------------------------------------------------- walk registry
class ViewWalks(object):
    """Per start view: every walk any expression on it needs, deduplicated, with a stable alias.

    Aliases are assigned on first sight in row order, which is deterministic for a given map --
    so the spec and every model built from it are byte-reproducible from an empty models/.
    """

    def __init__(self, view):
        self.view = view
        self.order = []
        self.by_key = {}

    def register(self, walk):
        k = walk.key()
        if k in self.by_key:
            walk.alias = self.by_key[k].alias
            return self.by_key[k]
        walk.alias = "w%d_%s" % (len(self.order), N.cast_alias(walk.column))
        self.by_key[k] = walk
        self.order.append(walk)
        return walk

    def alias_of(self, walk):
        return self.register(walk).alias

    def as_json(self):
        return [{"alias": w.alias, "join_column": w.join_column,
                 "chain": list(w.chain), "column": w.column, "relation": w.relation,
                 "destination": w.destination} for w in self.order]


WALKS = {}


def walks_for(view):
    if view not in WALKS:
        WALKS[view] = ViewWalks(view)
    return WALKS[view]


def render(expression, view, where, kind="hub"):
    reg = walks_for(view)
    rk = K.render_key(expression, view, where, kind=kind, alias_of_walk=reg.alias_of)
    for w in rk.walks:
        reg.register(w)
    return rk


# --------------------------------------------------------------------------- main build
def build():
    rows = load_map()
    degenerate_contract = assert_degenerate_contract(rows)
    keynorm_shapes = assert_keynorm_shapes(rows)
    model = load_model()
    sib = N.sibling_satellites()

    row_field = MF["row"]
    tgt_field = MF["target"]
    aug_field = MF["augmentation"]
    rk_field = MF["target.resolved_key"]

    key_slots = {}            # (view, hub, instance, expr) -> slot
    sat_rows = collections.defaultdict(list)     # (view, satellite, track) -> [row records]
    link_rows = []
    deferred = []
    hub_row_counts = collections.Counter()
    hash_forms = collections.Counter()
    hash_forms_by_hub = collections.defaultdict(collections.Counter)
    namespace_counts = collections.defaultdict(collections.Counter)
    constant_keys = []
    key_expr_by_view = collections.defaultdict(dict)
    degenerate_outer = []
    ordinal_legs_seen = []
    link_anchored_rows = collections.Counter()
    transformations = collections.Counter()
    derived_refused = []
    sibling_src_pk_repoints, src_pk_unmatched = [], []

    NAMESPACE = re.compile(r"\A'([A-Z_]+:)'")

    def slot_for(view, hub, instance, expression, tier, where):
        try:
            rk = render(expression, view, where, kind="hub")
        except K.KeyGrammarError as exc:
            K.unresolved("key_unrenderable", where, str(exc), view=view, hub=hub,
                         expression=str(expression)[:200])
            return None
        # Slot identity is the RENDERED KEY. Two expressions that name one destination with an
        # abbreviated token and with its full name resolve to the same walk and the same SQL;
        # keying the slot on the expression STRING instead minted two 'proposer' key columns on
        # one view -- two hub populations for one party.
        k = (view, hub, instance, rk.sql)
        if k in key_slots:
            key_slots[k]["rows"] += 1
            key_slots[k]["expressions"].add(str(expression))
            key_expr_by_view[view][K.normalise_for_match(expression)] = hub
            return key_slots[k]
        variant = sum(1 for kk in key_slots if kk[0] == view and kk[1] == hub and kk[2] == instance)
        suffix = N.instance_suffix(instance) + ("__v%d" % (variant + 1) if variant else "")
        slot = {
            "view": view, "hub": hub, "instance": instance, "expression": expression,
            "tier": tier, "sql": rk.sql, "hkey": N.hub_key_column(hub) + suffix.upper(),
            "bk": N.hub_bk_column(hub) + suffix.upper(),
            "nk": N.hub_nk_column(hub) + suffix.upper(),
            "nk_sql": N.natural_key(hub, rk.sql),
            "walks": [w.alias for w in rk.walks], "shape": rk.shape,
            "degenerate": rk.degenerate, "constant": rk.constant, "rows": 1,
            "columns": rk.columns, "variant": variant + 1,
            "expressions": {str(expression)},
        }
        key_slots[k] = slot
        if rk.constant:
            constant_keys.append(slot)
        if rk.degenerate:
            degenerate_outer.append(slot)
        hash_forms[rk.shape] += 1
        hash_forms_by_hub[hub][rk.shape] += 1
        m = NAMESPACE.match(str(expression).strip())
        if m:
            namespace_counts[hub][m.group(1)] += 1
        key_expr_by_view[view][K.normalise_for_match(expression)] = hub
        return slot

    # ---------------------------------------------------------------- pass 1: rows
    for i, row in enumerate(rows):
        view = row[row_field["table"]]
        column = row[row_field["column"]]
        outcome = row[row_field["outcome"]]
        if not K.view_exists(view):
            unbuilt("view %s" % view, "not present in 00_tables_index.json", "mapper")
            continue
        if column not in K.columns_of(view):
            NOTES["row_column_not_on_view"] += 1

        for track, block_name in (("target", "target"), ("augmentation", "augmentation")):
            body = row.get(block_name)
            if not body:
                continue
            fields = tgt_field if track == "target" else aug_field
            rk = body.get("resolved_key") or {}
            hub = rk.get(rk_field["hub"])
            expression = rk.get(rk_field["expression"])
            instance = rk.get(rk_field["instance"])
            tier = rk.get(rk_field["tier"])
            where = "row %d %s.%s [%s]" % (i, view, column, track)

            if hub and not expression:
                unbuilt("%s key on %s.%s" % (hub, view, column),
                        "resolved_key.expression is empty -- no identifier for this hub exists on "
                        "this view. Not invented (BUILD_RULES 5.6).", "source",
                        view=view, hub=hub, track=track, column=column)
                continue
            if not hub:
                # The block carries an ANCHOR but no resolved_key at all -- 190 of them, almost
                # all augmentation. Dropping them is a silence no other check can see
                # (BUILD_RULES 8): coverage would read complete because the attribute was never
                # in the denominator. They are deferred and bound in pass 1b to the key slot the
                # MAP ITSELF resolved for that anchor on this very view -- not to a key this
                # build invented (BD11).
                anchor = body.get(fields["anchor"]) if "anchor" in fields else None
                deferred.append({"i": i, "view": view, "column": column, "track": track,
                                 "body": body, "fields": fields, "anchor": anchor,
                                 "instance": body.get(fields["instance"]), "where": where})
                continue

            hub_row_counts[hub] += 1

            if str(expression).strip().startswith("LNK("):
                link_rows.append({"i": i, "view": view, "column": column, "link": hub,
                                  "instance": instance, "expression": expression,
                                  "track": track, "where": where, "tier": tier,
                                  "body": body, "fields": fields})
                continue

            slot = slot_for(view, hub, instance, expression, tier, where)
            if slot is None:
                continue

            if track == "target":
                kind = body.get(tgt_field["kind"])
                if kind == "hub_key":
                    continue
                if kind not in ("satellite_attribute", "link_key"):
                    raise SystemExit(
                        "UNRECOGNISED target kind %r at %s. Sweep the set, never a named member "
                        "(BUILD_RULES 1.5)." % (kind, where))
                satellite = body.get(tgt_field["satellite"])
                attribute = body.get(tgt_field["attribute"])
            else:
                satellite = body.get(aug_field["new_satellite"]) or body.get(
                    aug_field["existing_satellite"])
                attribute = body.get(aug_field["attribute"])
            if not satellite or not attribute:
                NOTES["row_without_a_satellite_attribute_%s" % track] += 1
                continue
            verdict = classify_transformation(body, where)
            transformations[verdict or "absent"] += 1
            if verdict == "refuse":
                derived_refused.append({
                    "satellite": satellite, "attribute": attribute, "view": view,
                    "source_column": column, "track": track,
                    "transformation": str(body.get(TRANSFORMATION_FIELD)).strip()})
                unbuilt("%s.%s from %s.%s" % (satellite, attribute, N.short_view(view), column),
                        "transformation_kind=executable_expression with build_directive=true. The "
                        "map DECLARES this attribute requires a derivation this build does not "
                        "implement: %r. Emitting the raw column would put an untransformed value "
                        "into the attribute -- a date of birth in an age field, or a whole "
                        "delimited list where one row per code is wanted -- which is WRONG data "
                        "rather than missing data and passes every gate. Refused; the derivation "
                        "is reported verbatim. Not implemented because its functions are not "
                        "ratified in KEY_FUNCTIONS.md and a split-to-rows is a bespoke FAN-OUT "
                        "layer (BUILD_RULES 6.5), not an expression."
                        % str(body.get(TRANSFORMATION_FIELD)).strip(),
                        "mapper", count=1, view=view, satellite=satellite, attribute=attribute)
                continue

            legs, leg_problem = [], None
            for j, comp in enumerate(body.get("child_key_components") or []):
                leg_name = comp.get(K.LEG_NAME_FIELD)
                rendered = K.render_child_leg(comp, view, "%s leg[%d]" % (where, j),
                                              alias_of_walk=walks_for(view).alias_of)
                if rendered is None:
                    leg_problem = leg_name
                    continue
                for w in rendered.walks:
                    walks_for(view).register(w)
                legs.append({"name": leg_name, "sql": rendered.sql,
                             "kind": K.leg_kind(comp), "constant": rendered.constant,
                             "column": N.cdk_column(leg_name)})
                if rendered.columns:
                    ords = K.ordinal_legs(rendered.columns)
                    if ords:
                        ordinal_legs_seen.append(
                            {"satellite": satellite, "leg": leg_name, "columns": ords,
                             "view": view, "spellings_checked": sorted(K.RENUMBERING_ORDINALS)})

            declared_multi = bool(body.get(aug_field["multi_active"])) if track == "augmentation" \
                else bool(model["sats"].get(satellite, {}).get("childkey"))
            declared_ck_name = (body.get(aug_field["child_key_declared_note"])
                                if track == "augmentation"
                                else model["sats"].get(satellite, {}).get("childkey"))

            sat_rows[(view, satellite, track)].append({
                "i": i, "column": column, "attribute": attribute, "slot": slot,
                "legs": legs, "leg_problem": leg_problem, "declared_multi": declared_multi,
                "declared_ck_name": declared_ck_name, "where": where,
                # three fields NEW in this re-issue; named from the profile's alternates
                # census so none is read by a remembered spelling (BUILD_RULES 2.4)
                "legs_missing": body.get("child_key_legs_missing"),
                "stability": body.get("child_key_stability"),
                "components_gap": body.get("child_key_components_gap"),
                "redundant_of": body.get(fields["redundant_of"]),
            })

    # ---------------------------------------------------------------- pass 2: link legs
    links = {}
    link_slots, link_sat_pending = {}, []
    lnk_uncorroborated, lnk_literal_legs = [], []
    leg_key_divergence = []
    # THE LINK-LEG POPULATION, counted once, here, so no reader has to reconcile three numbers
    # from three scopes. Every leg of every LNK call is classified by HOW ITS HUB IS BOUND.
    leg_population = []
    for rec in link_rows:
        view, link = rec["view"], rec["link"]
        try:
            legs = K.parse_link(rec["expression"], view, rec["where"])
        except K.KeyGrammarError as exc:
            K.unresolved("link_unparsed", rec["where"], str(exc), link=link)
            continue
        model_hubs = model["links"].get(link, {}).get("hubs", [])
        for _leg in legs:
            _declared = _leg["declared_hub"]
            if K.is_pure_literal(_leg["expression"]):
                _binding = "literal"          # a degenerate leg: no hub to bind
            elif _declared and str(_declared).startswith("HUB_"):
                _binding = "named_hub"        # the map names the hub this leg fills
            elif _declared:
                _binding = "named_role"       # named for something that is NOT a hub (BD5)
            else:
                _binding = "positional"       # bound by the link's hub order in data_7.js
            leg_population.append({"link": link, "view": view, "binding": _binding,
                                   "declared": _declared,
                                   "name_separator": _leg.get("name_separator"),
                                   "has_name_token": bool(_declared)})
        rendered_legs, ok = [], True
        hub_cursor = 0
        for leg in legs:
            expr = leg["expression"]
            norm = K.normalise_for_match(expr)
            corroborated = norm in key_expr_by_view.get(view, {})
            bound_hub = leg["declared_hub"] if (leg["declared_hub"] or "").startswith("HUB_") else None
            if bound_hub is None and corroborated:
                bound_hub = key_expr_by_view[view][norm]
            named_not_a_hub = bool(leg["declared_hub"]) and not leg["declared_hub"].startswith("HUB_")
            if K.is_pure_literal(expr) or named_not_a_hub:
                lnk_literal_legs.append({"view": view, "link": link, "leg": expr,
                                         "where": rec["where"]})
                if K.LINK_DEGENERATE_LEG == "drop":
                    continue
                if K.is_pure_literal(expr):
                    leg_sql = "'" + expr.strip()[1:-1].replace("'", "''") + "'"
                else:
                    # A leg NAMED for something that is not a hub -- 'ROLE: <expr>' -- is the role
                    # discriminator. It is rendered by the same render_key() as every other leg.
                    try:
                        leg_sql = render(expr, view, rec["where"], kind="child_leg").sql
                    except K.KeyGrammarError as exc:
                        K.unresolved("link_degenerate_leg_unrenderable", rec["where"], str(exc),
                                     link=link)
                        ok = False
                        break
                # ONE name for the degenerate leg of a link, whether the map wrote it
                # positionally or as 'ROLE: <expr>'. Two names for one column is two columns.
                rendered_legs.append({"role": "degenerate", "hub": None,
                                      "column": N.payload_column(link[4:] + "_ROLE"),
                                      "declared_name": leg["declared_hub"],
                                      "sql": leg_sql, "corroborated": False})
                continue
            if bound_hub is None:
                bound_hub = model_hubs[hub_cursor] if hub_cursor < len(model_hubs) else None
            if bound_hub is None:
                K.unresolved("link_leg_unbound", rec["where"],
                             "leg %r on %s binds to no hub" % (expr[:80], link), link=link)
                ok = False
                break
            hub_cursor += 1
            if not corroborated:
                lnk_uncorroborated.append({"view": view, "link": link, "hub": bound_hub,
                                           "leg": expr[:160], "where": rec["where"],
                                           "positional": leg["declared_hub"] is None})
                # Does the SAME VIEW resolve a key for this hub by a DIFFERENT expression? That
                # is the divergence that produces an empty join and reads as sparse source data.
                rival = [sl for sl in key_slots.values()
                         if sl["view"] == view and sl["hub"] == bound_hub]
                if rival:
                    ws_only = any(K.normalise_for_match(e) == norm
                                  for sl in rival for e in sl["expressions"])
                    leg_key_divergence.append({
                        "link": link, "hub": bound_hub, "view": view,
                        "leg_expression": expr,
                        "hub_key_expressions": sorted(
                            {e for sl in rival for e in sl["expressions"]})[:4],
                        "class": "whitespace_only" if ws_only else "VALUE_CHANGING",
                        "consequence": "the leg and the hub key are different values, so the link "
                                       "joins to nothing and the miss reads as sparse source "
                                       "data" if not ws_only else
                                       "render_key() normalises both to the same SQL; no effect",
                        "built": "as mapped (BD12)"})
                else:
                    leg_key_divergence.append({
                        "link": link, "hub": bound_hub, "view": view,
                        "leg_expression": expr, "hub_key_expressions": [],
                        "class": "ORPHAN_LEG",
                        "consequence": "no key for this hub is resolved on this view at all, so "
                                       "the leg mints a hub member the hub feed never creates",
                        "built": "as mapped (BD12)"})
                if K.LNK_LEG_UNCORROBORATED == "fatal":
                    K.unresolved("link_leg_uncorroborated", rec["where"],
                                 "leg not also used as an on-view hub key", link=link)
                    ok = False
                    break
            slot = slot_for(view, bound_hub, rec["instance"], expr, rec["tier"], rec["where"])
            if slot is None:
                ok = False
                break
            rendered_legs.append({"role": "hub", "hub": bound_hub, "column": slot["hkey"],
                                  "bk": slot["bk"], "sql": slot["sql"],
                                  "corroborated": corroborated})
        if not ok or not rendered_legs:
            unbuilt("%s leg set on %s" % (link, view),
                    "a leg could not be bound to a hub or rendered", "mapper", view=view)
            continue
        nk_parts = [l["sql"] for l in rendered_legs]
        nk_sql = "'%s|' || (%s)" % (link, " || '|' || ".join(
            "coalesce(%s,'')" % p for p in nk_parts))
        entry = links.setdefault(link, {"link": link, "hubs": [], "feeders": [],
                                        "degenerate_columns": []})
        for l in rendered_legs:
            if l["role"] == "hub" and l["hub"] not in entry["hubs"]:
                entry["hubs"].append(l["hub"])
            if l["role"] == "degenerate" and l["column"] not in entry["degenerate_columns"]:
                entry["degenerate_columns"].append(l["column"])
        suffix = N.instance_suffix(rec["instance"]).upper()
        link_slot = {
            "view": view, "hub": link, "instance": rec["instance"], "is_link": True,
            "expression": rec["expression"], "tier": rec["tier"],
            "hkey": N.hub_key_column(link) + suffix,
            "bk": N.hub_bk_column(link) + suffix,
            "nk": N.hub_nk_column(link) + suffix,
            "sql": " || '|' || ".join("coalesce(%s,'')" % pp for pp in nk_parts),
            "nk_sql": nk_sql, "legs": rendered_legs,
        }
        feeder = {"view": view, "instance": rec["instance"], "hkey": link_slot["hkey"],
                  "bk": link_slot["bk"], "nk": link_slot["nk"], "nk_sql": nk_sql,
                  "legs": rendered_legs}
        if feeder not in entry["feeders"]:
            entry["feeders"].append(feeder)
        link_slots[(view, link, rec["instance"])] = link_slot
        # the row is ALSO a satellite attribute in 50 of this bundle's 51 LNK() expressions
        link_sat_pending.append((rec, link_slot))

    # ------------------------------------------- pass 2b: link-anchored satellite rows
    for rec, link_slot in link_sat_pending:
        body, fields, track, view = rec["body"], rec["fields"], rec["track"], rec["view"]
        if track == "target":
            if body.get(tgt_field["kind"]) == "link_key":
                continue
            satellite = body.get(tgt_field["satellite"])
            attribute = body.get(tgt_field["attribute"])
        else:
            satellite = body.get(aug_field["new_satellite"]) or body.get(
                aug_field["existing_satellite"])
            attribute = body.get(aug_field["attribute"])
        if not satellite or not attribute:
            NOTES["link_row_without_a_satellite_attribute"] += 1
            continue
        verdict = classify_transformation(body, rec["where"])
        transformations[verdict or "absent"] += 1
        if verdict == "refuse":
            derived_refused.append({
                "satellite": satellite, "attribute": attribute, "view": view,
                "source_column": rec["column"], "track": track,
                "transformation": str(body.get(TRANSFORMATION_FIELD)).strip()})
            unbuilt("%s.%s from %s.%s" % (satellite, attribute, N.short_view(view), rec["column"]),
                    "target.transformation declares a DERIVATION this build does not implement: "
                    "%r. Refused rather than emitted raw." % str(body.get(TRANSFORMATION_FIELD)).strip(),
                    "mapper", count=1, view=view, satellite=satellite, attribute=attribute)
            continue
        legs = []
        for j, comp in enumerate(body.get("child_key_components") or []):
            leg_name = comp.get(K.LEG_NAME_FIELD)
            rendered = K.render_child_leg(comp, view, "%s leg[%d]" % (rec["where"], j),
                                          alias_of_walk=walks_for(view).alias_of)
            if rendered is None:
                continue
            for w in rendered.walks:
                walks_for(view).register(w)
            legs.append({"name": leg_name, "sql": rendered.sql, "kind": K.leg_kind(comp),
                         "constant": rendered.constant, "column": N.cdk_column(leg_name)})
        declared_multi = bool(body.get(aug_field["multi_active"])) if track == "augmentation" \
            else bool(model["sats"].get(satellite, {}).get("childkey"))
        declared_ck_name = (body.get(aug_field["child_key_declared_note"])
                            if track == "augmentation"
                            else model["sats"].get(satellite, {}).get("childkey"))
        sat_rows[(view, satellite, track)].append({
            "i": rec["i"], "column": rec["column"], "attribute": attribute, "slot": link_slot,
            "legs": legs, "leg_problem": None, "declared_multi": declared_multi,
            "declared_ck_name": declared_ck_name, "where": rec["where"],
            "legs_missing": body.get("child_key_legs_missing"),
            "stability": body.get("child_key_stability"),
            "components_gap": body.get("child_key_components_gap"),
            "redundant_of": body.get(fields["redundant_of"]),
            "on_link": True,
        })
        link_anchored_rows[satellite] += 1

    # ------------------------------------------------- pass 2c: anchor-only rows (BD11)
    # Runs AFTER the link pass so an anchor whose only key on the view is a LINK key can be
    # bound. Running it earlier reported one row unbuilt for a reason that was an artefact
    # of pass order rather than a fact about the map.
    by_view_anchor = collections.defaultdict(list)
    for slot in list(key_slots.values()) + list(link_slots.values()):
        by_view_anchor[(slot["view"], slot["hub"])].append(slot)
    anchor_bound = collections.Counter()
    anchor_dominant = []
    for d in deferred:
        cands = by_view_anchor.get((d["view"], d["anchor"]), [])
        if not cands:
            unbuilt("%s on %s.%s" % (d["anchor"] or "(no anchor)", N.short_view(d["view"]),
                                     d["column"]),
                    "the row carries no resolved_key and no other row resolves %r on this view, "
                    "so there is no key the MAP has already resolved to attach it to. Not "
                    "invented (BUILD_RULES 5.6)." % d["anchor"],
                    "mapper", track=d["track"], view=d["view"], count=1)
            continue
        body0, fields0, track0 = d["body"], d["fields"], d["track"]
        if track0 == "target":
            sat0 = body0.get(tgt_field["satellite"])
        else:
            sat0 = body0.get(aug_field["new_satellite"]) or body0.get(
                aug_field["existing_satellite"])
        exact = [c for c in cands if c["instance"] == d["instance"]]
        chosen = exact[0] if exact else None
        if chosen is None and sat0:
            # the row's OWN satellite is already fed from this view against a specific key slot;
            # that is the map's own placement, not a build guess.
            peers = collections.Counter(
                id(r["slot"]) for r in sat_rows.get((d["view"], sat0, track0), [])
                if r["slot"]["hub"] == d["anchor"])
            if peers:
                want = peers.most_common(1)[0][0]
                chosen = next(c for c in cands if id(c) == want)
                anchor_bound["(via its own satellite on the same view)"] += 1
        if chosen is None and len(cands) == 1:
            chosen = cands[0]
        if chosen is None and K.ANCHOR_AMBIGUOUS == "dominant":
            ranked = sorted(cands, key=lambda c: -c.get("rows", 1))
            if ranked[0].get("rows", 1) > ranked[1].get("rows", 1):
                chosen = ranked[0]
                anchor_dominant.append({
                    "view": d["view"], "anchor": d["anchor"], "column": d["column"],
                    "track": d["track"], "bound_to_instance": chosen["instance"],
                    "vote": {str(c["instance"]): c.get("rows", 1) for c in ranked},
                    "assumption": "the row names no instance and the map resolves %d %s keys on "
                                  "this view; bound to the one the map itself uses for %d of %d "
                                  "rows. Reported per row, not resolved (BUILD_RULES 11.3)."
                                  % (len(cands), d["anchor"], ranked[0]["rows"],
                                     sum(c.get("rows", 1) for c in cands))})
                anchor_bound["(dominant instance, assumption stated)"] += 1
        if chosen is None:
            unbuilt("%s on %s.%s" % (d["anchor"], N.short_view(d["view"]), d["column"]),
                    "the row carries no resolved_key and %d distinct %s key slots exist on this "
                    "view (instances %s); the map does not say which. Reported, not guessed "
                    "(BUILD_RULES 5.6)."
                    % (len(cands), d["anchor"], sorted(str(c["instance"]) for c in cands)),
                    "mapper", track=d["track"], view=d["view"], count=1)
            continue
        anchor_bound[d["anchor"]] += 1
        body, fields, track, view = d["body"], d["fields"], d["track"], d["view"]
        if track == "target":
            satellite = body.get(tgt_field["satellite"])
            attribute = body.get(tgt_field["attribute"])
        else:
            satellite = body.get(aug_field["new_satellite"]) or body.get(
                aug_field["existing_satellite"])
            attribute = body.get(aug_field["attribute"])
        if not satellite or not attribute:
            NOTES["anchor_row_without_a_satellite_attribute"] += 1
            continue
        verdict = classify_transformation(body, d["where"])
        transformations[verdict or "absent"] += 1
        if verdict == "refuse":
            derived_refused.append({
                "satellite": satellite, "attribute": attribute, "view": view,
                "source_column": d["column"], "track": track,
                "transformation": str(body.get(TRANSFORMATION_FIELD)).strip()})
            unbuilt("%s.%s from %s.%s" % (satellite, attribute, N.short_view(view), d["column"]),
                    "target.transformation declares a DERIVATION this build does not implement: "
                    "%r. Refused rather than emitted raw." % str(body.get(TRANSFORMATION_FIELD)).strip(),
                    "mapper", count=1, view=view, satellite=satellite, attribute=attribute)
            continue
        legs, leg_problem = [], None
        for j, comp in enumerate(body.get("child_key_components") or []):
            leg_name = comp.get(K.LEG_NAME_FIELD)
            rendered = K.render_child_leg(comp, view, "%s leg[%d]" % (d["where"], j),
                                          alias_of_walk=walks_for(view).alias_of)
            if rendered is None:
                leg_problem = leg_name
                continue
            for w in rendered.walks:
                walks_for(view).register(w)
            legs.append({"name": leg_name, "sql": rendered.sql, "kind": K.leg_kind(comp),
                         "constant": rendered.constant, "column": N.cdk_column(leg_name)})
        declared_multi = bool(body.get(aug_field["multi_active"])) if track == "augmentation" \
            else bool(model["sats"].get(satellite, {}).get("childkey"))
        declared_ck_name = (body.get(aug_field["child_key_declared_note"])
                            if track == "augmentation"
                            else model["sats"].get(satellite, {}).get("childkey"))
        sat_rows[(view, satellite, track)].append({
            "i": d["i"], "column": d["column"], "attribute": attribute, "slot": chosen,
            "legs": legs, "leg_problem": leg_problem, "declared_multi": declared_multi,
            "declared_ck_name": declared_ck_name, "where": d["where"],
            "legs_missing": body.get("child_key_legs_missing"),
            "stability": body.get("child_key_stability"),
            "components_gap": body.get("child_key_components_gap"),
            "redundant_of": body.get(fields["redundant_of"]),
            "key_by_anchor": True,
        })

    # ---------------------------------------------------------------- pass 3: satellites
    satellites = {}
    feeders = []
    legset_rejects = collections.Counter()
    leg_set_choices = []

    groups = collections.defaultdict(list)
    for (view, satellite, track), recs in sat_rows.items():
        groups[(satellite, track)].append((view, recs))

    for (satellite, track), view_groups in sorted(groups.items()):
        model_sat = model["sats"].get(satellite)
        if model_sat is None and track == "target":
            unbuilt(satellite, "named by a target row but absent from data_7.js", "modeller")
            continue

        # ---- the satellite's ONE child-key leg set.
        leg_sets = collections.Counter()
        for _v, recs in view_groups:
            for r in recs:
                leg_sets[tuple(sorted(l["name"] for l in r["legs"]))] += 1
        declared_name = next((r["declared_ck_name"] for _v, recs in view_groups for r in recs
                              if r["declared_ck_name"]), None)
        declared = declared_legs(declared_name)
        # Within one satellite the child key must be ONE leg set. It is the DECLARED set where any
        # row supplies it, and otherwise the MODAL set -- the one most rows carry. Taking the
        # MAXIMAL set instead looks tidier and is wrong: SAT_PARTY_BANKING declares one leg, all
        # 44 of its rows supply exactly that leg, and a maximal-set rule combined with a
        # cross-track sibling lookup deleted the entire satellite. The choice is recorded in the
        # spec census so it is visible rather than implied.
        modal = max(leg_sets, key=lambda t: (leg_sets[t], len(t))) if leg_sets else ()
        if declared and any(set(declared) == set(t) for t in leg_sets):
            row_leg_set = list(next(t for t in leg_sets if set(declared) == set(t)))
        else:
            row_leg_set = list(modal)
        if declared and set(declared) != set(row_leg_set):
            leg_set_choices.append({
                "satellite": satellite, "track": track, "declared": declared,
                "built": row_leg_set,
                "observed_sets": {(" + ".join(t) or "(none)"): n for t, n in leg_sets.items()},
                "reason": "no row supplies the declared set; the set most rows carry is built and "
                          "the missing legs are declared, NOT invented (BUILD_RULES 7.4)"})
        cdk_names = list(row_leg_set)

        multi = any(r["declared_multi"] for _v, recs in view_groups for r in recs)
        if multi and not cdk_names:
            if K.MA_WITHOUT_CDK == "unbuilt":
                unbuilt(satellite, "declared multi-active with no child key in either form; "
                                   "MA_WITHOUT_CDK='unbuilt'", "mapper", track=track)
                continue
            NOTES["multi_active_without_cdk_built_single_active"] += sum(
                len(recs) for _v, recs in view_groups)
            multi = False

        # The sibling's contract is ABSOLUTE for a satellite it already builds, ON THE SAME TRACK
        # (BUILD_RULES 7.2 / 7.7). It changes what is EMITTED; it never changes which rows are
        # built -- re-graining a satellite and then filtering its rows by the new grain deletes
        # the satellite, and a satellite that is not there passes every check that inspects
        # models which exist (BUILD_RULES 8).
        contract = N.sibling_contract(satellite, track=track)
        emitted_cdk = [N.cdk_column(c) for c in cdk_names]
        grain_divergence = None
        if contract:
            sib_multi = contract["multi_active"]
            sib_cdk = list(contract.get("src_cdk") or [])
            if sib_multi != multi or sorted(sib_cdk) != sorted(emitted_cdk):
                grain_divergence = {
                    "satellite": satellite, "track": track,
                    "sibling": {"multi_active": sib_multi, "src_cdk": sib_cdk,
                                "src_pk": contract.get("src_pk")},
                    "maximus_declared": {"multi_active": multi, "src_cdk": emitted_cdk,
                                         "child_key": declared_name},
                    "resolution": "built under the SIBLING contract; the divergence is reported, "
                                  "not resolved (BUILD_RULES 7.2)",
                    "rows_affected": sum(leg_sets.values()),
                }
            multi = sib_multi
            emitted_cdk = sib_cdk

        # BUILD_RULES 10 clause 9 -- no child key composed of collapse-trap legs ALONE. This
        # stops the SATELLITE with a reason, not the run: a build that dies here reports nothing
        # about the other 100-odd satellites (BUILD_RULES 10 clause 2).
        constant_by_leg = {}
        for _v, recs in view_groups:
            for r in recs:
                for l in r["legs"]:
                    constant_by_leg.setdefault(l["name"], l["constant"])
        try:
            K.assert_not_only_traps(satellite, cdk_names, satellite,
                                    constant_legs=constant_by_leg)
        except K.KeyGrammarError as exc:
            unbuilt(satellite,
                    "%s -- every surviving leg of the child key is a constant that discriminates "
                    "nothing, so the satellite would collapse its instances onto one row. Not "
                    "re-keyed by the build (BUILD_RULES 5.7)." % exc,
                    "mapper", track=track, declared_child_key=declared_name)
            continue

        # ---- the sibling's src_pk wins, and the feeder is re-pointed at that key (7.2)
        src_pk_repoints = []
        if contract and contract.get("src_pk"):
            want = contract["src_pk"]
            for view, recs in view_groups:
                for r in recs:
                    # Same hub, different INSTANCE of it, is not a divergence: the sibling's
                    # contract says which HUB the satellite hangs from. Treating the instance
                    # suffix as a mismatch merged three distinct addresses onto one.
                    if N.hub_key_column(r["slot"]["hub"]) == want:
                        continue
                    cands = [sl for sl in key_slots.values()
                             if sl["view"] == view
                             and N.hub_key_column(sl["hub"]) == want]
                    if not cands:
                        src_pk_unmatched.append({
                            "satellite": satellite, "track": track, "view": view,
                            "sibling_src_pk": want, "feeder_key": r["slot"]["hkey"],
                            "consequence": "the sibling keys this satellite on %s and this view "
                                           "resolves no such key; built on %s and REPORTED "
                                           "(BUILD_RULES 7.2)." % (want, r["slot"]["hkey"])})
                        continue
                    leg_sql = None
                    for leg in (r["slot"].get("legs") or []):
                        if leg.get("role") == "hub" and N.hub_key_column(leg["hub"]) == want:
                            leg_sql = leg["sql"]
                    exact = [c for c in cands if leg_sql and c["sql"] == leg_sql]
                    pick = exact[0] if exact else max(cands, key=lambda c: c.get("rows", 1))
                    src_pk_repoints.append({
                        "satellite": satellite, "track": track, "view": view,
                        "from": r["slot"]["hkey"], "to": pick["hkey"],
                        "byte_identical_to_the_link_leg": bool(exact)})
                    r["slot"] = pick
        if src_pk_repoints:
            sibling_src_pk_repoints.extend(src_pk_repoints)

        # ---- feeders
        payload_attrs = set()
        sat_feeders = []
        for view, recs in sorted(view_groups):
            kept = [r for r in recs if sorted(l["name"] for l in r["legs"]) == sorted(cdk_names)]
            dropped = [r for r in recs if r not in kept]
            if dropped:
                legset_rejects[satellite] += len(dropped)
                unbuilt("%s rows on %s" % (satellite, N.short_view(view)),
                        "row supplies child-key legs %s, the satellite's declared set is %s. "
                        "Within one satellite the child key must be ONE leg set; the missing legs "
                        "are declared, NOT invented (BUILD_RULES 7.4)."
                        % (sorted({tuple(sorted(l["name"] for l in r["legs"])) for r in dropped}),
                           sorted(cdk_names)),
                        "mapper", count=len(dropped), view=view, satellite=satellite)
            if not kept:
                continue

            # instance fan-out: distinct constant-leg tuples on this (view, satellite)
            def const_tuple(rec):
                return tuple((l["name"], l["sql"]) for l in rec["legs"] if l["constant"])

            const_tuples = sorted({const_tuple(r) for r in kept})
            has_const = any(const_tuples) and any(len(t) for t in const_tuples)
            mode = "unpivot" if (has_const and len(const_tuples) > 1) else "wide"

            branches = []
            for ct in (const_tuples if mode == "unpivot" else [const_tuples[0] if const_tuples else ()]):
                members = [r for r in kept if const_tuple(r) == ct] if mode == "unpivot" else kept
                if not members:
                    continue
                cols = collections.OrderedDict()
                for r in sorted(members, key=lambda x: x["i"]):
                    col = N.payload_column(r["attribute"])
                    cols.setdefault(col, [])
                    src = N.cast_alias(r["column"]) if r["column"] in K.columns_of(view) else None
                    if src and src not in cols[col]:
                        cols[col].append(src)
                    payload_attrs.add(col)
                legs_sql = collections.OrderedDict()
                for r in members:
                    for l in r["legs"]:
                        legs_sql.setdefault(l["column"], l["sql"])
                slot = members[0]["slot"]
                branches.append({
                    "instance_key": [list(x) for x in ct],
                    "slug": _branch_slug(ct) or "base",
                    "attributes": {c: v for c, v in cols.items()},
                    "cdk": dict(legs_sql),
                    "slot": {"hkey": slot["hkey"], "bk": slot["bk"], "nk": slot["nk"],
                             "nk_sql": slot["nk_sql"], "sql": slot["sql"], "hub": slot["hub"]},
                    "rows": len(members),
                })
            if branches:
                fd = {"view": view, "satellite": satellite, "track": track, "mode": mode,
                      "branches": branches, "hub": branches[0]["slot"]["hub"]}
                sat_feeders.append(fd)
                feeders.append(fd)

        if not sat_feeders:
            unbuilt(satellite, "no feeder survived child-key leg-set reconciliation", "mapper",
                    track=track)
            continue

        # BUILD_RULES 5.4 -- a payload attribute may not share a name with a child-key leg.
        cdk_cols = list(emitted_cdk)
        clash = sorted(set(cdk_cols) & payload_attrs)
        if clash:
            NOTES["payload_cdk_name_clash"] += len(clash)
            unbuilt("%s payload %s" % (satellite, clash),
                    "a payload attribute shares its name with a child-key leg; the payload write "
                    "would land second and overwrite the null-safe rendering (BUILD_RULES 5.4). "
                    "Kept as the child key, dropped from the payload.", "mapper",
                    satellite=satellite, count=len(clash))
            payload_attrs -= set(clash)

        satellites[(satellite, track)] = {
            "satellite": satellite, "track": track,
            "anchor": (model_sat or {}).get("parent") or sat_feeders[0]["hub"],
            "src_pk": (contract or {}).get("src_pk") or N.hub_key_column(sat_feeders[0]["hub"]),
            "multi_active": multi,
            "cdk": cdk_cols,
            "cdk_names": cdk_names,
            # BUILD_RULES 5.2: a renumbering ordinal is never a discriminator, and a child-key
            # leg needs hub-grade stability. Carried on the SATELLITE so every emitter that
            # writes it can say so in the model itself, not only in an artifact.
            "unstable_cdk": sorted(
                {"%s = %s" % (N.cdk_column(o["leg"]), ", ".join(o["columns"]))
                 for o in ordinal_legs_seen if o["satellite"] == satellite}),
            # The map's OWN routing for that instability, so the model carries the question and
            # not merely the warning (BUILD_RULES 9.8). Read from the map; the candidate key is
            # reduced to a VERIFIED source column and refused if it is not one.
            "cdk_stability": child_key_stability_for(satellite, rows),
            "payload": sorted(payload_attrs),
            "hashdiff_stage": N.stage_hashdiff_column(satellite),
            "hashdiff_sat": N.satellite_hashdiff_column(satellite),
            "sibling_built": bool(contract),
            "sibling_track": (contract or {}).get("track"),
            "grain_divergence": grain_divergence,
            "emit_name": satellite if track == "target" else N.aug_satellite_name(satellite),
            "feeders": [{"view": f["view"], "mode": f["mode"],
                         "branches": [b["slug"] for b in f["branches"]]} for f in sat_feeders],
        }

    # -------------------------------------------- pass 3b: stage column names, collisions
    # Two satellites fed from one view can want the same payload column name from different
    # source columns. The wide stage is ONE model, so the second write would silently replace the
    # first and leave the other satellite declaring an attribute it no longer feeds.
    stage_claims = collections.defaultdict(dict)      # view -> stage column -> sql
    stage_collisions = []
    NULL_SQL = "cast(null as varchar)"

    wide = []
    for f in sorted(feeders, key=lambda x: (x["view"], x["satellite"])):
        if f["mode"] != "wide" or f["track"] != "target":
            # An unpivot feeder owns its own model, and the AUGMENTED track has its own models
            # entirely -- neither shares the wide stage's column namespace, and pooling them made
            # an augmentation claim rename a standard-track column.
            for b in f["branches"]:
                b["stage_columns"] = {c: c for c in list(b["attributes"]) + list(b["cdk"])}
            continue
        sat = satellites.get((f["satellite"], f["track"]))
        full_payload = sat["payload"] if sat else sorted(f["branches"][0]["attributes"])
        for b in f["branches"]:
            b["stage_columns"] = {}
            # EVERY column the wide stage will emit for this satellite, including the ones it
            # null-pads. A null-padded column that is left out of the claim pass still takes the
            # plain name in the stage, and blocks the satellite that actually feeds it.
            for name in full_payload:
                wide.append((f, b, name, payload_sql(b["attributes"].get(name))))
            for name, sql in sorted(b["cdk"].items()):
                wide.append((f, b, name, sql))

    # LIVE claims first. A column that is cast(null) on this view must not take the plain name
    # from the satellite that actually feeds it -- that is a declaration over a dead path.
    for live_round in (True, False):
        for f, b, name, sql in wide:
            if (sql != NULL_SQL) != live_round:
                continue
            claims = stage_claims[f["view"]]
            if claims.get(name, sql) == sql:
                claims[name] = sql
                b["stage_columns"][name] = name
                continue
            alt = "%s__%s" % (name, N.sat_slug(f["satellite"]).upper())
            claims[alt] = sql
            b["stage_columns"][name] = alt
            stage_collisions.append({
                "view": f["view"], "satellite": f["satellite"], "column": name,
                "renamed_to": alt, "is_null_here": sql == NULL_SQL,
                "reason": "another satellite on this view derives this column name from a "
                          "different source; one wide stage cannot carry both under one name"})

    # ------------------------------------------ pass 3c: the hub key FORM census (BD13)
    # Re-derived from the map in hand. One source column keying one hub BOTH with a namespace
    # prefix and bare is two key spaces for one identifier -- two hub rows for one thing. The
    # profile reports this for HUB_DOCUMENT; it is measured here over EVERY hub, because a
    # finding confirmed on the instance the mapper happened to find leaves the class open
    # (BUILD_RULES 1.3).
    PREFIX_RE = re.compile(r"\A'([A-Z_]+:)'")
    COLUMN_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
    hub_forms = collections.defaultdict(lambda: {"rows": 0, "forms": set(), "prefixes":
                                                 collections.Counter(), "by_column": {}})
    for slot in key_slots.values():
        h = hub_forms[slot["hub"]]
        h["rows"] += slot["rows"]
        h["forms"].add(slot["sql"])
        for expr in slot["expressions"]:
            m = PREFIX_RE.match(str(expr).strip())
            ns = m.group(1) if m else "(NO PREFIX)"
            h["prefixes"][ns] += slot["rows"]
            for col in slot["columns"]:
                h["by_column"].setdefault(col, collections.Counter())[ns] += slot["rows"]
    split_namespace = []
    for hub, h in sorted(hub_forms.items()):
        for col, nss in sorted(h["by_column"].items()):
            if len(nss) > 1:
                split_namespace.append({
                    "hub": hub, "source_column": col, "namespaces": dict(nss),
                    "consequence": "one identifier keyed into %d key spaces: %d hub row(s) for "
                                   "one %s. Built as mapped (BD13)." % (len(nss), len(nss), col)})
    # The signal is several SINGLE-OPERAND bare keys -- distinct code systems each minting
    # members in one unprefixed space. Counting every unprefixed source column instead flags
    # HUB_LOCATION's 56 address COMPONENTS, which are the operands of ONE content hash, and the
    # real ORG_UNIT finding gets discounted along with the noise (BUILD_RULES 11.8).
    bare_sharers, bare_broad = [], []
    for hub, h in sorted(hub_forms.items()):
        bare_cols = sorted(c for c, nss in h["by_column"].items() if set(nss) == {"(NO PREFIX)"})
        solo = sorted({sl["columns"][0] for sl in key_slots.values()
                       if sl["hub"] == hub and len(sl["columns"]) == 1
                       and not PREFIX_RE.match(str(next(iter(sl["expressions"]))).strip())})
        if len(bare_cols) > 1:
            bare_broad.append({"hub": hub, "unprefixed_source_columns": len(bare_cols)})
        if len(solo) > 1:
            bare_sharers.append({
                "hub": hub, "single_operand_bare_keys": solo,
                "mapper_flagged": hub == "HUB_ORG_UNIT",
                "consequence": "%d source columns each key %s ALONE with no namespace prefix. "
                               "Whether that is ONE code system reached by several column names "
                               "-- which is exactly what a canonical hub is for -- or SEVERAL "
                               "systems that must not merge is a SOURCE question this build "
                               "cannot answer. The mapper has flagged HUB_ORG_UNIT's three "
                               "(BRANCH_CODE, LOCATION_CODE, STORED_COMPANY_CODE) as distinct "
                               "systems; the rest are reported as a census, not as a verdict. "
                               "Built as mapped either way." % (len(solo), hub)})
    hub_key_forms = {hub: {"rows": h["rows"], "distinct_rendered_forms": len(h["forms"]),
                           "prefix_namespaces": dict(h["prefixes"])}
                     for hub, h in sorted(hub_forms.items())}

    # ---------------------------------------------------------------- pass 4: the cast layer
    map_views = sorted({r[row_field["table"]] for r in rows if (r.get("target") or r.get("augmentation"))})
    on_walk, joined = set(), set()
    for view, reg in WALKS.items():
        on_walk.add(view)
        joined.add(view)
        for w in reg.order:
            joined.update(w.chain)
            on_walk.update(w.chain)
            # BD2: the parent-chain levels a named destination skips are provisioned even where
            # the emitted join does not traverse them.
            cur = view
            try:
                anc = K.ancestors(view)
            except K.KeyGrammarError:
                anc = []
            if w.destination in anc:
                for step in anc[:anc.index(w.destination) + 1]:
                    on_walk.add(step)
    cast_views = set(map_views) | (on_walk if K.CAST_COVERAGE == "parent_chain" else joined)
    # rev 4's method: every view that is a proper NAME-PREFIX of a needed view also gets a cast.
    # On a shred feed a name-prefix IS an ancestor, so these are views that have to exist anyway;
    # rev 3 added only the levels lying BETWEEN a walk's endpoints and measured 113 where rev 4
    # measures 115. 00_tables_index.json is byte-identical across both, so this is a definition
    # difference and not a bundle change.
    if K.CAST_COVERAGE == "parent_chain":
        every = K.all_views()
        for v in sorted(cast_views):
            for cand in every:
                if cand != v and v.startswith(cand + "_"):
                    cast_views.add(cand)
    cast_views = sorted(cast_views)
    provisioned = sorted(set(cast_views) - set(map_views) - joined)

    coverage = measure_coverage(rows, row_field, tgt_field, model, satellites, UNBUILT,
                                derived_refused)
    if coverage["unexplained"]:
        raise SystemExit(
            "REFUSING TO BUILD: %d mapped column(s) reach no satellite and the build has no "
            "reason for them. An unexplained coverage gap is indistinguishable from the silent "
            "drop this project was built to make impossible (BUILD_RULES 8.1)."
            % coverage["unexplained"])
    _kinds, _directive_rows = measure_transformation_contract(rows)
    profile_crosschecks = crosscheck_profile({
        "expression_slots": measure_expression_slots(rows),
        "fk_hops": K.PARSE_STATS["fk_hops"],
        "leg_unresolved_sentinel_refused": K.PARSE_STATS["leg_unresolved_sentinel_refused"],
        "hub_risk_object_namespaces": [ns.rstrip(":") for ns in
                                       namespace_counts.get("HUB_RISK_OBJECT", {})],
        "transformation_kinds": _kinds,
        "build_directive_rows": _directive_rows,
    })

    spec = {
        "lob": N.LOB,
        "prefix": N.PREFIX,
        "profile_revision": PROFILE.get("profile_revision"),
        "map_digest": _digest_files([N.MAP_PATH, N.TABLES_INDEX, N.CANON_JS, N.PROFILE_PATH]),
        "views": {v: {"short": N.short_view(v), "is_pivot": K.is_pivot(v),
                      "parent": K.parent_of(v), "columns": K.columns_of(v),
                      "has_map_rows": v in map_views,
                      "on_walk": v in on_walk,
                      "joined": v in joined,
                      "walks": walks_for(v).as_json() if v in WALKS else []}
                  for v in cast_views},
        "cast_views": cast_views,
        "map_views": map_views,
        "walk_only_views": sorted(set(cast_views) - set(map_views)),
        "provisioned_not_joined": provisioned,
        "link_slots": sorted(link_slots.values(),
                             key=lambda s: (s["view"], s["hub"], str(s["instance"]))),
        "key_slots": sorted([dict(sl, expressions=sorted(sl["expressions"]))
                             for sl in key_slots.values()],
                            key=lambda s: (s["view"], s["hub"], str(s["instance"]), s["variant"])),
        "links": sorted(links.values(), key=lambda l: l["link"]),
        "satellites": [v for _k, v in sorted(satellites.items())],
        "feeders": feeders,
        "unbuilt": UNBUILT,
        "unresolved": K.UNRESOLVED,
        "builder_decisions": K.BUILDER_DECISIONS,
        "census": {
            "rows": len(rows),
            "hub_key_rows": dict(hub_row_counts),
            "key_slots": len(key_slots),
            "content_hash_forms": dict(hash_forms),
            "content_hash_forms_by_hub": {h: dict(c) for h, c in hash_forms_by_hub.items()},
            "namespaces_by_hub": {h: dict(c) for h, c in namespace_counts.items()},
            "constant_keys": len(constant_keys),
            "keys_with_a_static_degenerate_constant": len(degenerate_outer),
            "link_legs_uncorroborated": lnk_uncorroborated,
            "link_legs_positional_unverifiable": sum(
                1 for x in lnk_uncorroborated if x.get("positional")),
            "link_leg_census": link_leg_census(leg_population, lnk_uncorroborated),
            "leg_key_divergence": leg_key_divergence,
            "hub_key_forms": hub_key_forms,
            "one_column_two_key_spaces": split_namespace,
            "hubs_with_a_shared_bare_namespace": bare_sharers,
            "hubs_with_several_unprefixed_operand_columns_NOT_a_finding": bare_broad,
            "collapse_trap_warnings": K.COLLAPSE_TRAP_WARNINGS,
            "collapse_trap_scope_reconciliation": collapse_trap_scope_reconciliation(rows),
            "pattern_proofs": probe_patterns(),
            "component_kind_spelling_census": assert_component_kind_spelling_absent(rows),
            "child_key_component_spelling_census": K.ck_spelling_census(),
            "link_legs_pure_literal": len(lnk_literal_legs),
            "legset_rejects": dict(legset_rejects),
            "link_anchored_satellite_rows": dict(link_anchored_rows),
            "sibling_src_pk_repoints": sibling_src_pk_repoints,
            "sibling_src_pk_unmatched": src_pk_unmatched,
            "stage_column_collisions": stage_collisions,
            "leg_set_choice": leg_set_choices,
            "ordinal_child_key_legs": ordinal_legs_seen,
            "ordinal_child_key_summary": ordinal_child_key_summary(ordinal_legs_seen),
            "anchor_bound_rows": dict(anchor_bound),
            "anchor_bound_by_assumption": anchor_dominant,
            "degenerate_contract": degenerate_contract,
            "keynorm_shapes": keynorm_shapes,
            "transformation_shapes": dict(transformations),
            "derived_transformations_refused": derived_refused,
            "build_directive_crosscheck": crosscheck_build_directives(derived_refused),
            "notes": dict(NOTES),
            "grammar": dict(K.PARSE_STATS),
            "profile_crosschecks": profile_crosschecks,
            "coverage": coverage,
        },
    }
    return spec


def payload_sql(sources):
    """The SQL a payload column takes in a feeder.

    A satellite attribute can be fed by more than one source column on one view -- AADHAAR_NUMBER
    and AADHAR_NO both carry 'Aadhaar Number' for the AADHAAR instance. They coalesce in the map's
    own row order; taking only the first would silently drop the other spelling, which is
    BUILD_RULES 1.3 in miniature.
    """
    if not sources:
        return "cast(null as varchar)"
    if len(sources) == 1:
        return sources[0]
    return "coalesce(%s)" % ", ".join(sources)


def _branch_slug(const_tuple):
    if not const_tuple:
        return ""
    parts = []
    for _name, sql in const_tuple:
        lit = sql.strip()
        if lit.startswith("'") and lit.endswith("'"):
            lit = lit[1:-1]
        parts.append(re.sub(r"[^A-Za-z0-9]+", "_", lit).strip("_").lower())
    slug = "_".join(p for p in parts if p)
    if len(slug) > 48:
        slug = slug[:40] + "_" + hashlib.md5(slug.encode("utf-8")).hexdigest()[:6]
    return slug


def _digest_files(paths):
    """A digest is only evidence if something computes it, over a NAMED file set (9.3 / 11.7).

    FULL LENGTH, and the algorithm is named. This returned `h.hexdigest()[:32]` under a field
    called `combined_sha256`, and BUILD_STATUS.json shipped that 32-character value -- a
    half-length digest wearing a full-length label, which verifies as a prefix and reconciles
    against nothing. CONVENTIONS.digests, status RATIFIED, forbids both truncation and an unnamed
    algorithm, and build_profile.json rev 6 routes the fix here explicitly (digest_contract_note).
    """
    h = hashlib.sha256()
    named = []
    for p in sorted(paths):
        with open(p, "rb") as fh:                       # BINARY, always
            d = hashlib.sha256(fh.read()).hexdigest()
        named.append({"file": os.path.basename(p), "sha256": d})
        h.update(d.encode())
    return {"files": named,
            "combined_sha256": h.hexdigest(),
            "combining_method": "sha256 of each file's bytes, then sha256 over those per-file "
                                "digests concatenated in sorted-basename order. Stated because a "
                                "digest without its method is not checkable (BUILD_RULES 11.7).",
            "digest_length_note": "64 hex, the full length sha256 produces. The previous emission "
                                  "truncated to 32 under this same field name."}


def assert_function_census(spec):
    """The MAP is authoritative, not KEY_FUNCTIONS.md.

    The bundle's own function table is the allowlist, and it has been stale by 1 and by 678 at
    different points in this engagement. Validating against it fails CLOSED against a map that
    has legitimately changed, so the census is taken over the map and compared to the PROFILE's,
    with any divergence reported rather than raised.
    """
    measured = spec["census"]["grammar"]
    claimed = N.PROFILE["function_census"]
    out = []
    for fn, n in sorted(claimed.items()):
        mine = measured.get("fn_" + fn)
        if mine is None:
            continue
        if mine != n:
            out.append({"function": fn, "map": mine, "profile": n})
    return out


def main():
    spec = build()
    N.ensure_dir(N.ARTIFACTS)
    N.assert_writable(SPEC_PATH)
    with open(SPEC_PATH, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(spec, fh, indent=1, sort_keys=False)

    c = spec["census"]
    print("build_mtv2_spec.py -> %s" % SPEC_PATH)
    print("  map rows                      : %d" % c["rows"])
    print("  views carrying map rows       : %d" % len(spec["map_views"]))
    print("  views needing a cast          : %d  (walk-only %d, of which provisioned-not-joined %d)"
          % (len(spec["cast_views"]), len(spec["walk_only_views"]),
             len(spec["provisioned_not_joined"])))
    print("  key slots (view,hub,instance) : %d over %d hubs/links"
          % (c["key_slots"], len(c["hub_key_rows"])))
    print("  content-hash canonicalisations: %s" % c["content_hash_forms"])
    for hub, forms in sorted(c["content_hash_forms_by_hub"].items()):
        hashed = {k: v for k, v in forms.items() if k in ("normalise", "upper_trim", "md5_other")}
        if hashed:
            print("      %-26s %s" % (hub, hashed))
    print("  degenerate contract, ASSERTED not consumed: %s"
          % c["degenerate_contract"]["degenerate_verdict"])
    print("      two branches have ZERO rows (%s); this build ships NO code path for them -- it"
          % ", ".join(c["degenerate_contract"]["branches_with_zero_rows"]))
    print("      RAISES instead, because a branch with no rows is not a tested branch.")
    print("      degenerate_value read as a value: %s  (type census %s)"
          % (c["degenerate_contract"]["degenerate_value_read_as_a_value"],
             c["degenerate_contract"]["degenerate_value_types"]))
    print("  keynorm field-set shapes (asserted, never read): %s" % c["keynorm_shapes"])
    print("  keys that are constant by construction (BD10): %d" % c["constant_keys"])
    print("  keys with a STATICALLY COMPUTABLE degenerate constant: %d"
          % c["keys_with_a_static_degenerate_constant"])
    print("      -- zero is reported as zero. Under Snowflake semantics every key expression in")
    print("         this map is NULL on an all-blank row, so the outer nullif has nothing to")
    print("         compare against. The CASE guard is what rejects; a constant predicate would")
    print("         never fire (BD9).")
    print("  namespaces per hub            :")
    for hub, ns in sorted(c["namespaces_by_hub"].items()):
        if len(ns) > 1 or sum(ns.values()) > 0:
            print("      %-28s %s" % (hub, dict(ns)))
    print("  satellites in spec            : %d (target %d, augmentation %d)"
          % (len(spec["satellites"]),
             sum(1 for s in spec["satellites"] if s["track"] == "target"),
             sum(1 for s in spec["satellites"] if s["track"] == "augmentation")))
    print("  feeders                       : %d (wide %d, unpivot %d)"
          % (len(spec["feeders"]),
             sum(1 for f in spec["feeders"] if f["mode"] == "wide"),
             sum(1 for f in spec["feeders"] if f["mode"] == "unpivot")))
    print("  links                         : %d" % len(spec["links"]))
    print("  link legs with no on-view hub key to corroborate against: %d (built, reported -- BD4)"
          % len(c["link_legs_uncorroborated"]))
    ctr = c["collapse_trap_scope_reconciliation"]
    print("  COLLAPSE-TRAP SCOPES (four published figures, one byte-identical map):")
    print("      S0 all rows (the scope this build ACTS on) : %d"
          % ctr["scope_S0_all_rows"]["count"])
    print("      A  more than one row  (profile)            : %d"
          % ctr["scope_A_more_than_one_row"]["count"])
    print("      B  more than one view (profile)            : %d   subset of A: %s"
          % (ctr["scope_B_more_than_one_view"]["count"],
             ctr["scope_B_more_than_one_view"]["subset_of_A"]))
    cks = c["component_kind_spelling_census"]
    print("  component kind field          : %r on %d of %d element(s); the literal spelling "
          "`kind` occurs %d time(s) -- COUNTED, not read from the note"
          % (cks["kind_field_declared_by_the_profile"],
             cks["occurrences_of_the_declared_field"], cks["elements"],
             cks["occurrences_of_the_literal_spelling_kind"]))
    cs = c["child_key_component_spelling_census"]
    print("  child-key component spellings : read from %s"% cs["read_from"])
    print("      accepted but never occurring: %s  (BD14 -- insurance, not evidence)"
          % cs["declared_but_never_occurring"])
    lc = c["link_leg_census"]
    print("  LINK LEG POPULATION: %s" % lc["population"])
    print("      THREE DIFFERENT QUESTIONS, THREE DIFFERENT ANSWERS:")
    for _q, _a in sorted(lc["THE_THREE_QUESTIONS"].items()):
        print("        %s: %s" % (_q, _a))
    print("  LINK LEG POPULATION (one population, four bindings):")
    print("      legs in total                     : %d over %d LNK call site(s)"
          % (lc["legs_total"], K.PARSE_STATS["lnk_call_sites"]))
    print("      named for a HUB                   : %d   <- binding checkable from the map"
          % lc["named_for_a_hub"])
    print("      named for a non-hub role (BD5)    : %d" % lc["named_for_a_non_hub_role"])
    print("           by hub                       : %s" % lc["named_for_a_hub_by_hub"])
    print("      carrying NO name token            : %d   <- bound by hub order in data_7.js;"
          % lc["no_name_token_at_all"])
    print("           of those, pure-literal legs  : %d   (degenerate, no hub to bind)"
          % lc["literal_degenerate"])
    print("      COVERAGE LIMIT: %d of %d legs (%.1f%%) name no hub, so leg-equals-hub-key is"
          % (lc["not_named_for_a_hub"], lc["legs_total"],
             100.0 * lc["not_named_for_a_hub"] / max(lc["legs_total"], 1)))
    print("      UNVERIFIABLE on them -- leg and hub key come from one renderer and agree by")
    print("      construction. Of the uncorroborated legs, %d are positional."
          % lc["uncorroborated_and_positional"])
    div = collections.Counter(x["class"] for x in c["leg_key_divergence"])
    print("  leg vs hub key divergence (BD12)  : %s" % (dict(div) or "none"))
    for x in c["leg_key_divergence"]:
        if x["class"] != "whitespace_only":
            print("      %-18s %-16s on %s" % (x["class"], x["hub"], N.short_view(x["view"])))
    print("  hub key FORMS, re-derived from the map (BD13):")
    for hub, f in sorted(c["hub_key_forms"].items()):
        if len(f["prefix_namespaces"]) > 1:
            print("      %-28s %d form(s)  namespaces %s"
                  % (hub, f["distinct_rendered_forms"], f["prefix_namespaces"]))
    print("  ONE source column in TWO key spaces: %d  (a zero here is a MEASURED zero)"
          % len(c["one_column_two_key_spaces"]))
    for x in c["one_column_two_key_spaces"]:
        print("      %-26s %-24s %s" % (x["hub"], x["source_column"], x["namespaces"]))
    print("  CENSUS -- hubs with several SINGLE-OPERAND bare keys: %d (a census, not a verdict:"
          % len(c["hubs_with_a_shared_bare_namespace"]))
    print("  one code system reached by several column names is what a canonical hub is FOR)")
    for x in c["hubs_with_a_shared_bare_namespace"]:
        print("      %-26s %-4s %s" % (x["hub"], "FLAG" if x["mapper_flagged"] else "",
                                       ", ".join(x["single_operand_bare_keys"])[:110]))
    print("      (%d hub(s) have several unprefixed OPERAND columns; those are the components of"
          % len(c["hubs_with_several_unprefixed_operand_columns_NOT_a_finding"]))
    print("       one composite key, NOT separate code systems, and are not reported as a risk)")
    print("  collapse-trap child keys BUILT with a warning (column-backed, currently single-")
    print("  valued): %d   -- refused only where every leg is a literal with no operand"
          % len(c["collapse_trap_warnings"]))
    _ord = c["ordinal_child_key_summary"]
    print("  ** RENUMBERING ORDINAL REACHING A CHILD KEY: %d distinct child-key leg(s) over %d "
          "map row(s)" % (len(_ord["distinct"]), _ord["map_row_occurrences"]))
    print("     (the ordinal class is re-derived BY SHAPE from 00_tables_index.json: %s)"
          % ", ".join(sorted(K.RENUMBERING_ORDINALS)))
    for o in _ord["distinct"]:
        print("     ** %s child key %s (column %s) is defined from %s on %s -- %d map row(s)"
              % (o["satellite"], o["leg"], o["column"], ", ".join(o["columns"]),
                 N.short_view(o["view"]), o["map_rows"]))
    if c["ordinal_child_key_legs"]:
        print("     ** An ordinal is never a discriminator and a child-key leg needs hub-grade")
        print("     ** stability (BUILD_RULES 5.2): inserting or removing one row RENUMBERS the")
        print("     ** rest and re-attaches their history. BUILT AS MAPPED (5.7) and routed")
        print("     ** BLOCKING to the MODELLER -- this build does not re-key a satellite.")
    print("  grain divergences against the sibling: %d"
          % sum(1 for s in spec["satellites"] if s["grain_divergence"]))
    print("  rows bound to an anchor key slot the map resolved elsewhere on the same view (BD11): %d"
          % sum(spec["census"]["anchor_bound_rows"].values()))
    print("  target.transformation, swept by the DECLARED transformation_kind (five contracts on")
    print("  this LOB; the value's shape is never tested -- it misclassifies): %s"
          % c["transformation_shapes"])
    print("  attributes REFUSED, on build_directive == true: %d. The DECLARED kind is read,"
          % len(c["derived_transformations_refused"]))
    print("  never the value shape: 7 rows begin 'derived:' and only these are executable;")
    print("  refusing on the prefix would withhold 4 real attributes. Emitted raw these are")
    print("  WRONG data, not missing data, and pass every gate:")
    for d in c["derived_transformations_refused"]:
        print("      %-44s <- %-24s %s"
              % ("%s.%s" % (d["satellite"], d["attribute"]), d["source_column"],
                 d["transformation"][:86]))
    cov = c["coverage"]
    print("  MAPPING COVERAGE, measured here as the gate measures it: %d of %d mapped column(s) "
          "reach a payload" % (cov["covered"], cov["total"]))
    print("      uncovered, EVERY ONE WITH A REASON: %d %s" % (len(cov["uncovered"]),
                                                               cov["by_class"]))
    for u in cov["uncovered"]:
        print("      %-34s %-26s %s" % (u["satellite"], u["column"], u["class"]))
    print("      these are written to build_artifacts/accepted_uncovered.mtv2.txt, which is the")
    print("      text vault_tools/accepted_uncovered.txt must carry for this project (8.2).")
    pc = c["profile_crosschecks"]
    print("  build_profile.json rev %s cross-checks (the five CONSUMED rev-5 keys):"
          % PROFILE.get("profile_revision"))
    for r in pc["checked"]:
        print("      [%s] %-42s mine %s / profile %s"
              % ("OK " if r["agrees"] else "DIFF", r["item"], r["mine"], r["profile"]))
    print("      still OPEN per the profile, carried to the report: %s" % ", ".join(pc["still_open"]))
    xc = c["build_directive_crosscheck"]
    print("  cross-check vs the bundle's own 20_build_directives.json: %s (mine %s, theirs %s)"
          % (xc["agreement"], xc["mine"], xc["theirs"]))
    for k in ("only_in_the_bundle", "only_in_my_sweep"):
        for row in xc.get(k) or []:
            print("      %-22s %s" % (k, row))
    print("  UNBUILT entries               : %d  (each carries a reason and a routing)"
          % len(spec["unbuilt"]))
    agg = collections.Counter(u["routing"] for u in spec["unbuilt"])
    print("      by routing: %s" % dict(agg))
    print("  UNRESOLVED (reported, never guessed): %d" % len(spec["unresolved"]))
    ur = collections.Counter(u["kind"] for u in spec["unresolved"])
    for k, v in sorted(ur.items()):
        print("      %-34s %d" % (k, v))
    print("  spec digest over %s: %s"
          % ([f["file"] for f in spec["map_digest"]["files"]],
             spec["map_digest"]["combined_sha256"]))


if __name__ == "__main__":
    main()
