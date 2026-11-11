# -*- coding: utf-8 -*-
"""The absolute rule: building v5 changes nothing in any other build, ever.

`baseline` records every file outside this project -- every sibling build, vault_tools, data_7.js
and the two mapper bundle directories this build reads -- as (relative path, size, mtime_ns).
`check` re-walks the same roots and reports any file added, removed or modified.

Size + mtime is the right instrument here: the claim is "nothing was written", and any write
changes mtime. It is cheap enough to run on every build, which a content hash of ~20k files on
OneDrive is not -- and a guard that is too slow to run stops being run.
"""
import io
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.abspath(os.path.join(HERE, os.pardir))
WORKSPACE = os.path.abspath(os.path.join(PROJECT, os.pardir))
DEV = os.path.abspath(os.path.join(WORKSPACE, os.pardir))
BASELINE = os.path.join(PROJECT, "build_artifacts", "other_builds_baseline.json")

ROOTS = [
    (WORKSPACE, {os.path.basename(PROJECT)}),
    (os.path.join(DEV, "SourceMapping_Skill", "Health Consolidated"), set()),
    (os.path.join(DEV, "SourceMapping_Skill", "OPUS Health Delta 3"), set()),
]


def snapshot():
    out = {}
    for root, skip_top in ROOTS:
        for d, dirs, files in os.walk(root):
            if d == root:
                dirs[:] = [x for x in dirs if x not in skip_top]
            for f in files:
                p = os.path.join(d, f)
                try:
                    st = os.stat(p)
                except OSError:
                    continue
                out[os.path.relpath(p, DEV).replace("\\", "/")] = [st.st_size, st.st_mtime_ns]
    return out


def baseline():
    snap = snapshot()
    os.makedirs(os.path.dirname(BASELINE), exist_ok=True)
    io.open(BASELINE, "w", encoding="utf-8").write(json.dumps(snap, sort_keys=True))
    print("  baseline: %d files outside this project recorded" % len(snap))


def check():
    """Return (status, detail). Never PASS without a baseline to compare against."""
    if not os.path.exists(BASELINE):
        return "NOT RUN", {"why": "no baseline was recorded before the build"}
    before = json.load(io.open(BASELINE, encoding="utf-8"))
    after = snapshot()
    added = sorted(set(after) - set(before))
    removed = sorted(set(before) - set(after))
    changed = sorted(k for k in set(before) & set(after) if before[k] != after[k])
    detail = {"files_compared": len(before), "added": added[:20], "removed": removed[:20],
              "modified": changed[:20], "n_added": len(added), "n_removed": len(removed),
              "n_modified": len(changed)}
    if not before:
        return "NOT RUN", detail
    return ("PASS" if not (added or removed or changed) else "FAIL"), detail


if __name__ == "__main__":
    if sys.argv[1:] == ["baseline"]:
        baseline()
    else:
        s, d = check()
        print(s, json.dumps(d)[:2000])
