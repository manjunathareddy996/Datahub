# -*- coding: utf-8 -*-
"""verify_mtv2_gates.py -- run every gate, and PROVE each one can fail, by injection.

WHY THIS IS A FILE AND NOT A SESSION
------------------------------------
Stage 2 recorded that its re-verification "initially read `tail`'s exit status instead of the
gate's". Every gate here is run with subprocess and ITS OWN returncode is the verdict; nothing is
piped. And every verdict is proved by INJECTION before its zero is believed, because a gate that
cannot fail and a clean tree produce the same output.

FOUR OUTCOMES, NEVER COLLAPSED TO TWO (BUILD_RULES 1.8)
    PASS             ran and satisfied
    FAIL             ran and did not satisfy
    NOT_RUN          deliberately not attempted, with a reason
    DID_NOT_COMPLETE attempted and did not finish, so no verdict exists

THE RESTORE MECHANISM IS THE CHAIN. Models are generated, so re-running run_all.sh puts the tree
back, and the BINARY tree digest proves it did. A text-mode restore once rewrote 19 line endings
on this project and the accompanying "byte-identical" assertion was itself text-mode, so it could
not see the damage; every byte comparison in this file opens "rb".

PROBE DEFECTS ARE RECORDED, NOT HIDDEN. Two injections in this file's first run did not fire, and
both were the probe, not the gate: one was aimed at `source_model:` when check_internal reads
ref() calls, and one used the word `number`, which is on check_prose_shape's SQL-keyword list. A
silence is never accepted as a pass.

USAGE
    python3 verify_mtv2_gates.py          -> build_artifacts/gate_verification.json
Exit 0 only when every gate passes on the clean tree, every injection fires, and the tree is
byte-identical to the baseline afterwards.
"""
import hashlib
import json
import os
import subprocess
import sys

import mtv2_names as N

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

TOOLS = os.path.join(N.REPO, "vault_tools")
OUT = os.path.join(N.ARTIFACTS, "gate_verification.json")
PROJECT_ARG = os.path.basename(N.PROJECT)

# Each gate with the arguments it actually takes. check_vault_alignment takes THREE; invoking it
# with one raises a TypeError and exits 1, which is indistinguishable from a FAIL unless the
# output is read. It is spelled out here so that can never happen again.
GATES = {
    "check_internal": [PROJECT_ARG],
    "check_patterns": [PROJECT_ARG],
    "check_prose_shape": [PROJECT_ARG],
    "check_prose_counts": [PROJECT_ARG],
    "check_vault_alignment": [PROJECT_ARG,
                              os.path.basename(N.SIBLING),
                              os.path.relpath(N.MAP_PATH, N.REPO).replace("\\", "/")],
}

RESULTS = []


def record(check, result, detail, **extra):
    rec = {"check": check, "result": result, "detail": detail}
    rec.update(extra)
    RESULTS.append(rec)
    print("  [%s] %s\n        %s" % (result, check, detail), flush=True)
    return rec


def run_gate(name):
    """(exit_code, output). NEVER through a pipe: this returncode is the GATE's."""
    proc = subprocess.run([sys.executable, os.path.join(TOOLS, name + ".py")] + GATES[name],
                          cwd=N.REPO, capture_output=True, text=True, encoding="utf-8",
                          errors="replace")
    return proc.returncode, (proc.stdout or "") + (proc.stderr or "")


def file_digest(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:                    # BINARY, always
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def tree_digest():
    files = {}
    for root, _dirs, fs in os.walk(N.MODELS):
        for f in sorted(fs):
            p = os.path.join(root, f)
            files[os.path.relpath(p, N.PROJECT).replace("\\", "/")] = p
    for extra in ("dbt_project.yml", "packages.yml"):
        p = os.path.join(N.PROJECT, extra)
        if os.path.exists(p):
            files[extra] = p
    per = {rel: file_digest(p) for rel, p in sorted(files.items())}
    joined = "\n".join("%s %s" % kv for kv in sorted(per.items()))
    return hashlib.sha256(joined.encode("utf-8")).hexdigest(), len(per)


def rebuild():
    return subprocess.run(["sh", os.path.join(N.GEN_DIR, "run_all.sh")], cwd=N.GEN_DIR,
                          capture_output=True, text=True, encoding="utf-8",
                          errors="replace").returncode


def inject(relpath, old, new, marker):
    """Plant `new` in place of `old`, and ASSERT IT LANDED before any verdict is taken.

    A replace that matches nothing leaves the tree clean and the gate green, and that green is
    then recorded as proof. It has happened on this project; the assertion is what stops it.
    """
    path = os.path.join(N.PROJECT, relpath)
    with open(path, "rb") as fh:
        raw = fh.read()
    if raw.count(old) < 1:
        raise SystemExit("INJECTION ANCHOR ABSENT in %s: %r. The probe would have proved nothing."
                         % (relpath, old[:60]))
    with open(path, "wb") as fh:
        fh.write(raw.replace(old, new, 1))
    with open(path, "rb") as fh:
        if marker not in fh.read():
            raise SystemExit("INJECTION DID NOT LAND in %s. A replace matching nothing yields a "
                             "vacuous green (BUILD_RULES 1.1)." % relpath)


def restore_and_assert(baseline, label):
    code = rebuild()
    digest, n = tree_digest()
    return record("tree restored by the CHAIN after %s" % label,
                  "PASS" if (code == 0 and digest == baseline) else "FAIL",
                  "run_all.sh exit %d; %d file(s) -> %s. Models are GENERATED, so the chain is "
                  "the restore mechanism and the BINARY tree digest is the proof."
                  % (code, n, digest))


def main():
    print("verify_mtv2_gates -- every gate run directly, every gate proved to fail")
    baseline, base_n = tree_digest()
    print("  baseline tree: %s over %d file(s)" % (baseline, base_n))

    # ---- the bundle, BEFORE
    before = {os.path.basename(N.MAP_PATH): file_digest(N.MAP_PATH)}

    # ---- clean verdicts
    clean = {}
    for g in sorted(GATES):
        code, out = run_gate(g)
        clean[g] = code
        tail = " / ".join(l.strip() for l in out.splitlines() if l.strip())[-200:]
        record("%s on the clean tree" % g, "PASS" if code == 0 else "FAIL",
               "EXIT %d, read from the GATE's own returncode -- never from a pipe. %s"
               % (code, tail),
               gate=g, exit_code=code, argv=GATES[g])

    # ---- injections, each aimed at the surface the gate actually reads
    FEED = ("models/automate_dv/standard/satfeed/"
            "satfeed_mtv2_sat_assessment_header.sql")
    SAT = "models/automate_dv/standard/satellites/sat_assessment_header.sql"
    STAGE = "models/automate_dv/standard/staging/stg2_mtv2__clm_clmd.sql"
    README = os.path.join(N.GEN_DIR, "README.md")

    # 1. check_internal -- a dangling ref(), in the FEED, which is where ref() calls live
    inject(FEED, b"ref('stg2_mtv2__uwr_pol_tele')", b"ref('stg2_mtv2__PLANTED_DANGLING')",
           b"PLANTED_DANGLING")
    code, out = run_gate("check_internal")
    record("check_internal FAILS on a dangling ref()",
           "PASS" if (code == 1 and "PLANTED_DANGLING" in out) else "FAIL",
           "EXIT %d and the gate NAMES the edge: %s. A first attempt aimed at a `source_model:` "
           "entry did NOT fire -- see the scope-limit finding below; that was the probe being "
           "wrong about what the gate reads, and it is recorded rather than retried silently."
           % (code, " ".join(l.strip() for l in out.splitlines() if "PLANTED" in l)[:140]))
    restore_and_assert(baseline, "the dangling-ref injection")

    # 1b. the SCOPE LIMIT that first miss exposed, measured rather than asserted
    inject(SAT, b"  - 'satfeed_mtv2_sat_assessment_header'",
           b"  - 'satfeed_mtv2_PLANTED_NONEXISTENT'", b"PLANTED_NONEXISTENT")
    code, out = run_gate("check_internal")
    no_ref_sats = 0
    for root, _d, fs in os.walk(os.path.join(N.MODELS, "automate_dv")):
        if os.sep + "satellites" not in root:
            continue
        for f in fs:
            if not f.endswith(".sql"):
                continue
            body = N.read_input(os.path.join(root, f))
            if "ref('" not in body and "source_model:" in body:
                no_ref_sats += 1
    record("GATE SCOPE LIMIT: check_internal cannot see a source_model entry naming a model that "
           "does not exist",
           "FAIL" if code == 0 else "PASS",
           "EXIT %d -- SILENT on a planted nonexistent source_model entry. The gate skips a "
           "source_model name absent from its file set, commenting 'a dangling ref, already "
           "reported above', but the ref() half sees only ref() CALLS and %d satellite model(s) "
           "here carry a source_model list and NO ref() call at all. MEASURED by injection, not "
           "inferred. vault_tools is NOT edited and no exemption is written to work around it: "
           "the shared gate is read by other builds." % (code, no_ref_sats),
           population="%d satellite models with a source_model list and no ref() call"
                      % no_ref_sats)
    restore_and_assert(baseline, "the source_model scope probe")

    # 2. check_prose_shape -- a two-word token INSIDE a render function's arguments
    inject(STAGE, b"nullif(trim(claimno), '')", b"nullif(trim(claim reference planted), '')",
           b"claim reference planted")
    code, out = run_gate("check_prose_shape")
    record("check_prose_shape FAILS on a two-word token in an identifier position",
           "PASS" if (code == 1 and "claim reference" in out) else "FAIL",
           "EXIT %d and the gate names file, line and phrase. TWO probe defects preceded this "
           "one: the first put the space in a YAML scalar, which the gate does not scan, and the "
           "second used the word `number`, which is on the gate's SQL-keyword list precisely "
           "because SQL legitimately puts a type name beside an identifier. Neither silence was "
           "accepted as a pass (BUILD_RULES 1.1)." % code)
    restore_and_assert(baseline, "the prose-shape injection")

    # 3. check_vault_alignment -- a payload column that is not the canonical rendering
    inject(SAT, b"  - 'ASSESSMENT_STATUS'", b"  - 'ASSESSMENT_STATUS_PLANTED'",
           b"ASSESSMENT_STATUS_PLANTED")
    code, out = run_gate("check_vault_alignment")
    record("check_vault_alignment FAILS on a payload column that is not the canonical rendering",
           "PASS" if code == 1 else "FAIL",
           "EXIT %d. %s" % (code, " / ".join(l.strip() for l in out.splitlines()
                                             if l.strip().startswith("FAIL"))[:180]))
    restore_and_assert(baseline, "the alignment injection")

    # 4. check_prose_counts -- an unsourced count under a NEW heading. Under an EXISTING heading
    #    it inherits that heading's provenance flag and stays silent; stage 2 recorded accepting
    #    that silence once, and it was not a proof.
    with open(README, "rb") as fh:
        readme_raw = fh.read()
    with open(README, "wb") as fh:
        fh.write(readme_raw + b"\n## Planted heading for the prose-counts injection\n\n"
                              b"There are 4242 satellites in this build.\n")
    code, out = run_gate("check_prose_counts")
    with open(README, "wb") as fh:
        fh.write(readme_raw)
    restored = file_digest(README) == hashlib.sha256(readme_raw).hexdigest()
    record("check_prose_counts FAILS on an unsourced count under a NEW heading",
           "PASS" if (code == 1 and "4242" in out and restored) else "FAIL",
           "EXIT %d, the gate names the number and the line, and README.md is restored "
           "byte-identically (asserted in BINARY: %s). The heading matters: the scanner's "
           "declared-provenance flag is sticky until the next heading, so a count appended at the "
           "end inherits provenance from far above and the gate stays silent." % (code, restored))
    code, out = run_gate("check_prose_counts")
    record("check_prose_counts returns to PASS with the injection removed",
           "PASS" if code == 0 else "FAIL", "EXIT %d" % code)

    # 5. check_patterns -- a control byte inside a COMPILED pattern, which is the §12 defect
    names_py = os.path.join(N.GEN_DIR, "mtv2_names.py")
    with open(names_py, "rb") as fh:
        names_raw = fh.read()
    old = b'LEADING_DIGIT = re.compile(r"' + bytes([92]) + b'A[0-9]")'
    new = b'LEADING_DIGIT = re.compile("' + bytes([8]) + b'A[0-9]")'
    fired = restored_names = False
    gate_out = ""
    if names_raw.count(old) == 1:
        with open(names_py, "wb") as fh:
            fh.write(names_raw.replace(old, new, 1))
        with open(names_py, "rb") as fh:
            present = bytes([8]) in fh.read()
        code, gate_out = run_gate("check_patterns")
        with open(names_py, "wb") as fh:
            fh.write(names_raw)
        restored_names = file_digest(names_py) == hashlib.sha256(names_raw).hexdigest()
        fired = present and code == 1 and restored_names
        detail = ("0x08 asserted PRESENT in the bytes BEFORE the verdict (present=%s), gate EXIT "
                  "%d naming the file and line, and mtv2_names.py restored byte-identically "
                  "(asserted in BINARY: %s). %s"
                  % (present, code, restored_names,
                     " ".join(l.strip() for l in gate_out.splitlines()
                              if "control_byte" in l)[:140]))
    else:
        detail = ("NOT_RUN: the anchor this probe substitutes is not present exactly once in "
                  "mtv2_names.py, so the injection could not be placed. Reported rather than "
                  "skipped.")
    record("check_patterns FAILS on a control byte in a compiled pattern",
           "PASS" if fired else ("NOT_RUN" if names_raw.count(old) != 1 else "FAIL"), detail)
    code, _out = run_gate("check_patterns")
    record("check_patterns returns to PASS with the injection removed",
           "PASS" if code == 0 else "FAIL", "EXIT %d" % code)

    # ---- the tree, and the bundle, AFTER
    final, final_n = tree_digest()
    record("the tree is byte-identical to the baseline after EVERY injection",
           "PASS" if (final == baseline and final_n == base_n) else "FAIL",
           "%d file(s) -> %s, baseline %s over %d file(s)"
           % (final_n, final, baseline, base_n))
    after = {os.path.basename(N.MAP_PATH): file_digest(N.MAP_PATH)}
    record("the bundle is byte-identical before and after this verification",
           "PASS" if before == after else "FAIL",
           "%s: %s before, %s after. The bundle is READ-ONLY and FINAL (BUILD_RULES 9.1, 9.6)."
           % (os.path.basename(N.MAP_PATH),
              list(before.values())[0][:16], list(after.values())[0][:16]))

    result = {
        "produced_by": "generators/verify_mtv2_gates.py -- this file. Every gate verdict is the "
                       "gate's OWN subprocess returncode; nothing is read through a pipe.",
        "outcome_vocabulary": "PASS / FAIL / NOT_RUN / DID_NOT_COMPLETE, never collapsed to two "
                              "(BUILD_RULES 1.8).",
        "gates": {g: {"argv": GATES[g], "clean_exit": clean[g],
                      "verdict": "PASS" if clean[g] == 0 else "FAIL"} for g in sorted(GATES)},
        "baseline_tree_sha256": baseline,
        "baseline_tree_files": base_n,
        "final_tree_sha256": final,
        "bundle_before": before,
        "bundle_after": after,
        "checks": RESULTS,
        "failed": [r["check"] for r in RESULTS if r["result"] == "FAIL"],
        "not_run": [r["check"] for r in RESULTS if r["result"] == "NOT_RUN"],
    }
    N.ensure_dir(N.ARTIFACTS)
    N.assert_writable(OUT)
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(result, fh, indent=1)
    print("  -> %s" % OUT)
    print("  %d check(s): %d PASS, %d FAIL, %d NOT_RUN"
          % (len(RESULTS),
             sum(1 for r in RESULTS if r["result"] == "PASS"),
             sum(1 for r in RESULTS if r["result"] == "FAIL"),
             sum(1 for r in RESULTS if r["result"] == "NOT_RUN")))
    # The scope-limit check is recorded as FAIL because the GATE is silent where it should not be.
    # That is a finding against a SHARED gate this stage may not edit, so it does not stop this
    # verifier; it is named here and routed in the stage-1 report.
    blocking = [r for r in RESULTS if r["result"] == "FAIL" and "GATE SCOPE LIMIT" not in r["check"]]
    if blocking:
        raise SystemExit("verify_mtv2_gates: %d check(s) FAILED: %s"
                         % (len(blocking), "; ".join(r["check"] for r in blocking)))


if __name__ == "__main__":
    main()
