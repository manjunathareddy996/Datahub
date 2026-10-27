# -*- coding: utf-8 -*-
"""prove_mtv2_reproducibility.py -- the deletion proof, run by a SCRIPT, with its method stated.

BUILD_RULES 9.3 requires reproducibility to be proved by DELETION, and 11.7 requires a digest a
script produced over a named file set. Stage 1 previously recorded a digest that reproduced under
none of five combining methods and whose script was not in the repository -- evidence of nothing.
This file is that script, so the number and the method can never be separated again.

WHAT IT DOES
  1. digests the tree as it stands (D0) over the NAMED FILE SET;
  2. deletes exactly what the chain rewrites -- and NOTHING else. build_artifacts/reports/ is
     never deleted and never backed up (9.3); its contents are recorded before and after and
     compared, so a deletion would be a failure rather than a surprise;
  3. runs generators/run_all.sh over the empty tree (D1);
  4. runs it again over the populated tree (D2);
  5. writes build_artifacts/reproducibility.json with D0, D1, D2, the file set, the combining
     method, and every file that differs.

THE COMBINING METHOD, stated because a digest without one is not checkable:
    sha256 of each file's bytes, then sha256 over the sorted lines "<relative path> <digest>".
    A rename, an addition, a deletion and a content change are all visible.

USAGE
    python3 prove_mtv2_reproducibility.py          (from anywhere; paths are absolute)
Exit 0 only when D0 == D1 == D2 and reports/ is intact.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys

import mtv2_names as N

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

OUT = os.path.join(N.ARTIFACTS, "reproducibility.json")
REPORTS = os.path.join(N.ARTIFACTS, "reports")

# Exactly what the chain rewrites. Anything not in this list is not deleted.
#
# BUILD_STATUS.json is DELIBERATELY ABSENT from this list. It has two writers (BUILD_RULES 10):
# this stage writes the build census and stage 2 writes the DONE clauses into the same file.
# selfcheck_mtv2.py preserves every key it does not own, but only if the file still exists --
# deleting it here destroyed another stage's verification block, and the file is not in the
# digested named file set, so deleting it proved nothing about inherited state. selfcheck
# rewrites every key it owns on every run, and it FAILS if a preserved count no longer describes
# the tree, which is the guarantee deletion was standing in for.
CHAIN_OUTPUT_FILES = [
    os.path.join(N.PROJECT, "dbt_project.yml"),
    os.path.join(N.PROJECT, "packages.yml"),
    os.path.join(N.GEN_DIR, "README.md"),
    os.path.join(N.ARTIFACTS, "mtv2_spec.json"),
    os.path.join(N.ARTIFACTS, "accepted_uncovered.mtv2.txt"),
    # reproducibility.json is DELIBERATELY ABSENT. It is written by THIS prover, not by the
    # chain: `run_all.sh` only mentions it in a comment. Listing it here made the deletion step
    # remove a file no later step rewrites, so a plain chain run destroyed it permanently --
    # which happened, and it was recovered only because the prover ran afterwards. That is
    # BUILD_RULES §9.7 exactly: nothing may delete an artifact that no subsequent step writes.
    # Three artifacts have already been lost on this estate to that ordering.
]
CHAIN_OUTPUT_DIRS = [N.MODELS]


def file_digest(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def named_file_set():
    """Every file under models/, plus dbt_project.yml and packages.yml. Named, so that what the
    digest covers is not a matter of memory."""
    out = {}
    for root, _dirs, files in os.walk(N.MODELS):
        for f in sorted(files):
            p = os.path.join(root, f)
            out[os.path.relpath(p, N.PROJECT).replace("\\", "/")] = p
    for extra in ("dbt_project.yml", "packages.yml"):
        p = os.path.join(N.PROJECT, extra)
        if os.path.exists(p):
            out[extra] = p
    return out


def tree_digest():
    files = named_file_set()
    per_file = {rel: file_digest(p) for rel, p in sorted(files.items())}
    joined = "\n".join("%s %s" % (rel, dg) for rel, dg in sorted(per_file.items()))
    return hashlib.sha256(joined.encode("utf-8")).hexdigest(), per_file


# The chain itself writes these two, so they are expected to change across a proof. Every other
# file under reports/ belongs to an earlier stage and must survive byte for byte.
# The stage-1 report AND EVERY SLOT OF ITS CASCADE. The cascade is part of the chain: a genuinely
# new report shifts prev -> prev2 -> prev3, which is the chain doing its job, not damage. The
# guarantee that matters is NOTHING LOST, and that is checked separately and is fatal.
def _is_chain_written_report(name):
    return name == "stage1_report.json" or (name.startswith("stage1_report.prev")
                                            and name.endswith(".json"))


CHAIN_WRITTEN_REPORTS = {"stage1_report.json", "stage1_report.prev.json"}


def reports_state():
    if not os.path.isdir(REPORTS):
        return {}
    return {f: file_digest(os.path.join(REPORTS, f)) for f in sorted(os.listdir(REPORTS))}


def reports_verdict(before, after):
    """(intact, detail). Intact means: nothing lost, and nothing changed that the chain does not
    write."""
    lost = sorted(set(before) - set(after))
    changed = sorted(f for f in set(before) & set(after)
                     if before[f] != after[f] and not _is_chain_written_report(f))
    return (not lost and not changed,
            {"files_before": len(before), "files_after": len(after),
             "lost": lost, "changed_outside_the_chain_written_set": changed,
             "chain_written": sorted(f for f in after if _is_chain_written_report(f)),
             "added_by_the_cascade": sorted(set(after) - set(before)),
             "rule": "LOST is fatal. A new .prevN slot is the cascade doing its job -- the chain "
                     "is shifted, nothing is overwritten and nothing is deleted "
                     "(BUILD_RULES 9.3, 9.7)."})


def wipe():
    for d in CHAIN_OUTPUT_DIRS:
        if os.path.isdir(d):
            shutil.rmtree(d)
    for f in CHAIN_OUTPUT_FILES:
        if os.path.exists(f):
            os.remove(f)


def run_chain(label):
    print("  running the chain (%s) ..." % label)
    proc = subprocess.run(["sh", os.path.join(N.GEN_DIR, "run_all.sh")],
                          cwd=N.GEN_DIR, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.stdout.write(proc.stdout[-4000:])
        sys.stderr.write(proc.stderr[-4000:])
        raise SystemExit("prove_mtv2_reproducibility: run_all.sh exited %d on %s. A chain that "
                         "cannot run from its own directory is not reproducible, whatever the "
                         "digests say." % (proc.returncode, label))
    return proc.stdout.splitlines()[-1] if proc.stdout else ""


STALE_STEM = "stale_model_planted_by_the_wipe_proof"


def prove_wipe_order(expected_digest):
    """Plant a stale model in EVERY layer directory; the chain must remove all of them.

    This is the check that FAILED on this project before, so it is run rather than trusted, and
    it is re-run whenever the run order changes -- a generator inserted in the wrong place makes
    one layer's wipe delete another layer's output.
    """
    planted = []
    for key, d in sorted(N.LAYER_DIRS.items()):
        os.makedirs(d, exist_ok=True)
        p = os.path.join(d, STALE_STEM + ".sql")
        with open(p, "w", encoding="utf-8", newline="\n") as fh:
            fh.write("-- planted by the wipe proof; no generator writes this\nselect 1\n")
        planted.append((key, p))
    run_chain("run 3, over a tree carrying a stale model in every layer")
    survivors = [k for k, p in planted if os.path.exists(p)]
    for _k, p in planted:
        if os.path.exists(p):
            os.remove(p)
    digest, files = tree_digest()
    return {"layer_directories": len(planted),
            "stale_models_planted": len(planted),
            "stale_models_surviving_the_re_run": survivors,
            "every_layer_wiped_by_its_first_writer": not survivors,
            "digest_after": digest,
            "digest_returned_to_the_proved_value": digest == expected_digest,
            "files": len(files)}


def prove_foreign_block_preserved():
    """BUILD_STATUS.json has two writers. A foreign block must survive a chain re-run."""
    path = os.path.join(N.ARTIFACTS, "BUILD_STATUS.json")
    probe_keys = ("a_later_stage_block_PROBE",)
    with open(path, encoding="utf-8") as fh:
        status = json.load(fh)
    status["a_later_stage_block_PROBE"] = {"planted_by": "prove_mtv2_reproducibility"}
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(status, fh, indent=1)
    run_chain("run 4, with another stage's block planted in BUILD_STATUS.json")
    with open(path, encoding="utf-8") as fh:
        after = json.load(fh)
    survived = all(k in after for k in probe_keys)
    named = sorted(after.get("preserved_from_a_previous_writer", {}).get("keys", []))
    for k in probe_keys:
        after.pop(k, None)
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(after, fh, indent=1)
    run_chain("run 5, cleanup after the preservation probe")
    return {"foreign_block_survived_a_chain_re_run": survived,
            "named_in_preserved_from_a_previous_writer": named,
            "note": "stage 2's clause block is written into this same file. A re-run used to "
                    "discard it; it is preserved now, and selfcheck FAILS if a preserved count "
                    "no longer describes the tree, which was proved separately by planting one."}


def main():
    print("prove_mtv2_reproducibility -- deletion proof over the named file set")
    reports_before = reports_state()
    d0, files0 = tree_digest()
    print("  D0 (tree as it stands)      : %s over %d file(s)" % (d0, len(files0)))

    wipe()
    if os.path.isdir(N.MODELS):
        raise SystemExit("models/ still exists after the wipe; the proof would inherit state.")
    print("  models/ absent, chain outputs deleted; build_artifacts/reports/ untouched")

    run_chain("run 1, from empty")
    d1, files1 = tree_digest()
    print("  D1 (rebuilt from empty)     : %s over %d file(s)" % (d1, len(files1)))

    run_chain("run 2, over the populated tree")
    d2, files2 = tree_digest()
    print("  D2 (re-run over the tree)   : %s over %d file(s)" % (d2, len(files2)))

    wipe_proof = prove_wipe_order(d2)
    print("  wipe order                  : %d of %d layer directories wiped by their first "
          "writer; digest back to the proved value = %s"
          % (wipe_proof["layer_directories"]
             - len(wipe_proof["stale_models_surviving_the_re_run"]),
             wipe_proof["layer_directories"],
             wipe_proof["digest_returned_to_the_proved_value"]))
    preservation = prove_foreign_block_preserved()
    print("  foreign block preserved     : %s"
          % preservation["foreign_block_survived_a_chain_re_run"])

    reports_after = reports_state()
    reports_ok, reports_detail = reports_verdict(reports_before, reports_after)
    only0 = sorted(set(files0) - set(files1))
    only1 = sorted(set(files1) - set(files0))
    differing = sorted(r for r in set(files0) & set(files1) if files0[r] != files1[r])

    result = {
        "produced_by": "generators/prove_mtv2_reproducibility.py -- this file. The digest and "
                       "the method are emitted together by the script that computed them "
                       "(BUILD_RULES 9.3, 11.7); no digest in this project is typed by hand.",
        "digest_method": "sha256 of each file's bytes, then sha256 over the sorted lines "
                         "'<relative path> <per-file digest>'. A rename, an addition, a deletion "
                         "and a content change are each visible.",
        "named_file_set": "every file under models/, plus dbt_project.yml and packages.yml",
        "files": len(files1),
        "deleted_before_the_proof": [os.path.relpath(p, N.PROJECT).replace("\\", "/")
                                     for p in CHAIN_OUTPUT_DIRS + CHAIN_OUTPUT_FILES],
        "never_deleted": "build_artifacts/reports/ -- not deleted and not backed up "
                         "(BUILD_RULES 9.3). BUILD_STATUS.json is also not deleted: it carries "
                         "another stage's clause block, it is not in the digested set, and "
                         "selfcheck_mtv2.py rewrites every key it owns and fails on a preserved "
                         "count that no longer describes the tree.",
        "reports_before": reports_before,
        "reports_after": reports_after,
        "reports_intact": reports_ok,
        "reports_detail": reports_detail,
        "wipe_order_proof": wipe_proof,
        "foreign_block_preservation_proof": preservation,
        "combined_sha256_shipped_tree": d0,
        "combined_sha256_run1_from_empty": d1,
        "combined_sha256_run2_over_populated": d2,
        "identical": d0 == d1 == d2,
        "only_in_the_shipped_tree": only0,
        "only_in_the_rebuilt_tree": only1,
        "differing": differing,
        "profile_revision_built_against": N.PROFILE.get("profile_revision"),
        "ran_against_the_project_profile": True,
    }
    N.ensure_dir(N.ARTIFACTS)
    N.assert_writable(OUT)
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(result, fh, indent=1)
    print("  reports/ intact             : %s  %s"
          % (result["reports_intact"], result["reports_detail"]))
    print("  D0 == D1 == D2              : %s" % result["identical"])
    print("  -> %s" % OUT)
    if (not result["identical"] or not result["reports_intact"]
            or not wipe_proof["every_layer_wiped_by_its_first_writer"]
            or not wipe_proof["digest_returned_to_the_proved_value"]
            or not preservation["foreign_block_survived_a_chain_re_run"]):
        raise SystemExit("prove_mtv2_reproducibility: NOT reproducible as it stands "
                         "(identical=%s, reports_intact=%s, wipe=%s, preservation=%s)"
                         % (result["identical"], result["reports_intact"],
                            wipe_proof["every_layer_wiped_by_its_first_writer"],
                            preservation["foreign_block_survived_a_chain_re_run"]))


if __name__ == "__main__":
    main()
