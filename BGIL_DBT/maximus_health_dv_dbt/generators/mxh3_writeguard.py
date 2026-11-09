# -*- coding: utf-8 -*-
"""Containment. Every write this build makes goes through here.

ABSOLUTE: this build writes only inside maximus_health_v3_dv_dbt. The calibration
sibling opus_health_v2_dv_dbt is READ-ONLY -- a closed, digested, signed-off build
that this build changes NOTHING in, no matter what is found. health_dv_dbt,
maximus_health_dv_dbt and maximus_health_v2_dv_dbt are never opened at all.
vault_tools and .claude are never written.

The manifest is CROSS-PROCESS: it is appended to a .jsonl on disk, so a write
made by a different process (a generator run on its own, a gate, a later stage)
is still recorded and still auditable. An in-memory list would only prove the
containment of the process that happens to be holding it.

s9.1: NEVER write into a directory you read -- asserted over the WHOLE input set,
not spot-checked.
"""
import json
import os
import time

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(HERE)
MODELS = os.path.join(PROJECT, "models")
ARTIFACTS = os.path.join(PROJECT, "build_artifacts")
MANIFEST = os.path.join(ARTIFACTS, "write_manifest.jsonl")

_REPO = os.path.dirname(PROJECT)

# Directories this build READS. Writing into any of them is a hard error.
READ_ONLY_ROOTS = []


def _norm(p):
    return os.path.normcase(os.path.abspath(p))


def _init_read_only_roots():
    prof = os.path.join(PROJECT, "build_profile.json")
    roots = [
        os.path.join(_REPO, "vault_tools"),
        os.path.join(_REPO, ".claude"),
        os.path.join(_REPO, "opus_health_v2_dv_dbt"),
        os.path.join(_REPO, "health_dv_dbt"),
        os.path.join(_REPO, "maximus_health_dv_dbt"),
        os.path.join(_REPO, "maximus_health_v2_dv_dbt"),
    ]
    if os.path.isfile(prof):
        with open(prof, encoding="utf-8") as fh:
            roots.append(json.load(fh)["bundle_root"])
    # every sibling project on the estate, swept rather than named one by one
    if os.path.isdir(_REPO):
        for e in os.listdir(_REPO):
            full = os.path.join(_REPO, e)
            if os.path.isdir(full) and _norm(full) != _norm(PROJECT):
                roots.append(full)
    out, seen = [], set()
    for r in roots:
        n = _norm(r)
        if n not in seen:
            seen.add(n)
            out.append(n)
    return out


READ_ONLY_ROOTS = _init_read_only_roots()


def assert_path_is_ours(path):
    """Refuse any path outside this project, and any path inside a read root."""
    n = _norm(path)
    proj = _norm(PROJECT)
    if not (n == proj or n.startswith(proj + os.sep)):
        raise AssertionError(
            "REFUSED WRITE outside the project: %s\nThis build writes only inside %s."
            % (path, PROJECT))
    for r in READ_ONLY_ROOTS:
        if n == r or n.startswith(r + os.sep):
            raise AssertionError(
                "REFUSED WRITE into a directory this build READS: %s (read root %s). s9.1: "
                "never write into a directory you read." % (path, r))
    return True


def assert_inputs_are_outside(inputs):
    """s9.1 over the WHOLE input set, not a spot check."""
    proj = _norm(PROJECT)
    bad = []
    for p in inputs:
        n = _norm(p)
        if n == proj or n.startswith(proj + os.sep):
            # the profile and this project's own generators are legitimately inside
            rel = os.path.relpath(n, proj)
            if rel.split(os.sep)[0] in ("build_profile.json", "generators",
                                        "build_artifacts"):
                continue
            bad.append(p)
    if bad:
        raise AssertionError(
            "%d input path(s) lie inside the OUTPUT tree: %s. A generator that reads what it "
            "writes cannot be reproduced from empty." % (len(bad), bad[:4]))
    return {"inputs_checked": len(inputs), "inputs_inside_output_tree": 0}


_COUNT = {"n": 0}


def ensure_dir(path):
    """s6.4 -- every output directory is created by the generator that writes it."""
    assert_path_is_ours(path)
    if not os.path.isdir(path):
        os.makedirs(path, exist_ok=True)
    return path


def write(path, text, generator="unknown"):
    """The ONLY way this build puts bytes on disk."""
    assert_path_is_ours(path)
    ensure_dir(os.path.dirname(path))
    data = text if text.endswith("\n") else text + "\n"
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(data)
    _record(path, len(data.encode("utf-8")), generator)
    _COUNT["n"] += 1
    return path


def _record(path, nbytes, generator):
    ensure_dir(ARTIFACTS)
    row = {"ts": time.strftime("%Y-%m-%dT%H:%M:%S"),
           "pid": os.getpid(),
           "path": os.path.relpath(path, PROJECT).replace("\\", "/"),
           "bytes": nbytes,
           "generator": generator}
    with open(MANIFEST, "a", encoding="utf-8", newline="\n") as fh:
        fh.write(json.dumps(row) + "\n")


def manifest_rows():
    if not os.path.isfile(MANIFEST):
        return []
    out = []
    with open(MANIFEST, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if line:
                out.append(json.loads(line))
    return out


def audit():
    """Re-read the cross-process manifest and prove containment."""
    rows = manifest_rows()
    outside = [r for r in rows if r["path"].startswith("..")
               or os.path.isabs(r["path"])]
    pids = sorted({r["pid"] for r in rows})
    return {
        "manifest": os.path.relpath(MANIFEST, PROJECT).replace("\\", "/"),
        "writes_recorded": len(rows),
        "distinct_processes": len(pids),
        "files_outside_project_root": len(outside),
        "containment_assertion_token": "PASS" if not outside else "FAIL",
        "read_only_roots_asserted": len(READ_ONLY_ROOTS),
    }


if __name__ == "__main__":
    print(json.dumps(audit(), indent=1))
    print("read-only roots:", len(READ_ONLY_ROOTS))
    for r in READ_ONLY_ROOTS[:8]:
        print("  ", r)
