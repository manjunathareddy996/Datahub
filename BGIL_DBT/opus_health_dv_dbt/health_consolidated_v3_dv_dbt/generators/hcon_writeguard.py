# -*- coding: utf-8 -*-
"""Write confinement for the consolidated health build, enforced ACROSS PROCESSES.

WHY THIS EXISTS
---------------
`health_dv_dbt` and `opus_health_v2_dv_dbt` are the two ORIGINALS this project consolidates. This
build READS both of them (the legacy half of the map carries zero resolved_key, so the legacy hub
key forms exist only in legacy's emitted SQL -- open item R4-builder). Reading a directory you must
never write is the exact configuration in which an accidental write is both easy and invisible, and
BUILD_RULES.md s9.1 forbids writing into a directory you read.

An in-process assertion is not enough, because the build runs as a CHAIN OF SUBPROCESSES. Each
process appends every path it opens for writing to ONE manifest file; the closing audit replays the
manifest and re-digests the two read-only trees. A write that slipped past the in-process check
still shows up as a digest change, and a write the digest cannot see (a touched mtime, say) still
shows up in the manifest.

USAGE
    from hcon_writeguard import guarded_open, PROJECT_ROOT, assert_read_only_intact
    with guarded_open(path, "w") as fh: ...
"""
import hashlib
import json
import os
import time

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(HERE, os.pardir))
REPO_ROOT = os.path.abspath(os.path.join(PROJECT_ROOT, os.pardir))

# DERIVED from this file's own location, never hardcoded. The copied-forward v3 build
# inherited the literal "health_consolidated_dv_dbt" here and promptly refused to write
# into ITSELF -- while treating the ORIGINAL project as its legitimate write target. The
# guard caught it, which is the point: a hardcoded project name in a write guard survives a
# copy-forward and points the copy at its parent.
PROJECT_NAME = os.path.basename(PROJECT_ROOT)

# Never written, ever. The first two are read by this build; the rest are named so a typo in a
# path cannot land in them silently.
READ_ONLY_PROJECTS = ("health_dv_dbt", "opus_health_v2_dv_dbt",
                      # the build this one was COPIED FROM. It is a closed, verified
                      # artifact and v3 must never write into it -- the one place a
                      # copy-forward is most likely to, since every path it inherited
                      # pointed there a moment ago.
                      "health_consolidated_dv_dbt")
NEVER_OPEN_AT_ALL = ("maximus_health_v3_dv_dbt", "partner_kyc_opus")
NEVER_WRITE = READ_ONLY_PROJECTS + NEVER_OPEN_AT_ALL + ("vault_tools", ".claude", "partner_dv_dbt")

MANIFEST = os.path.join(PROJECT_ROOT, "build_artifacts", "write_manifest.jsonl")

# Baselines come from the profile, which took them from stage 0. Restated nowhere else.
_PROFILE = os.path.join(PROJECT_ROOT, "build_profile.json")


def _profile():
    with open(_PROFILE, encoding="utf-8") as fh:
        return json.load(fh)


def assert_inside(path):
    """Raise unless `path` is inside this project. Never warn; a warning gets scrolled past."""
    ap = os.path.abspath(path)
    if not (ap == PROJECT_ROOT or ap.startswith(PROJECT_ROOT + os.sep)):
        raise AssertionError(
            "WRITE CONFINEMENT VIOLATION: %s is outside %s" % (ap, PROJECT_ROOT))
    rel = os.path.relpath(ap, REPO_ROOT).replace(os.sep, "/")
    head = rel.split("/")[0]
    if head in NEVER_WRITE:
        raise AssertionError("WRITE CONFINEMENT VIOLATION: %s is in a never-write tree" % ap)
    if head != PROJECT_NAME:
        raise AssertionError(
            "WRITE CONFINEMENT VIOLATION: %s does not begin with %s/" % (rel, PROJECT_NAME))
    return ap


def _record(path, mode):
    os.makedirs(os.path.dirname(MANIFEST), exist_ok=True)
    row = {"pid": os.getpid(), "t": time.time(), "mode": mode,
           "path": os.path.relpath(os.path.abspath(path), REPO_ROOT).replace(os.sep, "/")}
    with open(MANIFEST, "a", encoding="utf-8") as fh:
        fh.write(json.dumps(row, sort_keys=True) + "\n")


def guarded_open(path, mode="w", **kw):
    """open() for writing, confined and recorded. Creates the parent directory (s6.4)."""
    if "r" in mode and "+" not in mode:
        raise AssertionError("guarded_open is for WRITES; use open() to read")
    ap = assert_inside(path)
    os.makedirs(os.path.dirname(ap), exist_ok=True)
    if os.path.abspath(ap) != os.path.abspath(MANIFEST):
        _record(ap, mode)
    kw.setdefault("encoding", "utf-8")
    kw.setdefault("newline", "\n")
    return open(ap, mode, **kw)


def guarded_makedirs(path):
    ap = assert_inside(path)
    os.makedirs(ap, exist_ok=True)
    return ap


# ----------------------------------------------------------------- tree digest
# Recipe from build_profile.json read_only_guard.recipe_note, validated against a control project
# whose digest was recorded by a previous build (partner_dv_dbt). The recipe is NOT trusted until
# that control reproduces: stage 0's first tool returned sha256('') for all three projects.
CONTROL_PROJECT = "partner_dv_dbt"
CONTROL_DIGEST = "d130c4bb8bd42b67136ebec6ca26d0008caba558d6747b4560481d983d51a3c7"
EMPTY_SHA256 = hashlib.sha256(b"").hexdigest()


def tree_digest(root):
    """posix-relpath + LF + sha256(bytes) per file; lines sorted; joined with LF; sha256 of that."""
    root = os.path.abspath(root)
    lines, nbytes, nfiles = [], 0, 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for fn in sorted(filenames):
            full = os.path.join(dirpath, fn)
            rel = os.path.relpath(full, root).replace(os.sep, "/")
            with open(full, "rb") as fh:
                blob = fh.read()
            lines.append("%s\n%s" % (rel, hashlib.sha256(blob).hexdigest()))
            nbytes += len(blob)
            nfiles += 1
    lines.sort()
    return (hashlib.sha256("\n".join(lines).encode("utf-8")).hexdigest(), nfiles, nbytes)


def validate_digest_tool(verbose=True):
    """Prove the recipe against a KNOWN ANSWER before any guard depends on it."""
    d, n, _ = tree_digest(os.path.join(REPO_ROOT, CONTROL_PROJECT))
    if n == 0:
        raise AssertionError("digest tool walked 0 files for the control project")
    if d == EMPTY_SHA256:
        raise AssertionError("digest tool returned sha256 of the EMPTY STRING -- rejected")
    if d != CONTROL_DIGEST:
        raise AssertionError("digest tool FAILED its known answer: %s != %s" % (d, CONTROL_DIGEST))
    if verbose:
        print("  digest tool VALIDATED against %s = %s... (%d files)"
              % (CONTROL_PROJECT, d[:8], n))
    return True


def assert_read_only_intact(when, verbose=True):
    """Re-assert both originals byte-for-byte. Any change is a s9.9 violation."""
    validate_digest_tool(verbose=False)
    prof = _profile()
    base = prof["read_only_guard"]["baseline"]
    basef = prof["read_only_guard"]["baseline_files"]
    unknown = set(base) - set(READ_ONLY_PROJECTS)
    if unknown:
        raise AssertionError("profile names a read-only project this guard does not know: %s"
                             % sorted(unknown))
    out = {}
    for proj in READ_ONLY_PROJECTS:
        d, n, b = tree_digest(os.path.join(REPO_ROOT, proj))
        if d != base[proj] or n != basef[proj]:
            raise AssertionError(
                "READ-ONLY VIOLATION at %s: %s is %s/%d files, baseline %s/%d files"
                % (when, proj, d, n, base[proj], basef[proj]))
        out[proj] = {"tree_digest_sha256": d, "files": n, "bytes": b}
        if verbose:
            print("  %-24s UNCHANGED  %s  %d files" % (proj, d[:16], n))
    for proj in NEVER_OPEN_AT_ALL:
        p = os.path.join(REPO_ROOT, proj)
        if os.path.isdir(p) and verbose:
            print("  %-24s PRESENT, NEVER OPENED by this build" % proj)
    return out


def manifest_audit(verbose=True):
    """Replay the cross-process manifest. Every recorded write must be inside this project."""
    if not os.path.exists(MANIFEST):
        return {"records": 0, "distinct_paths": 0, "outside": []}
    rows = []
    with open(MANIFEST, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    outside = sorted({r["path"] for r in rows
                      if not r["path"].startswith(PROJECT_NAME + "/")})
    paths = sorted({r["path"] for r in rows})
    pids = sorted({r["pid"] for r in rows})
    if verbose:
        print("  write manifest: %d records, %d distinct paths, %d processes, %d outside project"
              % (len(rows), len(paths), len(pids), len(outside)))
    if outside:
        raise AssertionError("manifest records writes OUTSIDE the project: %s" % outside[:5])
    return {"records": len(rows), "distinct_paths": len(paths), "processes": len(pids),
            "outside": outside}


def selftest():
    """Prove the guard REFUSES. A guard not shown to refuse proves nothing (s1.1)."""
    bad = [os.path.join(REPO_ROOT, "health_dv_dbt", "x.sql"),
           os.path.join(REPO_ROOT, "opus_health_v2_dv_dbt", "x.sql"),
           os.path.join(REPO_ROOT, "vault_tools", "x.py"),
           os.path.join(REPO_ROOT, "maximus_health_v3_dv_dbt", "x.sql"),
           os.path.join(REPO_ROOT, "data_7.js")]
    for p in bad:
        try:
            assert_inside(p)
        except AssertionError:
            continue
        raise AssertionError("GUARD DID NOT REFUSE: %s" % p)
    assert_inside(os.path.join(PROJECT_ROOT, "models", "x.sql"))
    print("  writeguard selftest: refused %d out-of-project paths, allowed 1 in-project" % len(bad))
    return True


if __name__ == "__main__":
    selftest()
    validate_digest_tool()
    assert_read_only_intact("standalone")
    manifest_audit()
