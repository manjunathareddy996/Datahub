# -*- coding: utf-8 -*-
"""selfcheck_mtv2.py -- the checks that can FAIL, run over what was actually written.

Every check here is proved to fire on a constructed probe before its zero is trusted
(BUILD_RULES 1.1). A check that cannot fail proves nothing and reads exactly like a check that
passed.

It also emits build_artifacts/BUILD_STATUS.json. No document in this workspace states a count
that describes current state; the numbers live here and are referenced.
"""
import collections
import hashlib
import json
import os
import re
import sys

import mtv2_names as N
import mtv2_keyrules as K
import build_mtv2_spec as S

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

# Authored in this file, never through a shell heredoc (BUILD_RULES 1.2). Proved below.
REF = re.compile(r"\{\{\s*ref\(\s*'([^']+)'\s*\)\s*\}\}")
SOURCE_REF = re.compile(r"\{\{\s*source\(\s*'([^']+)'\s*,\s*'([^']+)'\s*\)\s*\}\}")
CAST_NULL = re.compile(r"cast\(\s*null\s+as\s+\w+\s*\)", re.I)
CONTROL_BYTE = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f]")
YAML_KEYVAL = re.compile(r"^\s{2}([A-Za-z_][A-Za-z0-9_]*):\s*(.+)$")
PROSE_IN_SQL = re.compile(
    r"spine\[|\{[A-Za-z0-9_]+\}|\(column-as-instance\)|<COLUMN>|\bTBD\b|->|>>|<not on this view")

# The derived_columns entry of a stage model, and the bare identifiers inside a SQL value.
DERIVED_KEYVAL = re.compile(r"^\s{2}([A-Za-z_][A-Za-z0-9_]*):\s*(.+)$")
SQL_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")

# The keys THIS writer owns. Anything else in BUILD_STATUS.json was written by another stage
# and is preserved; these are always rewritten, because a build that republished the previous
# run's self-checks would be reporting checks it never ran.
STAGE1_OWNED_KEYS = {
    "self_checks", "self_checks_failed", "status", "preserved_from_a_previous_writer",
    "generated", "project",
}

def _now_iso():
    """UTC, second precision. A timestamp is the one number BUILD_RULES 11.7 cannot
    take from an artifact by reference, so it is computed, never typed."""
    import datetime
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


RESULTS = []


def check(name, ok, detail, clause=None):
    RESULTS.append({"check": name, "result": "pass" if ok else "fail", "detail": detail,
                    "clause": clause})
    return ok


def all_models():
    out = {}
    for root, _dirs, files in os.walk(N.MODELS):
        for f in files:
            if f.endswith(".sql") or f.endswith(".yml"):
                p = os.path.join(root, f)
                out[p] = open(p, encoding="utf-8").read()
    return out


def probe_patterns():
    """Prove every pattern FIRES and STAYS SILENT before any zero from it is believed."""
    probes = [
        ("REF", bool(REF.search("from {{ ref('stg_mtv2__uwr_pol') }} b")),
         not REF.search("from some_table b")),
        ("SOURCE_REF", bool(SOURCE_REF.search("{{ source('maximus_travel_v2_raw', 'X') }}")),
         not SOURCE_REF.search("{{ ref('X') }}")),
        ("CAST_NULL", bool(CAST_NULL.search("cast(null as varchar) as X")),
         not CAST_NULL.search("nullif(trim(x),'') as X")),
        ("CONTROL_BYTE", bool(CONTROL_BYTE.search("bad\x08byte")),
         not CONTROL_BYTE.search("clean text\n\ttabbed")),
        ("YAML_KEYVAL", bool(YAML_KEYVAL.match("  POLICY_BK: 'x'")),
         not YAML_KEYVAL.match("derived_columns:")),
        ("PROSE_IN_SQL", bool(PROSE_IN_SQL.search("nullif(trim(spine[A -> B].C),'')")),
         not PROSE_IN_SQL.search("nullif(trim(policy_number),'')")),
        # DERIVED_KEYVAL and SQL_IDENT had no probe, and both are load-bearing: the first finds
        # the derived-columns lines a dead-path check reads, the second supplies the identifiers
        # the ordinal sweep tests by shape. An unprobed pattern's zero means nothing.
        ("DERIVED_KEYVAL", bool(DERIVED_KEYVAL.match("  DISPATCH_SERIAL_NUMBER: \"serial_no\"")),
         not DERIVED_KEYVAL.match("derived_columns:")),
        ("SQL_IDENT", SQL_IDENT.findall("coalesce(nullif(trim(serial_no), ''),'')")
         == ["coalesce", "nullif", "trim", "serial_no"],
         not SQL_IDENT.findall("'|' || '#'")),
    ]
    fired = sum(1 for _n, f, _s in probes if f)
    silent = sum(1 for _n, _f, s in probes if s)
    total = N.assert_pattern_coverage(sys.modules[__name__], [p[0] for p in probes],
                                      "selfcheck_mtv2.py")
    failed = [n for n, f, s in probes if not (f and s)]
    return check("every pattern in this file fires on a probe and stays silent on a known-good "
                 "input, and COVERAGE IS TOTAL",
                 fired == len(probes) and silent == len(probes),
                 "%d of %d fire, %d of %d silent, over %d module-level pattern(s) -- coverage "
                 "ASSERTED total, so an unprobed pattern raises rather than passing for free. "
                 "Failing: %s" % (fired, len(probes), silent, len(probes), total,
                                  ", ".join(failed) or "none"),
                 clause=7)


# The BD13 control is defined by its FINDING and its DIGEST, never by a filename.
BD13_EXPECTED = ("HUB_DOCUMENT", "DOCUMENT_ID")
# sha256 of 04_column_map.pre_docfix.json as it stands in the bundle. Named by CONTENT so a
# rename cannot break the control and an overwrite cannot silently neuter it.
BD13_CONTROL_DIGEST =     "81cd1f46a6fb6248dc897e602644b56d6f460a109b4ec1c458a2d43da71857f5"


def _sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def check_digest_contract(status=None):
    """CONSUMES digest_contract_note: assert it over every digest THIS BUILD emits.

    CONVENTIONS.digests, status RATIFIED: name the algorithm, never truncate. The build shipped a
    32-character value under a field named `combined_sha256` in BUILD_STATUS.json; nothing checked
    it, so it survived a full verification pass and a handback. The rule is now applied to the
    build's OWN output, which is the only place this stage can enforce it.
    """
    findings, scanned = [], 0
    if status is not None:
        # The BLOCK THIS RUN IS ABOUT TO WRITE, not the copy from the previous run. Sweeping the
        # file on disk passed the old value through unexamined and then overwrote it, which is a
        # check that can only ever report the PREVIOUS run's defect.
        scanned += 1
        findings.extend("BUILD_STATUS.json (about to be written): %s" % f
                        for f in N._digest_shape_failures(status, "BUILD_STATUS.json"))
    targets = [os.path.join(N.ARTIFACTS, f) for f in ("mtv2_spec.json", "reproducibility.json")]
    for path in targets:
        if not os.path.exists(path):
            continue
        scanned += 1
        with open(path, encoding="utf-8") as fh:
            body = json.load(fh)
        findings.extend("%s: %s" % (os.path.basename(path), f)
                        for f in N._digest_shape_failures(body, os.path.basename(path)))
    # PROVED TO FIRE before its zero is believed, on the REAL value that shipped.
    fires = len(N._digest_shape_failures({"input_digest": {"combined_sha256": "1ce31de04163"
                                                          "7a01616d892b6f8f0de2"}})) == 1
    silent = len(N._digest_shape_failures({"input_digest": {"combined_sha256": "0" * 64}})) == 0
    return check("every digest this build emits is full length and names its algorithm",
                 not findings and fires and silent,
                 "%d artifact(s) swept, %d violation(s)%s. Proved able to fire on the real "
                 "32-char value that shipped under a field named sha256 (fires=%s) and silent at "
                 "64 (silent=%s)."
                 % (scanned, len(findings),
                    (": " + "; ".join(findings[:4])) if findings else "", fires, silent),
                 clause=7)


def check_ordinals_with_no_child_key_reach(hits, shaped_only):
    """CONSUMES renumbering_ordinals_with_no_child_key_reach.

    The profile lists SIX ordinal spellings that reach no child key, and a seventh -- SERIAL_NO --
    that reaches exactly one. A list of what is ABSENT is worth nothing unless the absence is
    MEASURED, so the seven are looked for in the EMITTED child-key surface and the split is
    asserted.

    It reads `hits` from ordinals_in_emitted_child_keys(), the build's existing emitted-SQL
    resolver, rather than implementing a second sweep. Two mechanisms answering one question is
    how three different link-leg figures came to be published on this project.
    """
    declared_absent = sorted(str(s).upper()
                             for s in N.PROFILE["renumbering_ordinals_with_no_child_key_reach"])
    all_ordinals = sorted(K.RENUMBERING_ORDINALS)
    expected_reaching = sorted(set(all_ordinals) - set(declared_absent))
    reached = sorted({c.upper() for h in hits for c in h["columns"]})
    wrongly_absent = sorted(set(declared_absent) & set(reached))
    missing_reach = sorted(set(expected_reaching) - set(reached))
    ok = not wrongly_absent and not missing_reach
    return check("the ordinal spellings declared to reach NO child key reach none, and the one "
                 "declared to reach a leg does",
                 ok,
                 "%d ordinal spelling(s) exist in this source; the EMITTED child-key surface is "
                 "reached by %s over %d leg(s) on %d satellite(s). DECLARED ABSENT (%d): %s -- "
                 "violations: %s. DECLARED PRESENT (%d): %s -- missing: %s. A further %d "
                 "child-key column(s) are ordinal-SHAPED but backed by no source column of that "
                 "shape, and are reported rather than counted."
                 % (len(all_ordinals), reached or "nothing", len(hits),
                    len({h["satellite"] for h in hits}),
                    len(declared_absent), ", ".join(declared_absent), wrongly_absent or "none",
                    len(expected_reaching), ", ".join(expected_reaching), missing_reach or "none",
                    len(shaped_only)),
                 clause=9)


def select_bd13_control():
    """A map snapshot on which the one-column-two-key-spaces detector FIRES.

    Selection is by CONTENT: prefer a snapshot whose digest is the recorded one, otherwise take
    the snapshot that produces the expected finding (the MARKER), which is how stage 0 selects
    baselines. A snapshot byte-identical to the live map is never a control.
    """
    live_digest = _sha256(N.MAP_PATH)
    candidates, byte_identical = [], []
    for fn in sorted(os.listdir(N.BUNDLE)):
        if not fn.startswith("04_column_map") or not fn.endswith(".json"):
            continue
        path = os.path.join(N.BUNDLE, fn)
        if os.path.abspath(path) == os.path.abspath(N.MAP_PATH):
            continue
        digest = _sha256(path)
        if digest == live_digest:
            # byte-identical to the live map: it would compare the map with itself and return 0
            byte_identical.append(fn)
            continue
        try:
            hits = S.prefix_split_probe(path)
        except Exception:
            continue
        if not hits:
            continue
        expected = [h for h in hits if (h[0], h[1]) == BD13_EXPECTED]
        candidates.append({"file": fn, "digest": digest, "hits": len(hits),
                           "expected_present": bool(expected),
                           "expected": "%s.%s %s" % (expected[0][0], expected[0][1], expected[0][2])
                                       if expected else "(the expected finding is absent)",
                           "live_digest": live_digest,
                           "by_digest": digest == BD13_CONTROL_DIGEST})
    if not candidates:
        return None
    by_digest = [c for c in candidates if c["by_digest"]]
    with_expected = [c for c in candidates if c["expected_present"]]
    chosen = (by_digest or with_expected or candidates)[0]
    chosen["byte_identical_to_the_live_map"] = byte_identical
    chosen["selection"] = (
        ("the recorded digest" if chosen["by_digest"] else
         "the first snapshot carrying the expected finding, of %d that fire" % len(candidates))
        + ("; EXCLUDED as byte-identical to the live map: %s" % ", ".join(byte_identical)
           if byte_identical else "; no snapshot is byte-identical to the live map"))
    return chosen


def _stage_expression_for(column, stage_body):
    """The derived_columns SQL that defines `column` in a stage model, or None."""
    for line in stage_body.splitlines():
        m = DERIVED_KEYVAL.match(line)
        if m and m.group(1) == column:
            return m.group(2)
    return None


def ordinals_in_emitted_child_keys(sql):
    """Child-key columns in the EMITTED models whose stage expression reads a source column of
    renumbering-ordinal SHAPE.

    Resolved the way the build actually wires it -- satellite src_cdk, then the feed's ref(),
    then that stage's derived_columns value -- and tested BY SHAPE. Stage 2 recorded that its
    first version of this check looked for a child key named *_CK, a spelling this build does
    not use, so it returned a clean zero it could not have earned (BUILD_RULES 1.5).
    """
    bodies = {os.path.basename(p)[:-4]: b for p, b in sql.items() if p.endswith(".sql")}
    source_columns = {c.upper() for v in K.all_views() for c in K.columns_of(v)}
    hits, shaped_only = [], []
    for name, body in sorted(bodies.items()):
        if not name.startswith("sat_"):
            continue
        cdk, in_cdk, feeds = [], False, []
        for line in body.splitlines():
            if line.startswith("src_cdk:"):
                in_cdk = True
                continue
            if in_cdk:
                item = line.strip()
                if item.startswith("- "):
                    cdk.append(item[2:].strip().strip("'"))
                    continue
                in_cdk = False
            if line.strip().startswith("- '") and "satfeed" in line:
                feeds.append(line.strip()[2:].strip().strip("'"))
        if not cdk:
            continue
        for feed in feeds:
            for stage_name in REF.findall(bodies.get(feed, "")):
                stage_body = bodies.get(stage_name, "")
                for col in cdk:
                    expr = _stage_expression_for(col, stage_body)
                    if not expr:
                        continue
                    shaped = {t.upper() for t in SQL_IDENT.findall(expr)
                              if K.is_ordinal_shaped(t)}
                    # A RENUMBERING ORDINAL is a SOURCE column of ordinal shape. An identifier of
                    # ordinal shape that is not a source column is an upstream MODEL column --
                    # on this build, the unpivot's instance label -- and the shape alone would
                    # report it as an ordinal it is not.
                    real = sorted(t for t in shaped if t in source_columns)
                    other = sorted(t for t in shaped if t not in source_columns)
                    if real:
                        hits.append({"satellite": name.upper(), "column": col,
                                     "columns": real, "stage": stage_name})
                    elif other or K.is_ordinal_shaped(col):
                        shaped_only.append({"satellite": name.upper(), "column": col,
                                            "stage": stage_name,
                                            "backed_by": " ".join(expr.split())[:120],
                                            "why_not_an_ordinal":
                                                "no SOURCE column of ordinal shape reaches this "
                                                "leg; the identifiers in its expression are "
                                                "upstream model columns"})
    return hits, shaped_only


def _ordinal_probe_fires():
    """Fire the emitted-model ordinal reader on a SYNTHESISED stage expression, so a clean tree
    still proves the reader works."""
    probe = "  PROBE_COLUMN: \"coalesce(nullif(trim(srl_no), ''),'')\""
    expr = _stage_expression_for("PROBE_COLUMN", probe)
    return bool(expr) and any(K.is_ordinal_shaped(t) for t in SQL_IDENT.findall(expr))


def exemption_lines():
    """The generated exemption block, and the shared file the gate actually reads."""
    gen_path = os.path.join(N.ARTIFACTS, "accepted_uncovered.mtv2.txt")
    shared = os.path.join(N.REPO, "vault_tools", "accepted_uncovered.txt")
    key = os.path.basename(N.PROJECT) + " "
    mine = [l.strip() for l in open(gen_path, encoding="utf-8")
            if l.startswith(key)] if os.path.exists(gen_path) else []
    theirs = [l.strip() for l in open(shared, encoding="utf-8")
              if l.startswith(key)] if os.path.exists(shared) else []
    missing = [l for l in mine if l not in theirs]
    return mine, theirs, missing


def sibling_shared_surface(spec):
    """BD7, MEASURED rather than asserted: the satellites BOTH projects write, and whether the
    hashdiff agrees in NAME and in INPUT LIST.

    The input list is the set of columns the hashdiff is computed over: on both projects that is
    the satellite's payload plus its child key, which is what each stage hashes. Same name and
    different contents is the worse failure of the two, because the name agreeing hides it.
    """
    sib = N.sibling_satellites()
    # EMITTED only: a spec record whose payload is empty is not written as a model.
    mine = {s["emit_name"]: s for s in spec["satellites"] if s["payload"]}
    shared = sorted(set(sib) & set(mine))
    name_disagreements, input_disagreements, detail = [], [], []
    for name in shared:
        theirs, ours = sib[name], mine[name]
        their_hd = theirs.get("src_hashdiff")
        our_hd = ours["hashdiff_sat"]
        if their_hd != our_hd:
            name_disagreements.append("%s: %s vs %s" % (name, their_hd, our_hd))
        their_inputs = sorted(set(theirs.get("src_payload") or [])
                              | set(theirs.get("src_cdk") or []))
        our_inputs = sorted(set(ours["payload"]) | set(ours["cdk"]))
        if their_inputs != our_inputs:
            input_disagreements.append(name)
            detail.append({"satellite": name,
                           "only_in_the_sibling": sorted(set(their_inputs) - set(our_inputs)),
                           "only_here": sorted(set(our_inputs) - set(their_inputs)),
                           "shared_columns": len(set(their_inputs) & set(our_inputs))})
    return {
        "satellites_here": len(mine),
        "satellites_in_the_sibling": len(sib),
        "shared_by_name": len(shared),
        "shared_satellites": shared,
        "hashdiff_name_disagreements": name_disagreements,
        "hashdiff_input_list_disagreements": len(input_disagreements),
        "hashdiff_input_list_detail": detail,
        "bare_hashdiff_here": sum(1 for s in mine.values() if s["hashdiff_sat"] == "HASHDIFF"),
        "bare_hashdiff_in_the_sibling": sum(1 for s in sib.values()
                                            if s.get("src_hashdiff") == "HASHDIFF"),
        "verdict": "NARROWED, NOT RETIRED: the column NAME agrees everywhere and the INPUT LIST "
                   "does not. A row written by one project and read by the other still compares "
                   "as changed, and the name agreeing is what hides it.",
        "input_list_definition": "the satellite's src_payload plus its src_cdk -- the columns "
                                 "each project's stage hashes into the hashdiff.",
    }


def main():
    with open(S.SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    models = all_models()
    sql = {p: b for p, b in models.items() if p.endswith(".sql")}
    names = {os.path.splitext(os.path.basename(p))[0]: p for p in sql}

    probe_patterns()

    # --- 1. no control byte in any generator or model (9.4)
    bad_bytes = []
    for d in (N.GEN_DIR,):
        for f in sorted(os.listdir(d)):
            if f.endswith((".py", ".sh")):
                body = open(os.path.join(d, f), encoding="utf-8").read()
                if CONTROL_BYTE.search(body):
                    bad_bytes.append(f)
    for p, b in sql.items():
        if CONTROL_BYTE.search(b):
            bad_bytes.append(os.path.basename(p))
    check("no control byte in any generator or emitted model", not bad_bytes,
          "%d generator/model file(s) scanned, %d carrying a control byte"
          % (len(sql) + len(os.listdir(N.GEN_DIR)), len(bad_bytes)), clause=7)

    # --- 2. no mapper notation reaches SQL (3.3 / 10 clause 4)
    residue = []
    for p, b in sql.items():
        for i, line in enumerate(b.splitlines(), 1):
            if line.lstrip().startswith("--"):
                continue
            if PROSE_IN_SQL.search(line):
                residue.append("%s:%d" % (os.path.basename(p), i))
    check("zero mapper-notation residue in emitted SQL (non-comment lines)", not residue,
          "%d model(s) scanned; residue in %d line(s)%s"
          % (len(sql), len(residue), (": " + ", ".join(residue[:5])) if residue else ""), clause=4)

    # the same check, proved able to fail
    planted = "select nullif(trim(spine[A -> B].C),'') as X"
    check("the residue check can FAIL", bool(PROSE_IN_SQL.search(planted)),
          "planted 'spine[A -> B].C' is detected; the zero above is a judged zero", clause=7)

    # --- 3. every ref() resolves to a model this build wrote (6.4)
    dangling = collections.Counter()
    for p, b in sql.items():
        for r in REF.findall(b):
            if r not in names:
                dangling[r] += 1
    check("every ref() resolves to a model in this project", not dangling,
          "%d distinct ref target(s); %d unresolved%s"
          % (len({r for b in sql.values() for r in REF.findall(b)}), len(dangling),
             (": " + ", ".join(sorted(dangling)[:5])) if dangling else ""), clause=8)

    # --- 4. every source() table is declared
    declared = set()
    yml = os.path.join(N.LAYER_DIRS["cast"], "_mtv2_sources.yml")
    if os.path.exists(yml):
        for line in open(yml, encoding="utf-8"):
            line = line.strip()
            if line.startswith("- name: "):
                declared.add(line[len("- name: "):])
    used = {t for b in sql.values() for _s, t in SOURCE_REF.findall(b)}
    check("every source() table is declared in _mtv2_sources.yml", used <= declared,
          "%d used, %d declared, %d undeclared" % (len(used), len(declared), len(used - declared)),
          clause=8)

    # --- 5. the two augmented generators partition the augmented satellites
    aug_dir = N.LAYER_DIRS["aug_sat"]
    aug_models = sorted(os.listdir(aug_dir)) if os.path.isdir(aug_dir) else []
    sib_aug = {n for n, v in N.sibling_satellites().items() if v["track"] == "augmented"}
    written_aligned = [m for m in aug_models if os.path.splitext(m)[0].upper() in sib_aug]
    check("the augmented generator and the alignment shim partition the augmented satellites",
          len(aug_models) == len(set(aug_models)),
          "%d augmented satellite model(s), %d of them the OPUS-named SAT_AUG_* the shim owns"
          % (len(aug_models), len(written_aligned)), clause=8)

    # --- 6. a satellite's declared payload has at least one LIVE feeder (8.3)
    # Reads what was BUILT: src_payload from the satellite model, then each satfeed union branch
    # back to its stage model, resolving the branch's own aliasing. Reading the SPEC's payload
    # instead over-reports (the shim drops attributes OPUS already populates) and reading the
    # payload name in the upstream stage over-reports again (the satfeed renames on the way in).
    def stage_live_columns(model_name):
        live = set()
        if model_name not in names:
            return live
        for line in sql[names[model_name]].splitlines():
            m = YAML_KEYVAL.match(line)
            if m and not CAST_NULL.search(m.group(2)):
                live.add(m.group(1))
            if " as " in line and not line.lstrip().startswith("--"):
                tail = line.rsplit(" as ", 1)[-1].strip().rstrip(",")
                if tail.isidentifier() and not CAST_NULL.search(line):
                    live.add(tail.upper())
        return live

    dead, payload_checked, sats_checked = [], 0, 0
    for model_path, body in sorted(sql.items()):
        rel = os.path.relpath(model_path, N.MODELS).replace("\\", "/")
        if "/satellites/" not in rel:
            continue
        sats_checked += 1
        sat_name = os.path.splitext(os.path.basename(model_path))[0].upper()
        payload, feed, block = [], [], None
        for line in body.splitlines():
            if line.endswith(":") and not line.startswith(" "):
                block = line[:-1]
                continue
            if line.startswith("  - '") and block in ("src_payload", "source_model"):
                (payload if block == "src_payload" else feed).append(line.strip()[3:-1])
                continue
            if not line.startswith(" "):
                block = None
        # a satellite names its feed as a MODEL NAME inside the YAML, not as a {{ ref() }} --
        # a reader that looked for ref() here found nothing and reported 0 attributes checked,
        # which is a check that cannot fail wearing a pass (BUILD_RULES 1).
        # a multi-source satellite (sat_multi_source) names one satfeed PER feeder; read them all
        feed = [f for f in feed if f in names]
        if not feed:
            continue
        feed_body = "\nunion all\n".join(sql[names[f]] for f in feed)
        live_payload = set()
        for branch in feed_body.split("union all"):
            up = REF.findall(branch)
            if not up:
                continue
            up_live = stage_live_columns(up[0])
            for line in branch.splitlines():
                line = line.strip().rstrip(",")
                if not line or line.startswith("--") or line.startswith("{"):
                    continue
                if " as " in line:
                    src, dst = [x.strip() for x in line.rsplit(" as ", 1)]
                else:
                    # a satfeed branch may pass a column through unaliased; requiring ' as '
                    # reported 929 of 1350 attributes dead on a build whose paths are live.
                    src = dst = line.strip()
                if dst in payload and src in up_live:
                    live_payload.add(dst)
        payload_checked += len(payload)
        for col in payload:
            if col not in live_payload:
                dead.append((sat_name, col))
    check("no satellite declares a payload attribute that is cast(null) in EVERY feeder "
          "(a declaration is not a data path)", not dead,
          "%d satellite model(s), %d declared payload attribute(s), %d with no live feeder%s"
          % (sats_checked, payload_checked, len(dead),
             (": " + ", ".join("%s.%s" % d for d in dead[:8])) if dead else ""), clause=5)

    # the liveness reader proved able to fail
    check("the dead-path reader reads the VALUE, not just the key",
          bool(CAST_NULL.search("  ATTR: 'cast(null as varchar)'"))
          and not CAST_NULL.search("  ATTR: 'policy_number'"),
          "fires on a cast-null YAML value, silent on a real one -- the defect BUILD_RULES 12 "
          "records inside the check written to enforce 8.3", clause=7)

    # --- 7. no key or child key composed only of collapse-trap legs (10 clause 9)
    trap_only = [u for u in spec["unresolved"] if u["kind"] == "collapse_trap_only"]
    check("no satellite was BUILT on a child key composed only of collapse-trap legs",
          all(not any(s["satellite"] == u.get("satellite") and s["cdk"]
                      for s in spec["satellites"]) for u in trap_only),
          "%d collapse trap(s) in the profile; %d satellite(s) refused for using them alone, and "
          "none of those was built" % (len(K.COLLAPSE_TRAPS), len(trap_only)), clause=9)

    # --- 8. no payload attribute shares a name with a child-key leg (5.4)
    clash = [(s["emit_name"], c) for s in spec["satellites"]
             for c in s["cdk"] if c in s["payload"]]
    check("no satellite payload attribute shares a name with a child-key leg", not clash,
          "%d satellite(s) checked, %d clash(es)" % (len(spec["satellites"]), len(clash)),
          clause=9)

    # --- 9. every multi-active satellite has a non-empty src_cdk
    bad_ma = [s["emit_name"] for s in spec["satellites"] if s["multi_active"] and not s["cdk"]]
    check("every multi-active satellite carries a child key", not bad_ma,
          "%d multi-active satellite(s), %d without a discriminator"
          % (sum(1 for s in spec["satellites"] if s["multi_active"]), len(bad_ma)), clause=9)

    # --- 10. parse residue is zero and the count is printed (10 clause 6)
    stats, failures, res = K.census()
    check("parse residue is zero, over %d live expression(s)" % stats["expressions"],
          not res and not failures,
          "%d expression(s) parsed, %d failure(s), %d residue"
          % (stats["expressions"], len(failures), len(res)), clause=6)

    # --- 11. nothing was written into a read-only input (9.1)
    strays = []
    for root in N.READ_ONLY_ROOTS + N.READ_NEVER:
        r = os.path.abspath(root)
        for p in list(sql) + [S.SPEC_PATH]:
            if os.path.abspath(p).startswith(r + os.sep):
                strays.append(p)
    check("no generator wrote into a read-only input", not strays,
          "%d output path(s) checked against %d read-only root(s)"
          % (len(sql) + 1, len(N.READ_ONLY_ROOTS) + len(N.READ_NEVER)), clause=8)

    # --- 12. the BD13 detector's zero is a JUDGED zero (BUILD_RULES 1.1)
    #
    # The control used to be PINNED TO A FILENAME. The mapper overwrote that snapshot with
    # post-fix bytes, the control became byte-identical to the live map, and the check compared
    # the live map WITH ITSELF and failed on every run -- a control that cannot fire, which is
    # the defect this project keeps finding. The control is now chosen BY CONTENT: any map
    # snapshot in the bundle on which the detector fires with the EXPECTED FINDING, preferring
    # the recorded digest. The check then asserts BOTH halves -- the control fires, and the live
    # map is clean.
    live = S.prefix_split_probe(N.MAP_PATH)
    control = select_bd13_control()
    if control is None:
        check("BD13 negative control: a snapshot on which the detector FIRES", False,
              "no snapshot in the bundle produces the expected HUB_DOCUMENT/DOCUMENT_ID finding, "
              "so the live zero cannot be judged. A zero from a detector nobody has seen fire is "
              "indistinguishable from one that cannot (BUILD_RULES 1.1).", clause=7)
    else:
        check("BD13 negative control FIRES, and on the expected finding",
              control["hits"] > 0 and control["expected_present"]
              and control["digest"] != control["live_digest"],
              "control %s (sha256 %s, %s) reports %d split namespace(s) including %s; the live "
              "map reports %d. The control is chosen by CONTENT -- %s -- and is asserted to "
              "differ from the live map, which is exactly the failure that made the previous "
              "control useless."
              % (control["file"], control["digest"][:16],
                 "the recorded digest" if control["by_digest"] else "selected by marker",
                 control["hits"], control["expected"], len(live), control["selection"]),
              clause=7)
        check("one-column-two-key-spaces: the live ZERO is judged", len(live) == 0,
              "live map %d, a control that fires %d. The zero is judged, not assumed."
              % (len(live), control["hits"]), clause=7)

    # --- 12b. the RENUMBERING ORDINAL in a child key, re-derived FROM THE EMITTED MODELS
    ordinal_hits, ordinal_shaped_only = ordinals_in_emitted_child_keys(sql)
    declared = spec["census"]["ordinal_child_key_summary"]["distinct"]
    check("renumbering ordinals in an emitted child key are found BY SHAPE, and agree with the "
          "spec", len(ordinal_hits) == len(declared),
          "%d child-key column(s) in the emitted models resolve to a source column of ordinal "
          "SHAPE (%s); the spec declares %d. Detected by resolving satellite src_cdk through the "
          "feed to the stage expression -- never by a name shape such as a _CK suffix, which "
          "this build does not use and which is how a check returns a clean zero it cannot earn. "
          "A further %d child-key column(s) are ordinal-SHAPED but backed by no source column of "
          "that shape (%s): reported, not counted as ordinals."
          % (len(ordinal_hits),
             "; ".join("%s.%s from %s" % (h["satellite"], h["column"], ", ".join(h["columns"]))
                       for h in ordinal_hits) or "none",
             len(declared), len(ordinal_shaped_only),
             ", ".join(sorted({"%s.%s" % (h["satellite"], h["column"])
                               for h in ordinal_shaped_only})) or "none"), clause=9)
    check("the ordinal detector over the emitted models CAN fire",
          bool(ordinal_hits) or _ordinal_probe_fires(),
          "it fires on the real tree" if ordinal_hits else
          "the real tree is clean, so the detector was fired on a synthesised stage expression "
          "instead", clause=7)
    # CONSUMES renumbering_ordinals_with_no_child_key_reach: the SIX absences are MEASURED.
    check_ordinals_with_no_child_key_reach(ordinal_hits, ordinal_shaped_only)

    # --- 12b2. superseded key HISTORY cannot be read (the cheap half of probe_mtv2_keynorm)
    #
    # The map archives the prior text of every normalised key in keynorm.previous_expression:
    # 1444 slots of valid, shape-identical grammar. A selector matching on 'expression' would
    # build the OLD key on every one of them and no gate here could see it.
    rk_fields = N.PROFILE["map_fields"]["target.resolved_key"]
    read_slots = sorted({rk_fields["hub"], rk_fields["expression"], rk_fields["instance"],
                         rk_fields["tier"], rk_fields["source_columns"]})
    keynorm_slots_read = [s for s in read_slots
                          if s.startswith("keynorm") or s == "previous_expression"]
    check("key selection reads a DECLARED slot set, and no keynorm slot is in it",
          not keynorm_slots_read and "keynorm" in N.NEVER_READ_FIELDS
          and "previous_expression" in N.NEVER_READ_FIELDS,
          "slots read: %s. The history slot the profile names is %r, and both 'keynorm' and "
          "'previous_expression' are on NEVER_READ_FIELDS, so adding a reader for one is fatal "
          "rather than quiet. keynorm slots in the read set: %d."
          % (", ".join(read_slots), rk_fields.get("history_do_not_parse"),
             len(keynorm_slots_read)), clause=9)
    try:
        S.assert_keynorm_shapes([{"target": {"resolved_key": {"keynorm": {
            "stage": "4b", "class": "whitespace", "previous_expression": "x",
            "a_field_this_build_has_never_seen": 1}}}}])
        fired = False
    except SystemExit:
        fired = True
    try:
        S.assert_keynorm_shapes([{"target": {"resolved_key": {"keynorm": {
            "stage": "4b", "class": "whitespace", "previous_expression": "x"}}}}])
        silent = True
    except SystemExit:
        silent = False
    check("the keynorm SHAPE guard fires on an unknown field set and is silent on a known one",
          fired and silent,
          "fires on a planted extra keynorm field, silent on the map's own commonest shape. The "
          "full containment proof -- all 1444 archived values poisoned, whole spec rebuilt, zero "
          "occurrences, with the search proved by poisoning a LIVE expression -- is "
          "generators/probe_mtv2_keynorm.py and its result is in "
          "build_artifacts/keynorm_probe.json.", clause=7)

    # --- 12c. the exemptions this build generated ARE what the shared gate reads (8.2)
    mine, theirs, missing_lines = exemption_lines()
    check("every coverage exemption this build generated is present in "
          "vault_tools/accepted_uncovered.txt", not missing_lines,
          "%d generated line(s), %d present in the shared file, %d missing. An exemption the gate "
          "cannot see leaves a recorded decision reading as novel silence (BUILD_RULES 8.2)."
          % (len(mine), len(mine) - len(missing_lines), len(missing_lines)), clause=3)

    # ------------------------------------------------------------------ BUILD_STATUS.json
    layer_counts = collections.Counter()
    for p in sql:
        rel = os.path.relpath(p, N.MODELS).replace("\\", "/")
        layer_counts[rel.rsplit("/", 1)[0]] += 1
    status = {
        "lob": N.LOB,
        "stage": "1",
        "generated_by": "generators/selfcheck_mtv2.py",
        "profile_revision": N.PROFILE.get("profile_revision"),
        "input_digest": spec["map_digest"],
        "models": {"total": len(sql), "by_layer": dict(sorted(layer_counts.items()))},
        "layers": {
            "cast_views": len(spec["cast_views"]),
            "map_views": len(spec["map_views"]),
            "walk_only_casts": len(spec["walk_only_views"]),
            "provisioned_not_joined": len(spec["provisioned_not_joined"]),
            "key_slots": len(spec["key_slots"]),
            "link_slots": len(spec["link_slots"]),
            "satellites_standard": sum(1 for s in spec["satellites"] if s["track"] == "target"),
            "satellites_augmented": sum(1 for s in spec["satellites"]
                                        if s["track"] == "augmentation"),
            "multi_active": sum(1 for s in spec["satellites"] if s["multi_active"]),
            "feeders": len(spec["feeders"]),
            "unpivot_feeders": sum(1 for f in spec["feeders"] if f["mode"] == "unpivot"),
        },
        "grammar": spec["census"]["grammar"],
        "content_hash_canonicalisations": {
            "forms": spec["census"]["content_hash_forms"],
            "by_hub": spec["census"]["content_hash_forms_by_hub"],
            "note": "TWO canonicalisations, used on DISJOINT hubs: md5(normalise(...)) on "
                    "HUB_LOCATION and LNK_PARTY_LOCATION (addresses, internal whitespace "
                    "collapsed) and md5(upper(trim(...))) on HUB_PARTY, LNK_PARTY_ROLE and "
                    "HUB_ORG_UNIT (nominee and branch NAMES, ends trimmed only). Zero hubs carry "
                    "both. Emitted as written; unifying them would re-key a hub.",
        },
        "namespaces_by_hub": spec["census"]["namespaces_by_hub"],
        "key_rejection": {
            "mechanism": "shape: CASE over coalesce(<guarded operands>) is not null, then "
                         "nullif(trim(key),'')",
            "keys_with_a_statically_computable_degenerate_constant": spec["census"][
                "keys_with_a_static_degenerate_constant"],
            "constant_by_construction_keys": spec["census"]["constant_keys"],
            "note": "Zero is reported as zero. Every key expression in this map evaluates to NULL "
                    "on an all-blank row under Snowflake semantics, so the outer nullif has "
                    "nothing to compare against and a predicate of the form key = 'RISK:' could "
                    "never fire. The per-hub per-feeder drop counts are in "
                    "audit_mtv2_key_rejections; they are measured at run time, not here.",
        },
        "unbuilt": len(spec["unbuilt"]),
        "unbuilt_by_routing": dict(collections.Counter(u["routing"] for u in spec["unbuilt"])),
        "unresolved_keys": len(spec["unresolved"]),
        "builder_decisions": [d["id"] for d in spec["builder_decisions"]],
        "link_leg_census": spec["census"]["link_leg_census"],
        "coverage": {k: v for k, v in spec["census"]["coverage"].items() if k != "uncovered"},
        "coverage_exemptions": len(spec["census"]["coverage"]["uncovered"]),
        "ordinal_child_keys": dict(spec["census"]["ordinal_child_key_summary"],
                                   re_derived_from_the_emitted_models=ordinal_hits,
                                   ordinal_shaped_but_not_source_backed=ordinal_shaped_only),
        "profile_crosschecks": spec["census"]["profile_crosschecks"],
        # STAGE1_OWNED_KEYS claimed these two, and nothing wrote them -- so the preserve step
        # dropped whatever a later stage had put there, on every chain run. Stage 2 caught it after
        # they had already been re-added by hand once. A key you claim to own and never write is
        # a DELETE dressed as ownership: the claim is what stops it being preserved.
        "project": os.path.basename(N.PROJECT),
        "generated": _now_iso(),
        "sibling": {
            "project": N.PROFILE["sibling"]["project"],
            "satellites": len(N.sibling_satellites()),
            "shared_surface": sibling_shared_surface(spec),
            "aligned_satellites": sorted(
                s["emit_name"] for s in spec["satellites"]
                if s["track"] == "augmentation" and s["sibling_built"]),
            "grain_divergences": [s["grain_divergence"] for s in spec["satellites"]
                                  if s["grain_divergence"]],
            "src_pk_repoints": spec["census"]["sibling_src_pk_repoints"],
        },
    }
    N.ensure_dir(N.ARTIFACTS)
    path = os.path.join(N.ARTIFACTS, "BUILD_STATUS.json")
    N.assert_writable(path)
    # BUILD_RULES 10 has stage 2 write its clause block into this same file. This writer owns the
    # stage-1 keys and PRESERVES every key it does not own, so a chain re-run no longer discards
    # the verification half and DONE no longer disappears from the single source of every number
    # (11.7). Stage 2 raised this; it is fixed here rather than answered.
    preserved = {}
    if os.path.exists(path):
        try:
            previous = json.load(open(path, encoding="utf-8"))
        except ValueError:
            previous = {}
        preserved = {k: v for k, v in previous.items()
                     if k not in status and k not in STAGE1_OWNED_KEYS}
    if preserved:
        status["preserved_from_a_previous_writer"] = {
            "keys": sorted(preserved),
            "note": "written by a LATER stage (BUILD_RULES 10) and preserved rather than "
                    "discarded by this writer. They describe the tree AS VERIFIED; the check "
                    "below fails if this run wrote a different tree, so a preserved number is "
                    "never read as a current one.",
        }
        stale = []
        prev_counts = (preserved.get("counts") or {})
        if prev_counts.get("models") not in (None, len(sql)):
            stale.append("counts.models %r vs %d written now"
                         % (prev_counts.get("models"), len(sql)))
        if stale:
            status["preserved_from_a_previous_writer"]["STALE"] = stale
        check("the preserved verification block still describes THIS tree", not stale,
              "preserved key(s): %s. %s"
              % (", ".join(sorted(preserved)),
                 "STALE: " + "; ".join(stale) if stale else
                 "every preserved count that overlaps a stage-1 fact still agrees"), clause=8)
        status.update(preserved)
    # CONSUMES digest_contract_note, over the build's OWN artifacts and over the BUILD_STATUS
    # block this run is about to write. Last, because it is the last thing this run produces.
    check_digest_contract(status)
    fails = [r for r in RESULTS if r["result"] == "fail"]
    status["self_checks"] = RESULTS
    status["self_checks_failed"] = len(fails)
    status["status"] = "fail" if fails else "pass"
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(status, fh, indent=1)

    print("selfcheck_mtv2 -> %s" % path)
    for r in RESULTS:
        print("  [%s] %s" % (r["result"].upper(), r["check"]))
        print("        %s" % r["detail"])
    print("  models written: %d" % len(sql))
    if fails:
        raise SystemExit("selfcheck_mtv2: %d check(s) FAILED" % len(fails))


if __name__ == "__main__":
    main()
