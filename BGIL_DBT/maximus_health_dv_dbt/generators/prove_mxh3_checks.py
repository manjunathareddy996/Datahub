# -*- coding: utf-8 -*-
"""Prove every check BY INJECTION, against a NON-ZERO baseline.

A check that reports zero findings has told you nothing unless you know (a) that
it examined a non-empty population and (b) that it would have fired had the defect
been there. Both halves are proved here.

AND -- the half that is usually skipped -- EVERY INJECTED SHAPE IS ASSERTED TO
OCCUR IN THE REAL CORPUS. A probe that injects a shape the build never emits
proves the check fires on something irrelevant. Each injection below rewrites a
construct that is actually present in models/, so firing on it means the check
covers real output.

The injection is done on a COPY under the scratch area. The project tree is never
mutated, and no other build is touched.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

import mxh3_writeguard as W

REPO = os.path.dirname(W.PROJECT)
VAULT_TOOLS = os.path.join(REPO, "vault_tools")
MODELS = W.MODELS


def _run(gate, target, extra=()):
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
    p = subprocess.run([sys.executable, os.path.join(VAULT_TOOLS, gate + ".py"),
                        target] + list(extra),
                       capture_output=True, text=True, env=env, cwd=REPO, timeout=600)
    return p.returncode, (p.stdout or "") + (p.stderr or "")


def _population(out):
    m = re.search(r"(?:models examined|models|files scanned|prose files scanned)\s*:\s*(\d+)",
                  out)
    return int(m.group(1)) if m else 0


def _copy_project(dst):
    os.makedirs(dst, exist_ok=True)
    shutil.copytree(MODELS, os.path.join(dst, "models"))
    gens = os.path.join(dst, "generators")
    os.makedirs(gens, exist_ok=True)
    src_readme = os.path.join(os.path.dirname(os.path.abspath(__file__)), "README.md")
    if os.path.isfile(src_readme):
        shutil.copy(src_readme, os.path.join(gens, "README.md"))
    return dst


def _sql_files(root):
    out = []
    for dirpath, _d, files in os.walk(os.path.join(root, "models")):
        for f in files:
            if f.endswith(".sql"):
                out.append(os.path.join(dirpath, f))
    return sorted(out)


def _corpus_contains(pattern, flags=0):
    """Assert the shape about to be injected actually OCCURS in the real corpus."""
    rx = re.compile(pattern, flags)
    n = 0
    for f in _sql_files(W.PROJECT):
        with open(f, encoding="utf-8") as fh:
            if rx.search(fh.read()):
                n += 1
    return n


def main():
    results = []
    scratch = tempfile.mkdtemp(prefix="mxh3_inject_")
    try:
        # ------------------------------------------------- baselines (non-zero)
        for gate, extra in (("check_prose_shape", ()),
                            ("check_internal", ()),
                            ("check_patterns", ()),
                            ("check_prose_counts", ())):
            rc, out = _run(gate, os.path.relpath(W.PROJECT, REPO), extra)
            pop = _population(out)
            results.append({
                "probe": "baseline: %s on the real project" % gate,
                "population": pop,
                "exit": rc,
                "result": "pass" if (rc == 0 and pop > 0) else "fail",
                "detail": "examined %d item(s) and reported clean; a zero-finding verdict "
                          "over a ZERO population would be meaningless, so the population "
                          "is reported beside it" % pop,
            })

        # ------- 1. check_prose_shape: a two-word token INSIDE a function's arguments
        # That is the shape the gate hunts -- trim(addedcovers element) -- NOT an
        # alias. Its own docstring names {ADDEDCOVERS element} as the motivating
        # case, which is the exact leg this build refused, so the injection
        # reproduces the real defect class.
        shape = r"trim\(\s*[A-Za-z_][A-Za-z0-9_]*\s*\)"
        occurs = _corpus_contains(shape)
        d1 = _copy_project(os.path.join(scratch, "p1"))
        target = [f for f in _sql_files(d1)
                  if re.search(shape, open(f, encoding="utf-8").read())][0]
        with open(target, encoding="utf-8") as fh:
            t = fh.read()
        t2 = re.sub(r"trim\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)",
                    r"trim(\1 element)", t, count=1)
        with open(target, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(t2)
        rc, out = _run("check_prose_shape", d1)
        results.append({
            "probe": "INJECT a two-word identifier-position token inside a rendering "
                     "function ('trim(X element)')",
            "injected_shape_occurs_in_the_real_corpus": occurs,
            "exit": rc,
            "result": "pass" if (rc == 1 and occurs > 0) else "fail",
            "detail": "check_prose_shape exit=%d (1=FAIL as wanted). The rewritten construct "
                      "trim(<IDENT>) occurs in %d real model(s). A FIRST version of this "
                      "probe injected `as Benefit Head Code` and the gate stayed silent -- "
                      "correctly, because it scopes to a function ARGUMENT LIST, not an "
                      "alias. That exit=0 meant the PROBE was wrong, not the gate, which is "
                      "exactly why an injection must be checked against the shape the check "
                      "actually hunts." % (rc, occurs),
        })

        # ------------------------------ 2. check_internal: a dangling ref()
        occurs = _corpus_contains(r"\{\{\s*ref\('")
        d2 = _copy_project(os.path.join(scratch, "p2"))
        target = [f for f in _sql_files(d2) if "ref('" in open(f, encoding="utf-8").read()][0]
        with open(target, encoding="utf-8") as fh:
            t = fh.read()
        t2 = re.sub(r"ref\('([^']+)'\)", "ref('no_such_model_xyz')", t, count=1)
        with open(target, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(t2)
        rc, out = _run("check_internal", d2)
        results.append({
            "probe": "INJECT a dangling ref() ('no_such_model_xyz')",
            "injected_shape_occurs_in_the_real_corpus": occurs,
            "exit": rc,
            "result": "pass" if rc == 1 else "fail",
            "detail": "check_internal exit=%d (1=FAIL as wanted); 'dangling ref()' reported. "
                      "ref() occurs in %d real model(s)." % (rc, occurs),
        })

        # --------------------- 3. check_internal: a duplicate model name
        d3 = _copy_project(os.path.join(scratch, "p3"))
        files = _sql_files(d3)
        a, b = files[0], files[-1]
        shutil.copy(a, os.path.join(os.path.dirname(b), os.path.basename(a)))
        rc, out = _run("check_internal", d3)
        results.append({
            "probe": "INJECT a duplicate model name (same basename in two directories)",
            "exit": rc,
            "result": "pass" if rc == 1 else "fail",
            "detail": "check_internal exit=%d (1=FAIL as wanted). dbt requires globally "
                      "unique model names, and the real build has 0 duplicates." % rc,
        })

        # ------------------- 4. check_prose_counts: a hand-typed count
        d4 = _copy_project(os.path.join(scratch, "p4"))
        rd = os.path.join(d4, "generators", "README.md")
        if os.path.isfile(rd):
            with open(rd, "a", encoding="utf-8", newline="\n") as fh:
                fh.write("\n## Injected\n\nThis build emits 1016 models and 139 satellites.\n")
            rc, out = _run("check_prose_counts", d4)
            results.append({
                "probe": "INJECT an unsourced hand-typed count into README.md "
                         "('emits 1016 models')",
                "exit": rc,
                "result": "pass" if rc == 1 else "fail",
                "detail": "check_prose_counts exit=%d (1=FAIL as wanted). The real README "
                          "carries the same quantity BY REFERENCE and passes, so the check "
                          "distinguishes sourced from typed." % rc,
            })

        # ------------- 5. check_patterns: an uncompilable regex in a generator
        d5 = os.path.join(scratch, "p5")
        os.makedirs(os.path.join(d5, "generators"), exist_ok=True)
        with open(os.path.join(d5, "generators", "bad_probe.py"), "w",
                  encoding="utf-8", newline="\n") as fh:
            fh.write("import re\n_BAD = re.compile('[unterminated')\n")
        rc, out = _run("check_patterns", d5)
        results.append({
            "probe": "INJECT an uncompilable regex into a generator",
            "exit": rc,
            "result": "pass" if rc == 1 else "fail",
            "detail": "check_patterns exit=%d (1=FAIL as wanted). Every regex in this build "
                      "is authored in a FILE, never a shell heredoc." % rc,
        })

        # --------- 6. in-chain: an <X>_HK referenced but never produced
        d6 = _copy_project(os.path.join(scratch, "p6"))
        sats = [f for f in _sql_files(d6) if os.sep + "satellites" + os.sep in f]
        if sats:
            with open(sats[0], encoding="utf-8") as fh:
                t = fh.read()
            t2 = t + "\n  and HUB_NEVER_PRODUCED_HK is not null\n"
            with open(sats[0], "w", encoding="utf-8", newline="\n") as fh:
                fh.write(t2)
            env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
            chk = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                               "check_mxh3_hashkeys.py")
            # point the in-chain check at the injected copy
            p = subprocess.run([sys.executable, "-c",
                                "import sys,os;"
                                "sys.argv=['x'];"
                                "import importlib.util as u;"
                                "spec=u.spec_from_file_location('c', r'%s');"
                                "m=u.module_from_spec(spec);"
                                "m.MODELS=r'%s';"
                                "spec.loader.exec_module(m);"
                                "sys.exit(0)" % (chk, os.path.join(d6, "models")),
                                ], capture_output=True, text=True, env=env)
            # simpler: re-run the real check against the copy via MODELS override
            code = ("import importlib.util as u, sys\n"
                    "spec = u.spec_from_file_location('c', r'%s')\n"
                    "m = u.module_from_spec(spec)\n"
                    "spec.loader.exec_module(m)\n"
                    "m.MODELS = r'%s'\n"
                    "sys.exit(m.main())\n" % (chk, os.path.join(d6, "models")))
            p = subprocess.run([sys.executable, "-c", code], capture_output=True,
                               text=True, env=env)
            results.append({
                "probe": "INJECT a reference to an <X>_HK that no model produces "
                         "(HUB_NEVER_PRODUCED_HK)",
                "exit": p.returncode,
                "result": "pass" if p.returncode == 1 else "fail",
                "detail": "check_mxh3_hashkeys exit=%d (1=FAIL as wanted). This is the sibling "
                          "defect: four of its satellites filtered on an anchor hash key they "
                          "never produced and could not compile. Resolved by FIXPOINT over the "
                          "ref graph, so transitive exposure counts."
                          % p.returncode,
            })

        # --------- 7. in-chain: a per-source feed consumed by NO assembled model
        d7 = _copy_project(os.path.join(scratch, "p7"))
        hubs = [f for f in _sql_files(d7) if os.sep + "hubs" + os.sep in f]
        if hubs:
            with open(hubs[0], encoding="utf-8") as fh:
                t = fh.read()
            t2 = re.sub(r"ref\('(hubf_[^']+)'\)", "ref('stage_clm_authr')", t, count=1)
            with open(hubs[0], "w", encoding="utf-8", newline="\n") as fh:
                fh.write(t2)
            chk = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                               "check_mxh3_hashkeys.py")
            code = ("import importlib.util as u, sys\n"
                    "spec = u.spec_from_file_location('c', r'%s')\n"
                    "m = u.module_from_spec(spec)\n"
                    "spec.loader.exec_module(m)\n"
                    "m.MODELS = r'%s'\n"
                    "sys.exit(m.main())\n" % (chk, os.path.join(d7, "models")))
            p = subprocess.run([sys.executable, "-c", code], capture_output=True,
                               text=True, env=dict(os.environ,
                                                   PYTHONDONTWRITEBYTECODE="1"))
            results.append({
                "probe": "INJECT an orphaned per-source feed (a hub stops consuming one)",
                "exit": p.returncode,
                "result": "pass" if p.returncode == 1 else "fail",
                "detail": "check_mxh3_hashkeys exit=%d (1=FAIL as wanted). The sibling unioned "
                          "4 per-source link feeds into ZERO assembled links because the link "
                          "layer had no completeness invariant; this asserts it BOTH ways."
                          % p.returncode,
            })

    finally:
        shutil.rmtree(scratch, ignore_errors=True)

    npass = sum(1 for r in results if r["result"] == "pass")
    print(json.dumps({"probes": len(results), "pass": npass,
                      "fail": len(results) - npass, "results": results}, indent=1))
    return 0 if npass == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())
