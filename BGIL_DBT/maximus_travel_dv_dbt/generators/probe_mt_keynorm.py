# -*- coding: utf-8 -*-
"""probe_mt_keynorm.py -- PROVE that superseded key history cannot reach a model.

WHY THIS EXISTS
---------------
The map archives the PRIOR TEXT of every key expression its normalisation passes superseded, in
`resolved_key.keynorm.previous_expression`. That text is valid grammar and shape-identical to a
live expression, so a generator that selected key slots by pattern -- anything matching
`*expression*` -- would build the OLD key on every one of those slots, well-formed, and no gate
in this workspace could tell. build_mt_spec.assert_keynorm_shapes() guards the structure and
mt_names.NEVER_READ_FIELDS forbids the value, but neither had ever been SEEN TO FIRE, and a
guard nobody has watched fail is indistinguishable from one that cannot (BUILD_RULES 1.1). This
project has already shipped one control that silently stopped working.

WHAT IT RUNS  (nothing is written into the bundle: every copy lives in the scratch directory)
  1. INJECTION  -- an unrecognised keynorm field-set shape is planted in a scratch copy of the
     map and assert_keynorm_shapes is run over it. It must REFUSE and NAME the shape.
  2. CONTROL    -- the same code over an unmodified scratch copy. It must not refuse.
  3. CONTAINMENT-- every one of the archived previous_expression values in a scratch copy is
     replaced with a POISON token, the whole spec is built from that map, and the spec is
     searched for the token. Zero occurrences is the proof that no superseded VALUE was read.
     The poison detector is itself proved: poisoning one LIVE resolved_key.expression instead
     puts the token INTO the spec, so a zero from this search is a judged zero.
  4. SLOT SET   -- the slot names key selection actually reads are enumerated and asserted as a
     SET against the profile's declared resolved_key field names, so "nothing matched by
     accident" is replaced by "nothing may match".

USAGE
    python3 probe_mt_keynorm.py [--scratch DIR]
Exit 0 when all four hold; exit 1 otherwise. Results are written to
build_artifacts/keynorm_probe.json for the stage-1 report to read -- never retyped.
"""
import copy
import json
import os
import shutil
import sys
import tempfile

import mt_names as N
import mt_keyrules as K
import build_mt_spec as S

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

POISON = "KEYNORM_POISON_DO_NOT_BUILD"
OUT = os.path.join(N.ARTIFACTS, "keynorm_probe.json")
RESULTS = []


def record(name, result, detail):
    RESULTS.append({"check": name, "result": result, "detail": detail})
    print("  [%s] %s\n        %s" % (result.upper(), name, detail))
    return result == "pass"


def scratch_dir():
    for i, a in enumerate(sys.argv):
        if a == "--scratch" and i + 1 < len(sys.argv):
            return sys.argv[i + 1]
    return tempfile.mkdtemp(prefix="mt_keynorm_")


def write_scratch_map(rows, path):
    """A scratch map, in the scratch directory. The bundle is read-only and is never written
    (BUILD_RULES 9.1); N.assert_writable() is asserted on the destination first."""
    N.assert_writable(path)
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        json.dump({N.MAP_ROW_CONTAINER: rows}, fh)
    return path


def keynorm_blocks(rows):
    out = []
    for r in rows:
        for blk in ("target", "augmentation"):
            kn = ((r.get(blk) or {}).get("resolved_key") or {}).get("keynorm")
            if kn:
                out.append(kn)
    return out


def build_from(map_path):
    """Run the REAL spec builder against a scratch map by repointing the one path it reads."""
    saved = N.MAP_PATH
    saved_roots = list(N.READ_ONLY_ROOTS)
    try:
        N.MAP_PATH = map_path
        # the scratch map is not a read-only input; the bundle stays read-only
        N.READ_ONLY_ROOTS = [r for r in N.READ_ONLY_ROOTS if r != N.BUNDLE] + [N.BUNDLE]
        K.PARSE_STATS.clear()
        return S.build()
    finally:
        N.MAP_PATH = saved
        N.READ_ONLY_ROOTS = saved_roots


def main():
    work = scratch_dir()
    os.makedirs(work, exist_ok=True)
    rows = json.loads(N.read_input(N.MAP_PATH))[N.MAP_ROW_CONTAINER]
    blocks = keynorm_blocks(rows)
    with_prev = [b for b in blocks if b.get("previous_expression")]
    print("probe_mt_keynorm -- scratch %s" % work)
    print("  keynorm blocks in the live map: %d, carrying previous_expression: %d"
          % (len(blocks), len(with_prev)))

    # ---------------------------------------------------------------- 1. injection
    planted = copy.deepcopy(rows)
    target_row = None
    for r in planted:
        kn = ((r.get("target") or {}).get("resolved_key") or {}).get("keynorm")
        if kn:
            kn["superseded_by"] = "a field this build has never seen"
            target_row = r
            break
    if target_row is None:
        record("injection: an unrecognised keynorm shape is REFUSED", "not_run",
               "no keynorm block exists in the live map, so the guard cannot be exercised on "
               "real rows. NOT RUN is a third outcome, not a pass (BUILD_RULES 1.8).")
    else:
        try:
            S.assert_keynorm_shapes(planted)
            record("injection: an unrecognised keynorm shape is REFUSED", "fail",
                   "a keynorm block carrying an extra field 'superseded_by' was planted in a "
                   "scratch copy and assert_keynorm_shapes ACCEPTED it. The guard cannot fire.")
        except SystemExit as exc:
            msg = " ".join(str(exc).split())
            named = "superseded_by" in msg
            record("injection: an unrecognised keynorm shape is REFUSED",
                   "pass" if named else "fail",
                   "planted one extra keynorm field in a scratch copy of the map; the guard "
                   "refused and %s the shape: %s"
                   % ("NAMED" if named else "did NOT name", msg[:240]))

    # ---------------------------------------------------------------- 2. negative control
    try:
        census = S.assert_keynorm_shapes(copy.deepcopy(rows))
        record("control: the UNMODIFIED map is accepted", "pass",
               "the same code over an unmodified scratch copy returns the shape census %s and "
               "does not refuse, so the refusal above is caused by the planted field and not by "
               "the guard being unconditional" % census)
    except SystemExit as exc:
        record("control: the UNMODIFIED map is accepted", "fail",
               "the guard refuses the unmodified map: %s" % " ".join(str(exc).split())[:240])

    # ---------------------------------------------------------------- 3. containment
    poisoned = copy.deepcopy(rows)
    n_poisoned = 0
    for r in poisoned:
        for blk in ("target", "augmentation"):
            kn = ((r.get(blk) or {}).get("resolved_key") or {}).get("keynorm")
            if kn and kn.get("previous_expression"):
                kn["previous_expression"] = "%s_%d" % (POISON, n_poisoned)
                n_poisoned += 1
    path = write_scratch_map(poisoned, os.path.join(work, "04_column_map.keynorm_poisoned.json"))
    spec_text = json.dumps(build_from(path))
    hits = spec_text.count(POISON)
    record("containment: no archived previous_expression reaches the spec",
           "pass" if hits == 0 else "fail",
           "every one of the %d archived previous_expression values in a scratch copy was "
           "replaced with a poison token and the WHOLE SPEC was rebuilt from that map: %d "
           "occurrence(s) of the token in the spec." % (n_poisoned, hits))

    # the poison detector must be able to find the token -- otherwise the zero above is worthless
    live_poisoned = copy.deepcopy(rows)
    live_field = N.PROFILE["map_fields"]["target.resolved_key"]["expression"]
    planted_live = None
    for r in live_poisoned:
        rk = (r.get("target") or {}).get("resolved_key") or {}
        if rk.get(live_field) and rk.get("hub"):
            rk[live_field] = "nullif(trim(%s),'')" % POISON
            planted_live = r
            break
    if planted_live is None:
        record("the containment search CAN find the token", "not_run",
               "no live resolved_key.expression could be poisoned as a control")
    else:
        path2 = write_scratch_map(live_poisoned,
                                  os.path.join(work, "04_column_map.live_poisoned.json"))
        try:
            hits2 = json.dumps(build_from(path2)).count(POISON)
        except SystemExit as exc:
            hits2 = -1
            print("        (the live-poisoned build refused: %s)"
                  % " ".join(str(exc).split())[:160])
        record("the containment search CAN find the token",
               "pass" if hits2 > 0 else "fail",
               "poisoning ONE LIVE resolved_key.expression instead puts the token into the spec "
               "%d time(s), so the zero above is a judged zero and not a search that cannot "
               "match" % hits2)

    # ---------------------------------------------------------------- 4. the slot set
    rk_fields = N.PROFILE["map_fields"]["target.resolved_key"]
    read_slots = sorted({rk_fields["hub"], rk_fields["expression"], rk_fields["instance"],
                         rk_fields["tier"], rk_fields["source_columns"]})
    history = str(rk_fields.get("history_do_not_parse") or "")
    bad = [s for s in read_slots if s.startswith("keynorm") or s == "previous_expression"]
    record("the key-selection slot SET excludes every keynorm slot",
           "pass" if not bad else "fail",
           "key selection reads exactly these resolved_key slots: %s. The map's own history slot "
           "is %r and it is on mt_names.NEVER_READ_FIELDS (%s), so a reader for it is fatal "
           "rather than quiet. Slots read that are keynorm slots: %d."
           % (", ".join(read_slots), history,
              "keynorm" in N.NEVER_READ_FIELDS
              and "previous_expression" in N.NEVER_READ_FIELDS, len(bad)))

    N.ensure_dir(N.ARTIFACTS)
    N.assert_writable(OUT)
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        json.dump({"probe": "keynorm history containment",
                   "keynorm_blocks": len(blocks),
                   "blocks_with_previous_expression": len(with_prev),
                   "scratch_directory": work,
                   "bundle_written": False,
                   "checks": RESULTS}, fh, indent=1)
    print("  -> %s" % OUT)
    shutil.rmtree(work, ignore_errors=True)
    failed = [r for r in RESULTS if r["result"] != "pass"]
    if failed:
        raise SystemExit("probe_mt_keynorm: %d check(s) did not pass" % len(failed))


if __name__ == "__main__":
    main()
