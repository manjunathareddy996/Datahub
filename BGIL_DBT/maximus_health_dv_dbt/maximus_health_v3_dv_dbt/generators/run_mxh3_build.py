# -*- coding: utf-8 -*-
"""Run the whole chain in the documented order, FROM EMPTY.

s9.3 -- REPRODUCIBILITY IS PROVED BY DELETION. This deletes models/ and every
generated artifact, runs each generator in order, re-runs the in-chain invariants,
and emits BUILD_STATUS.json with a tree digest. A build that only works on a
second run is not reproducible; it is inheriting state.

Each generator is imported and called in-process, which is fine because they are
THIS project's modules. The GATES are different: they run as SUBPROCESSES with
PYTHONDONTWRITEBYTECODE=1 and are never imported, because an imported gate shares
this process's sys.path and sys.modules and can be shadowed by a stale module.
"""
import hashlib
import importlib
import json
import os
import shutil
import stat
import subprocess
import sys
import time

import mxh3_bundle as B
import mxh3_emit as E
import mxh3_writeguard as W

RUN_ORDER = [
    ("build_mxh3_spec", "map -> the ONE spec artifact (the only reader of the map)"),
    ("gen_mxh3_staging", "layer-1 casts for views that NEED one"),
    ("gen_mxh3_hopviews", "walk-only casts: every intervening level"),
    ("gen_mxh3_resolvers", "one resolver per start view, joins per REAL level"),
    ("gen_mxh3_unpivot", "column-as-instance families -> one row per instance"),
    ("gen_mxh3_stage", "one wide stage per view: keys + EMIT flags"),
    ("gen_mxh3_rejectlog", "divert-and-COUNT, the exact complement of EMIT"),
    ("gen_mxh3_vault", "hub feeds, hubs, links, satellites"),
    ("gen_mxh3_augmented", "the unratified build-side track"),
    ("gen_mxh3_quarantine", "BESPOKE: surrogate_child_key_quarantine"),
    ("gen_mxh3_refdecode", "BESPOKE: reference_decode_gate"),
    ("gen_mxh3_tests", "3 load-time assertions (runtime NOT RUN -- no source access)"),
]

GENERATED_ARTIFACTS = ("mxh3_spec.json", "write_manifest.jsonl", "BUILD_STATUS.json")
REPO = os.path.dirname(W.PROJECT)
VAULT_TOOLS = os.path.join(REPO, "vault_tools")
SIBLING = os.path.join(REPO, "opus_health_v2_dv_dbt")


def _rmtree_stubborn(path, attempts=6):
    """rmtree with a retry: this project lives in a OneDrive-synced folder, where the
    sync client can hold a directory handle briefly after its files are gone."""
    def _onexc(func, target, exc):
        try:
            os.chmod(target, stat.S_IWRITE)
            func(target)
        except OSError:
            pass
    last = None
    for i in range(attempts):
        try:
            try:
                shutil.rmtree(path, onexc=_onexc)
            except TypeError:
                shutil.rmtree(path, onerror=lambda f, t, e: _onexc(f, t, e))
            return
        except OSError as ex:
            last = ex
            time.sleep(0.4 * (i + 1))
    if os.path.isdir(path):
        raise AssertionError(
            "could not delete %s after %d attempts (%s). Reproducibility is proved by "
            "DELETION, so a build that cannot start from empty is not proved."
            % (path, attempts, last))


def clean():
    if os.path.isdir(W.MODELS):
        W.assert_path_is_ours(W.MODELS)
        _rmtree_stubborn(W.MODELS)
    for name in GENERATED_ARTIFACTS:
        p = os.path.join(W.ARTIFACTS, name)
        if os.path.exists(p):
            W.assert_path_is_ours(p)
            os.remove(p)
    E.reset_progress()
    print("cleaned: models/ and %d generated artifact(s). "
          "build_artifacts/reports/ is NEVER deleted." % len(GENERATED_ARTIFACTS))


def digest_tree(root):
    """A combining digest over the model tree.

    METHOD, stated because a digest without its combining method is unverifiable:
      1. walk `root` recursively and collect every file
      2. render each as  <posix-relative-path> + LF + sha256(file bytes)
      3. sort those lines as byte strings, so filesystem walk order cannot affect
         the result
      4. join with LF and take sha256 of the UTF-8 encoding of the join
    """
    lines = []
    for dirpath, _dirs, files in os.walk(root):
        for f in sorted(files):
            full = os.path.join(dirpath, f)
            rel = os.path.relpath(full, root).replace("\\", "/")
            with open(full, "rb") as fh:
                lines.append(rel + chr(10) + hashlib.sha256(fh.read()).hexdigest())
    lines.sort()
    blob = chr(10).join(lines)
    return {
        "files": len(lines),
        "tree_sha256": hashlib.sha256(blob.encode("utf-8")).hexdigest(),
        "combining_method":
            "per file: <posix-relpath> + LF + sha256(file bytes); lines sorted bytewise; "
            "joined with LF; sha256 of the UTF-8 encoding of that join",
    }


def count_models():
    out = {}
    for dirpath, _d, files in os.walk(W.MODELS):
        rel = os.path.relpath(dirpath, W.MODELS).replace("\\", "/")
        n = len([f for f in files if f.endswith(".sql")])
        if n:
            out[rel] = n
    return out


def run_gate(name, args):
    """A gate is a SUBPROCESS with PYTHONDONTWRITEBYTECODE=1 -- never imported."""
    path = os.path.join(VAULT_TOOLS, name + ".py")
    if not os.path.isfile(path):
        return {"gate": name, "verdict": "NOT RUN", "exit_code": None,
                "detail": "gate not present at %s" % path}
    env = dict(os.environ)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    try:
        p = subprocess.run([sys.executable, path] + args, capture_output=True,
                           text=True, env=env, cwd=REPO, timeout=600)
    except subprocess.TimeoutExpired:
        return {"gate": name, "verdict": "DID NOT COMPLETE", "exit_code": None,
                "detail": "timed out after 600s"}
    tail = [l for l in (p.stdout or "").splitlines() if l.strip()][-4:]
    rc = p.returncode
    verdict = {0: "PASS", 1: "FAIL", 2: "NOT RUN", 3: "DID NOT COMPLETE"}.get(
        rc, "DID NOT COMPLETE")
    return {"gate": name, "verdict": verdict, "exit_code": rc,
            "detail": " | ".join(tail)[:600]}


def main(argv=()):
    t0 = time.time()
    before = B.verify_all()
    additivity = B.assert_additive()
    clean()

    results = []
    for mod, why in RUN_ORDER:
        print("\n== %-24s %s" % (mod, why))
        m = importlib.import_module(mod)
        importlib.reload(m)
        n = m.main()
        results.append({"generator": mod, "purpose": why,
                        "models": n if isinstance(n, int) else None})

    print("\n== in-chain invariants ==")
    rc_hk = subprocess.run(
        [sys.executable, os.path.join(W.HERE if hasattr(W, "HERE") else
                                      os.path.dirname(os.path.abspath(__file__)),
                                      "check_mxh3_hashkeys.py")],
        capture_output=True, text=True,
        env=dict(os.environ, PYTHONDONTWRITEBYTECODE="1"))
    print(rc_hk.stdout.strip()[-900:])
    inchain = {"check": "check_mxh3_hashkeys (hash-key fixpoint + per-source "
                        "completeness, both directions)",
               "verdict": {0: "PASS", 1: "FAIL", 2: "NOT RUN"}.get(rc_hk.returncode,
                                                                   "DID NOT COMPLETE"),
               "exit_code": rc_hk.returncode,
               "detail": (rc_hk.stdout or "").strip().splitlines()[-1][:400]
               if rc_hk.stdout else ""}

    after = B.verify_all()
    if after != before:
        raise AssertionError("an input MOVED during the run; STOP")

    spec = E.spec()
    tree = digest_tree(W.MODELS)
    bydir = count_models()
    status = {
        "lob": spec["lob"],
        "stage": "1",
        "generated": time.strftime("%Y-%m-%d"),
        "elapsed_seconds": round(time.time() - t0, 1),
        "map": {"file": "04_column_map.json", **before["04_column_map.json"]},
        "inputs_verified_before_and_after": True,
        "additivity_proof": additivity,
        "models_total": sum(bydir.values()),
        "models_by_directory": bydir,
        "model_tree_digest": tree,
        "generators": results,
        "generators_total": len(RUN_ORDER),
        "in_chain_invariants": inchain,
        "census": spec["census"],
        "notes_decided": spec["notes"],
        "directive_kind": spec["directive_kind"],
        "do_not_build": spec["do_not_build"],
        "dispositions": spec["refusals"],
        "anchor_resolution": spec["anchor_resolution"],
        "hop_direction_report": spec.get("hop_direction_report"),
        "fully_keyed_report": spec.get("fully_keyed_report"),
        "unresolved_total": len(spec["unresolved"]),
        "unresolved_by_kind": _by_kind(spec["unresolved"]),
        "builder_decisions": [d["id"] for d in spec["builder_decisions"]],
        "build_directives_implemented": len(spec["build_directives"]),
        "bespoke_layers": [b["name"] for b in __import__("mxh3_names").PROFILE
                           ["bespoke_layers"]],
        "containment": W.audit(),
        "load_time_assertions": {
            "emitted": 3,
            "runtime_verdict": "NOT RUN",
            "reason": "no source access in this environment: no Oracle client on PATH, no "
                      "driver importable, no TNS/wallet/ODBC config, no env var, no dbt "
                      "profile. Each assertion fails LOUDLY at first load instead.",
        },
        "gates": [],
    }

    # BUILD_STATUS first (provisional, no gate verdicts yet), so the README has
    # something to read; then the gates; then BUILD_STATUS and the README again
    # with the verdicts in. A README whose gate table lagged a build would be the
    # stale-number defect check_prose_counts exists to catch.
    W.write(os.path.join(W.ARTIFACTS, "BUILD_STATUS.json"),
            json.dumps(status, indent=1), generator="run_mxh3_build.py")
    import gen_mxh3_readme
    importlib.reload(gen_mxh3_readme)
    gen_mxh3_readme.main()

    print("\n== gates (subprocesses, PYTHONDONTWRITEBYTECODE=1, never imported) ==")
    proj = os.path.relpath(W.PROJECT, REPO)
    for name, args in (("check_patterns", [proj]),
                       ("check_prose_counts", [proj]),
                       ("check_prose_shape", [proj]),
                       ("check_internal", [proj]),
                       ("check_vault_alignment",
                        [proj, os.path.relpath(SIBLING, REPO),
                         os.path.join(B.BUNDLE_ROOT, "04_column_map.json")])):
        r = run_gate(name, args)
        status["gates"].append(r)
        print("  %-26s %-18s exit=%s" % (r["gate"], r["verdict"], r["exit_code"]))

    W.write(os.path.join(W.ARTIFACTS, "BUILD_STATUS.json"),
            json.dumps(status, indent=1), generator="run_mxh3_build.py")
    importlib.reload(gen_mxh3_readme)
    gen_mxh3_readme.main()

    print("\nmodels emitted : %d" % status["models_total"])
    print("tree sha256    : %s" % tree["tree_sha256"])
    print("  method       : %s" % tree["combining_method"])
    return status


def _by_kind(rows):
    out = {}
    for r in rows:
        out[r["kind"]] = out.get(r["kind"], 0) + 1
    return out


if __name__ == "__main__":
    main(sys.argv[1:])
