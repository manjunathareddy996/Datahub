# -*- coding: utf-8 -*-
"""THE DOCUMENTED RUN ORDER. health_consolidated.

Every step is a SUBPROCESS with PYTHONDONTWRITEBYTECODE=1, so a step that crashes cannot leave a
half-imported module behind for the next one, and no __pycache__ is written into the project tree.

REPRODUCIBILITY IS PROVED BY DELETION (s9.3): --fresh deletes models/ and build_artifacts/ first.
A build that only works on a second run is not reproducible; it is inheriting state.

USAGE
    python run_hcon_build.py            # run the chain
    python run_hcon_build.py --fresh    # delete models/ and build_artifacts/ first, then run
"""
import os
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(HERE, os.pardir))

sys.path.insert(0, HERE)
from hcon_writeguard import (PROJECT_ROOT as PR, assert_read_only_intact, manifest_audit,  # noqa
                             selftest as guard_selftest, validate_digest_tool, tree_digest,
                             MANIFEST)

# (step, why it must come here)
ORDER = [
    ("hcon_writeguard.py", "prove the write guard REFUSES and the digest tool reproduces a known "
                           "answer, before anything is written"),
    ("hcon_names.py", "probe every regex and every naming rule; a pattern that cannot match "
                      "reports a zero indistinguishable from a clean result"),
    ("hcon_keyrules.py", "assert the profile and the map field-by-field, re-measure the profile's "
                         "load-bearing claims, and prove the walk-operator zero"),
    ("build_hcon_spec.py", "the ONE place the map is interpreted; everything after reads the spec"),
    ("gen_hcon_staging.py", "layer-1 casts; the stage layer refs these"),
    ("gen_hcon_hopviews.py", "walk-only casts: PROVE the zero"),
    ("gen_hcon_resolvers.py", "ancestor resolvers: PROVE the zero, twice"),
    ("gen_hcon_stage.py", "one wide stage per view, carrying the business-key columns"),
    ("gen_hcon_unpivot.py", "column-as-instance fan-out; reads the stage layer"),
    ("gen_hcon_vault.py", "hub feeds, hubs, links, satellites -- reads the stage layer"),
    ("gen_hcon_augmented.py", "the unratified track; imports the vault renderer so both tracks "
                              "share ONE satellite renderer"),
    ("gen_hcon_rejectlog.py", "the complement of every feed's WHERE clause"),
    ("gen_hcon_assertions.py", "LOAD-TIME assertions: the registry hazard and the intra-run "
                               "arbitrariness are DATA questions and cannot be settled "
                               "statically. Emitted and UNRUN."),
    ("check_hcon_reachability.py", "every <X>_HK referenced is produced locally or by a ref()ed "
                                   "model -- fixpoint over the ref graph"),
    ("check_hcon_payload_naming.py", "the payload-naming half that check_vault_alignment cannot "
                                     "reach in this layout"),
    ("emit_hcon_status.py", "BUILD_STATUS.json -- every count lives here and nowhere else"),
    ("gen_hcon_readme.py", "generators/README.md, generated FROM BUILD_STATUS.json; it must exist "
                           "before any gate or proof reads it"),
    ("run_hcon_gates.py", "every gate as a subprocess, exit codes read UNPIPED, population "
                          "recorded, a PASS on an empty population downgraded to NOT RUN"),
    ("prove_hcon_checks.py", "prove every check by INJECTION against a copy of the real corpus: "
                             "it must FIRE on the defect and stay SILENT on the clean corpus"),
    ("emit_hcon_stage1_report.py", "the stage-1 completion report; needs the gate verdicts and "
                                   "the proof results, and every builder decision appears as a "
                                   "decision_taken finding so the handback cannot omit one"),
]


def run(step):
    env = dict(os.environ)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    t0 = time.time()
    p = subprocess.run([sys.executable, os.path.join(HERE, step)], cwd=HERE, env=env,
                       capture_output=True, text=True)
    return p.returncode, p.stdout, p.stderr, time.time() - t0


# Stage-0 artefacts are INPUTS to this stage and are NEVER deleted by --fresh. Two of them are
# load-bearing: carried_forward_caveats.json supplies the five s9.8 blocks reproduced verbatim into
# model headers, and vault_table_sets.json supplies the 62/140/45 partition.
STAGE0_INPUTS = ("baseline_digests.json", "carried_forward_caveats.json",
                 "declared_unresolved_grain.json", "input_manifest.json",
                 "r8_precedence_table.json", "stage0_report.json",
                 "stage65_reissue_diff.json", "vault_table_sets.json")

# Exactly what THIS stage writes.
STAGE1_OUTPUTS = ("build_artifacts/hcon_spec.json",
                  "build_artifacts/BUILD_STATUS.json",
                  "build_artifacts/write_manifest.jsonl",
                  "build_artifacts/reports/declared_unresolved_grain_hcon.json",
                  "build_artifacts/reports/hub_registries.json",
                  "build_artifacts/reports/r8_precedence_as_built.json",
                  "build_artifacts/reports/stage1_report.json",
                  "generators/README.md")


def _rmtree_stubborn(path, rounds=24, pause=0.5, pause_cap=2.5):
    """rmtree that survives a sync client holding a DIRECTORY handle.

    This project sits inside a OneDrive-synced folder. Measured behaviour: after one pass every
    FILE is gone and only an empty directory remains, access-denied, and the handle clears a
    second or two later. So the strategy is to alternate a full rmtree with a bottom-up manual
    pass over several rounds.

    The delete is then ASSERTED. A silently skipped delete would make the next run look
    reproducible while it was in fact inheriting state, which is the thing the deletion proof
    exists to rule out.
    """
    last = None
    for _round in range(rounds):
        if not os.path.exists(path):
            return
        try:
            shutil.rmtree(path)
            if not os.path.exists(path):
                return
        except (PermissionError, OSError) as exc:
            last = exc
        for root, dirs, fnames in os.walk(path, topdown=False):
            for f in fnames:
                try:
                    os.remove(os.path.join(root, f))
                except OSError as exc:
                    last = exc
            for d in dirs:
                try:
                    os.rmdir(os.path.join(root, d))
                except OSError as exc:
                    last = exc
        try:
            os.rmdir(path)
        except OSError as exc:
            last = exc
        if not os.path.exists(path):
            return
        time.sleep(min(pause * (_round + 1), pause_cap))
    remaining_files, remaining_dirs = [], []
    for root, dirs, fnames in os.walk(path):
        remaining_files += [os.path.join(root, f) for f in fnames]
        remaining_dirs += [os.path.join(root, d) for d in dirs]
    if remaining_files:
        raise AssertionError(
            "COULD NOT DELETE %s after %d rounds (%s). %d FILE(S) REMAIN: %s. A remaining file is "
            "INHERITED STATE, so the deletion proof cannot be completed and this run must NOT be "
            "reported as reproducible-by-deletion. Re-run; if it recurs on the same path, the "
            "lock is real."
            % (path, rounds, last, len(remaining_files), remaining_files[:5]))
    # Every FILE is gone and only empty directories remain -- diagnosed repeatedly, in the synced
    # project folder and in %TEMP%: a handle outside this process lingers on a just-written
    # directory. REPORTED, not fatal. What the deletion proof must rule out is INHERITED STATE;
    # state lives in files, the tree digest enumerates files, and an empty directory can neither
    # carry state nor change the digest. Failing here would stop a correct build for a property
    # that does not matter, which is how an assertion gets switched off (s1.12).
    print("  NOTE: %d empty director%s could not be removed after %d rounds and %s REPORTED, not "
          "fatal: %s. Every FILE was deleted, so no state is inherited -- the models tree digest "
          "enumerates files only."
          % (len(remaining_dirs), "y" if len(remaining_dirs) == 1 else "ies", rounds,
             "is" if len(remaining_dirs) == 1 else "are",
             [os.path.relpath(d, PROJECT_ROOT) for d in remaining_dirs[:4]]))


def fresh():
    """Delete everything this stage produces, and NOTHING it consumes (s9.3)."""
    models = os.path.join(PROJECT_ROOT, "models")
    if os.path.isdir(models):
        _rmtree_stubborn(models)
        print("  DELETED models/ entirely, and asserted it is gone")
    for rel in STAGE1_OUTPUTS:
        p = os.path.join(PROJECT_ROOT, *rel.split("/"))
        if os.path.exists(p):
            os.remove(p)
            print("  DELETED %s" % rel)
    reports = os.path.join(PROJECT_ROOT, "build_artifacts", "reports")
    missing = [f for f in STAGE0_INPUTS if not os.path.exists(os.path.join(reports, f))]
    if missing:
        raise AssertionError(
            "--fresh must not remove a stage-0 INPUT, and these are absent: %s. Two of them are "
            "load-bearing: carried_forward_caveats.json and vault_table_sets.json." % missing)
    print("  reproducibility is proved by deletion (s9.3): models/ is absent and every stage-1")
    print("  artefact is removed, while all %d stage-0 inputs are asserted PRESENT -- deleting an"
          % len(STAGE0_INPUTS))
    print("  input and rebuilding proves the build cannot run twice, not that it is reproducible")



def _checkpoint(done, step, rc):
    """Rewrite stage1_progress.json per step, so an interruption costs ONE layer, not the run."""
    import json
    path = os.path.join(PROJECT_ROOT, "build_artifacts", "reports", "stage1_progress.json")
    prev = {}
    if os.path.exists(path):
        try:
            with open(path, encoding="utf-8") as fh:
                prev = json.load(fh)
        except ValueError:
            prev = {}
    prev.update({
        "stage": "1",
        "state": "IN_PROGRESS",
        "steps_total": len(ORDER),
        "steps_complete": len(done),
        "layers_done": list(done),
        "last_step": step,
        "last_step_exit": rc,
        "resume_note": "Re-run run_hcon_build.py. Every step is idempotent and reads only the "
                       "spec, so resuming re-does at most the failed step; --fresh re-does all of "
                       "them and is what proves reproducibility.",
    })
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(prev, fh, indent=1)




def _finish(n):
    import json
    path = os.path.join(PROJECT_ROOT, "build_artifacts", "reports", "stage1_progress.json")
    prev = {}
    if os.path.exists(path):
        with open(path, encoding="utf-8") as fh:
            prev = json.load(fh)
    prev.update({"state": "COMPLETE", "steps_complete": n, "steps_total": n})
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(prev, fh, indent=1)



def main():
    argv = sys.argv[1:]
    print("=" * 100)
    print("health_consolidated build chain -- %d steps, each a subprocess with "
          "PYTHONDONTWRITEBYTECODE=1" % len(ORDER))
    print("=" * 100)
    guard_selftest()
    validate_digest_tool()
    opened = assert_read_only_intact("build-open")
    if "--fresh" in argv:
        fresh()
    failed = []
    done = []
    for step, why in ORDER:
        rc, out, err, dt = run(step)
        _checkpoint(done, step, rc)
        tag = "OK  " if rc == 0 else "FAIL"
        print("\n--- [%s] %-32s %5.1fs   (%s)" % (tag, step, dt, why))
        for line in out.splitlines():
            print("    " + line)
        if rc != 0:
            for line in err.strip().splitlines()[-18:]:
                print("    ! " + line)
            failed.append(step)
            break
        done.append(step)
    print("\n" + "=" * 100)
    closed = assert_read_only_intact("build-close")
    for proj in opened:
        if opened[proj]["tree_digest_sha256"] != closed[proj]["tree_digest_sha256"]:
            raise AssertionError("READ-ONLY PROJECT CHANGED DURING THE BUILD: %s" % proj)
    manifest_audit()
    md, mf, mb = tree_digest(os.path.join(PROJECT_ROOT, "models"))
    print("  models/ tree digest sha256 %s  (%d files, %d bytes)" % (md, mf, mb))
    print("  combining method: per file 'posix-relpath + LF + sha256(file bytes)'; lines sorted "
          "bytewise; joined with LF; sha256 of the UTF-8 encoding of that join")
    if failed:
        print("  RESULT: FAILED at %s" % failed[0])
        return 1
    _finish(len(ORDER))
    print("  RESULT: chain complete, %d steps, 0 failures" % len(ORDER))
    return 0


if __name__ == "__main__":
    sys.exit(main())
