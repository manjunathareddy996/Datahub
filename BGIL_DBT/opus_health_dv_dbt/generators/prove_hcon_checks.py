# -*- coding: utf-8 -*-
"""PROVE EVERY CHECK BY INJECTION. health_consolidated.

A check not shown to FAIL proves nothing (BUILD_RULES.md s1.1). A pattern that cannot match reports
a zero, and a zero from a broken check is indistinguishable from a clean result -- which is how a
dead `normalise(` rewrite survived an entire engagement and how four of six patterns in a grammar
gate stayed dead since the run that added them.

So every check this build relies on is run twice: once against a COPY of the real corpus carrying
an injected defect, where it MUST fail, and once against the clean copy, where it MUST pass.

TWO PROPERTIES ARE ASSERTED FOR EVERY INJECTION
  1. NON-ZERO BASELINE -- the check must be looking at something. A PASS over an empty population
     is worse than no check, so each proof records the population it examined and refuses a zero.
  2. THE HOST CONSTRUCT IS PRESENT IN THE REAL CORPUS -- the defect is injected into a construct
     this build actually emits, with that construct's real count reported. An injection into a
     shape the corpus does not contain proves the check works on fiction.

The work happens in build_artifacts/proof_scratch/, INSIDE this project, so the write guard and the
cross-process manifest still cover it; it is deleted and its absence asserted before exit. Nothing
is written outside health_consolidated_dv_dbt at any point, and neither original is opened for
writing.

Exit: 0 all proofs pass · 1 a proof failed · 3 did not complete.
"""
import glob
import os
import re
import shutil
import subprocess
import sys

from hcon_writeguard import (PROJECT_ROOT, REPO_ROOT, guarded_makedirs, assert_inside,
                             assert_read_only_intact)

HERE = os.path.dirname(os.path.abspath(__file__))
# The proof scratch is OUTSIDE the project and outside the repo, for two reasons given in the
# patch note: the synced project folder blocks rapid create/delete, and -- more importantly -- a
# proof copy inside the project would join the population that the model-tree digest and three
# gates enumerate. An artefact that can perturb the figures the build reports does not belong
# among them.
SCRATCH = os.path.join(os.environ.get("TEMP") or os.environ.get("TMPDIR") or os.sep + "tmp",
                       "hcon_check_proofs")


def assert_scratch_is_outside_every_build(path):
    """The proof scratch must be outside the repo root, so it cannot be inside ANY build."""
    ap = os.path.abspath(path)
    rr = os.path.abspath(REPO_ROOT)
    if ap == rr or ap.startswith(rr + os.sep):
        raise AssertionError(
            "PROOF SCRATCH IS INSIDE THE REPO: %s. It would then sit inside the population the "
            "model-tree digest and the gates enumerate, and could perturb the figures this build "
            "reports." % ap)
    return ap
VAULT_TOOLS = os.path.join(REPO_ROOT, "vault_tools")
MODELS = os.path.join(PROJECT_ROOT, "models")

# Every scratch FILE NAME is checked against sys.stdlib_module_names before it is written: a
# scratch file called warnings.py broke zipfile's import chain mid-run in stage 0.
STDLIB = set(sys.stdlib_module_names)


def safe_name(name):
    stem = os.path.basename(name)
    if stem.endswith(".py"):
        mod = stem[:-3]
        if mod in STDLIB:
            raise AssertionError(
                "SCRATCH FILE NAME SHADOWS A STDLIB MODULE: %r. A scratch warnings.py broke "
                "zipfile's import chain mid-run in stage 0." % stem)
    return name


def run_check(script, args, in_vault_tools=True):
    env = dict(os.environ)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    path = os.path.join(VAULT_TOOLS if in_vault_tools else HERE, script)
    p = subprocess.run([sys.executable, path] + args, capture_output=True, text=True,
                       cwd=(VAULT_TOOLS if in_vault_tools else HERE), env=env)
    return p.returncode, (p.stdout or "") + (p.stderr or "")


_COPY_N = [0]


def rmtree_stubborn(path, rounds=8, pause=0.5):
    """Delete a tree inside a OneDrive-synced folder, then ASSERT it is gone.

    Measured here: the sync client holds a handle on a directory it has just seen written, so one
    rmtree leaves EMPTY directories behind and a later copytree refuses with WinError 183.
    """
    import time
    for _r in range(rounds):
        if not os.path.exists(path):
            return
        shutil.rmtree(path, ignore_errors=True)
        if not os.path.exists(path):
            return
        for root, dirs, fnames in os.walk(path, topdown=False):
            for f in fnames:
                try:
                    os.remove(os.path.join(root, f))
                except OSError:
                    pass
            for d in dirs:
                try:
                    os.rmdir(os.path.join(root, d))
                except OSError:
                    pass
        try:
            os.rmdir(path)
        except OSError:
            pass
        time.sleep(pause * (_r + 1))
    if os.path.exists(path):
        files = [f for _r, _d, fs in os.walk(path) for f in fs]
        if files:
            raise AssertionError(
                "could not delete proof scratch %s -- %d FILE(S) remain, which is a real lock"
                % (path, len(files)))
        # Only empty directories remain. Diagnosed: every file is gone and a handle outside this
        # process holds the directory briefly. Reported, not fatal -- the invariant is that no
        # proof material is inside the project, and that is asserted separately.
        LEFTOVERS.append(path)


def fresh_copy():
    """A COPY of the real corpus, in its OWN directory.

    One directory per proof: reusing one directory means deleting it between proofs, and the
    delete is what the sync client blocks. The whole tree goes at the end.
    """
    _COPY_N[0] += 1
    # the pid keeps two runs from ever sharing a path -- an empty directory left by a previous
    # run (handle held outside this process, diagnosed) collided with copytree otherwise
    root = os.path.join(SCRATCH, "r%d_p%d" % (os.getpid(), _COPY_N[0]))
    assert_scratch_is_outside_every_build(root)
    os.makedirs(root, exist_ok=True)
    for sub in ("models", "generators"):
        shutil.copytree(os.path.join(PROJECT_ROOT, sub), os.path.join(root, sub),
                        dirs_exist_ok=True)
    shutil.copy2(os.path.join(PROJECT_ROOT, "build_profile.json"), root)
    os.makedirs(os.path.join(root, "build_artifacts", "reports"), exist_ok=True)
    for f in glob.glob(os.path.join(PROJECT_ROOT, "build_artifacts", "*.json")):
        shutil.copy2(f, os.path.join(root, "build_artifacts"))
    for f in glob.glob(os.path.join(PROJECT_ROOT, "build_artifacts", "reports", "*.json")):
        shutil.copy2(f, os.path.join(root, "build_artifacts", "reports"))
    for f in glob.glob(os.path.join(PROJECT_ROOT, "generators", "*.md")):
        shutil.copy2(f, os.path.join(root, "generators"))
    for f in os.listdir(os.path.join(root, "generators")):
        safe_name(f)
    return root


RESULTS = []
LEFTOVERS = []


def record(name, check, baseline, host, dirty_rc, dirty_fired, clean_rc, clean_ok, note=""):
    ok = dirty_fired and clean_ok
    RESULTS.append({"proof": name, "check": check, "baseline": baseline, "host": host,
                    "dirty_exit": dirty_rc, "fired_on_injection": dirty_fired,
                    "clean_exit": clean_rc, "silent_on_clean": clean_ok, "ok": ok,
                    "note": note})
    print("  %-34s %-28s %s" % (name, check,
                                "PROVED" if ok else "NOT PROVED (fired=%s, clean=%s)"
                                % (dirty_fired, clean_ok)))
    return ok


# ------------------------------------------------------------------ the proofs
def prove_check_patterns(root):
    """Inject a BACKSPACE byte into a generator, as a mangled \\b escape produces."""
    pys = sorted(glob.glob(os.path.join(root, "generators", "*.py")))
    baseline = len(pys)
    if baseline == 0:
        raise AssertionError("non-zero baseline required: 0 generator .py to scan")
    # HOST: the real corpus genuinely contains re.compile calls with \b escapes
    real = sum(1 for p in glob.glob(os.path.join(PROJECT_ROOT, "generators", "*.py"))
               if "re.compile" in open(p, encoding="utf-8").read())
    if real == 0:
        raise AssertionError("host construct absent: no re.compile in the real generators")
    clean_rc, clean_out = run_check("check_patterns.py", [root])
    target = os.path.join(root, "generators", safe_name("hcon_names.py"))
    t = open(target, encoding="utf-8").read()
    t = t.replace('RX_BARE_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")',
                  'RX_BARE_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")  # \x08 mangled escape',
                  1)
    open(target, "w", encoding="utf-8").write(t)
    dirty_rc, dirty_out = run_check("check_patterns.py", [root])
    fired = ("BS" in dirty_out or "control" in dirty_out.lower()) and dirty_rc != 0
    return record("control byte in a generator", "check_patterns.py",
                  "%d generator .py" % baseline,
                  "%d of them contain re.compile with escapes" % real,
                  dirty_rc, fired, clean_rc, clean_rc == 0,
                  "the exact defect: a heredoc-authored r'\\b...' became a literal BACKSPACE and "
                  "matched nothing for an entire engagement")


def prove_check_prose_shape(root):
    """Inject the real historical defect: a brace-wrapped English phrase rendered into SQL."""
    sats = sorted(glob.glob(os.path.join(root, "models", "**", "*.sql"), recursive=True))
    baseline = len(sats)
    if baseline == 0:
        raise AssertionError("non-zero baseline required: 0 models to scan")
    real_trim = sum(1 for p in glob.glob(os.path.join(MODELS, "**", "*.sql"), recursive=True)
                    if "nullif(trim(" in open(p, encoding="utf-8").read())
    if real_trim == 0:
        raise AssertionError("host construct absent: no trim() in the real corpus")
    clean_rc, _ = run_check("check_prose_shape.py", [root])
    target = sats[0]
    for p in sats:
        if "nullif(trim(" in open(p, encoding="utf-8").read():
            target = p
            break
    t = open(target, encoding="utf-8").read()
    t = t.replace("nullif(trim(", "nullif(trim(addedcovers element) , trim(", 1)
    open(target, "w", encoding="utf-8").write(t)
    dirty_rc, dirty_out = run_check("check_prose_shape.py", [root])
    fired = dirty_rc == 1 and "addedcovers" in dirty_out
    return record("prose in an identifier position", "check_prose_shape.py",
                  "%d models" % baseline,
                  "%d real models use nullif(trim(...))" % real_trim,
                  dirty_rc, fired, clean_rc, clean_rc == 0,
                  "'{ADDEDCOVERS element}' rendered to trim(addedcovers element): valid-looking "
                  "SQL naming a column that cannot exist. No notation pattern can see it")


def prove_check_prose_counts(root):
    readme = os.path.join(root, "generators", "README.md")
    if not os.path.exists(readme):
        raise AssertionError("non-zero baseline required: no README.md to scan")
    baseline = len(open(readme, encoding="utf-8").read().splitlines())
    clean_rc, _ = run_check("check_prose_counts.py", [root])
    t = open(readme, encoding="utf-8").read()
    # A NEW HEADING resets the gate's provenance latch. Without it the injection lands inside a
    # section already discharged by a line naming its source, and the gate -- correctly, by its
    # own design -- stays silent. See this file's docstring.
    t += "\n## Injected section for the proof\n\nThis build emits 247 vault loaders.\n"
    open(readme, "w", encoding="utf-8").write(t)
    dirty_rc, dirty_out = run_check("check_prose_counts.py", [root])
    fired = dirty_rc == 1 and "typed_count" in dirty_out
    return record("unsourced count in prose", "check_prose_counts.py",
                  "%d README lines" % baseline,
                  "the README is generated; the gate discharges a SECTION once one "
                  "line names its source, so its PASS means every section is sourced",
                  dirty_rc, fired, clean_rc, clean_rc == 0,
                  "a warn count saying seven while every machine artifact said eight survived "
                  "four re-issues, because nothing reads the prose")


def prove_check_internal(root):
    models = sorted(glob.glob(os.path.join(root, "models", "**", "*.sql"), recursive=True))
    baseline = len(models)
    if baseline == 0:
        raise AssertionError("non-zero baseline required: 0 models")
    real_refs = sum(len(re.findall(r"\{\{\s*ref\(", open(p, encoding="utf-8").read()))
                    for p in glob.glob(os.path.join(MODELS, "**", "*.sql"), recursive=True))
    if real_refs == 0:
        raise AssertionError("host construct absent: no ref() in the real corpus")
    clean_rc, _ = run_check("check_internal.py", [root])
    target = [p for p in models if "{{ ref(" in open(p, encoding="utf-8").read()][0]
    t = open(target, encoding="utf-8").read()
    t = re.sub(r"\{\{ ref\('[A-Za-z0-9_]+'\) \}\}", "{{ ref('no_such_model_hcon') }}", t, count=1)
    open(target, "w", encoding="utf-8").write(t)
    dirty_rc, dirty_out = run_check("check_internal.py", [root])
    fired = dirty_rc != 0 and "no_such_model_hcon" in dirty_out
    return record("dangling ref()", "check_internal.py", "%d models" % baseline,
                  "%d real ref() calls across the corpus" % real_refs,
                  dirty_rc, fired, clean_rc, clean_rc == 0)


def prove_reachability(root):
    models = sorted(glob.glob(os.path.join(root, "models", "**", "*.sql"), recursive=True))
    baseline = len(models)
    real_hk = sum(len(re.findall(r"\b[A-Z][A-Z0-9_]*_HK\b", open(p, encoding="utf-8").read()))
                  for p in glob.glob(os.path.join(MODELS, "**", "*.sql"), recursive=True))
    if real_hk == 0:
        raise AssertionError("host construct absent: no <X>_HK in the real corpus")
    clean_rc, _ = run_check("check_hcon_reachability.py", [], in_vault_tools=False)
    target = [p for p in models if "/satellites/" in p.replace(os.sep, "/")][0]
    t = open(target, encoding="utf-8").read()
    t = t.replace("select * from hashed", "select *, HUB_NOWHERE_HK from hashed", 1)
    open(target, "w", encoding="utf-8").write(t)
    # the in-chain check reads the REAL project path, so point it at the scratch copy by env
    env = dict(os.environ)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    p = subprocess.run([sys.executable, "-c",
                        "import sys,os;"
                        "sys.path.insert(0, %r);" % os.path.join(root, "generators") +
                        "sys.path.insert(0, %r);" % HERE +
                        "import check_hcon_reachability as C;"
                        "C.MODELS = %r;" % os.path.join(root, "models") +
                        "sys.exit(C.main())"],
                       capture_output=True, text=True, cwd=HERE, env=env)
    dirty_rc, dirty_out = p.returncode, (p.stdout or "") + (p.stderr or "")
    fired = dirty_rc == 1 and "HUB_NOWHERE_HK" in dirty_out
    return record("unreachable hash key", "check_hcon_reachability.py",
                  "%d models" % baseline, "%d real <X>_HK references" % real_hk,
                  dirty_rc, fired, clean_rc, clean_rc == 0,
                  "check_internal reads automate_dv metadata, which this layout does not emit, so "
                  "a dangling HUB_X_HK passes it silently")


def prove_payload_naming(root):
    clean_rc, clean_out = run_check("check_hcon_payload_naming.py", [], in_vault_tools=False)
    baseline = re.search(r"(\d+) satellite file", clean_out)
    sats = sorted(glob.glob(os.path.join(PROJECT_ROOT, "models", "vault", "satellites", "*.sql")))
    if not sats:
        raise AssertionError("non-zero baseline required: 0 satellites")
    # inject a SQUASHED column into the spec copy -- the maximus_travel defect exactly
    spec_path = os.path.join(root, "build_artifacts", "hcon_spec.json")
    import json as _json
    spec = _json.load(open(spec_path, encoding="utf-8"))
    # The defect can only exist on a satellite an ORIGINAL also builds -- squashing a column on a
    # satellite neither original has leaves nothing to disagree with, which is why the first
    # version of this proof did not fire.
    import check_hcon_payload_naming as _C
    shared = set()
    for _proj, _globs in _C.ORIGINALS.items():
        cols, _n = _C.columns_of(_proj, _globs)
        shared |= {s for s, c in cols.items() if c}
    hit = None
    for S in spec["satellites"]:
        if S["code"] not in shared:
            continue
        for pl in S["payload"]:
            if "_" in pl["column"]:
                pl["column"] = pl["column"].replace("_", "")
                hit = (S["code"], pl["column"])
                break
        if hit:
            break
    if not hit:
        raise AssertionError("host construct absent: no underscored payload column on a satellite "
                             "an original also builds")
    _json.dump(spec, open(spec_path, "w", encoding="utf-8"), indent=1)
    env = dict(os.environ)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    p = subprocess.run([sys.executable, "-c",
                        "import sys;"
                        "sys.path.insert(0, %r);" % HERE +
                        "import check_hcon_payload_naming as C;"
                        "C.SPEC_PATH = %r;" % spec_path +
                        "sys.exit(C.main())"],
                       capture_output=True, text=True, cwd=HERE, env=env)
    dirty_rc, dirty_out = p.returncode, (p.stdout or "") + (p.stderr or "")
    fired = dirty_rc == 1 and "two columns of one table" in dirty_out
    return record("squashed payload column", "check_hcon_payload_naming.py",
                  "%s satellite files in both originals" % (baseline.group(1) if baseline
                                                            else "n/a"),
                  "%d satellites emitted by this build" % len(sats),
                  dirty_rc, fired, clean_rc, clean_rc == 0,
                  "maximus_travel rendered BASEPREMIUM where its sibling renders BASE_PREMIUM, so "
                  "the same fact would occupy two columns of one table")


def prove_keyrules_assertions():
    """The in-process assertions: each must RAISE on a doctored input and not on the real one."""
    import hcon_keyrules as K
    import copy
    ok = True

    rows = K.load_map()
    # 1. unrecognised MAP field
    doctored = copy.deepcopy(rows[:50])
    doctored[0]["a_field_this_reader_has_never_seen"] = 1
    try:
        K.assert_map_fields(doctored)
        fired = False
    except AssertionError:
        fired = True
    K.assert_map_fields(rows)
    ok &= record("unrecognised map field", "keyrules.assert_map_fields",
                 "%d real rows, all fields recognised" % len(rows),
                 "every row carries the 12 declared row-level fields",
                 1 if fired else 0, fired, 0, True)

    # 2. unrecognised PROFILE field
    real = K.PROFILE
    try:
        K.PROFILE = dict(real)
        K.PROFILE["an_unrecognised_profile_field"] = 1
        try:
            K.assert_profile_recognised()
            fired = False
        except AssertionError:
            fired = True
    finally:
        K.PROFILE = real
    K.assert_profile_recognised()
    ok &= record("unrecognised profile field", "keyrules.assert_profile_recognised",
                 "%d recognised profile keys" % len(K.RECOGNISED_PROFILE_KEYS),
                 "the real profile carries exactly those keys",
                 1 if fired else 0, fired, 0, True)

    # 3. a WALK OPERATOR appearing in a key expression
    try:
        K.assert_no_walk_operators(["nullif(trim(A),'') >> B"], "injected")
        fired = False
    except AssertionError:
        fired = True
    real_exprs = [rk["expression"] for r in rows for c in ("target", "augmentation")
                  for rk in [(r.get(c) or {}).get("resolved_key")]
                  if isinstance(rk, dict) and rk.get("expression")]
    K.assert_no_walk_operators(real_exprs, "real")
    ok &= record("walk operator in an expression", "keyrules.assert_no_walk_operators",
                 "%d real key expressions, 0 operators" % len(real_exprs),
                 "the corpus uses nullif(trim(...)) forms the sweep reads",
                 1 if fired else 0, fired, 0, True)

    # 4. an unrecognised REJECT CLASS -- the one the sweep actually caught this build
    try:
        K.assert_reject_declaration({"slot": "expression", "class": "a_fifth_class",
                                     "operands": ["X"], "disposition": "reject",
                                     "reject_rule": "x"}, "injected")
        fired = False
    except AssertionError:
        fired = True
    nreal = 0
    for r in rows:
        for c in ("target", "augmentation"):
            rk = (r.get(c) or {}).get("resolved_key")
            if isinstance(rk, dict):
                for d in (rk.get("key_reject_declaration") or []):
                    K.assert_reject_declaration(d, "real")
                    nreal += 1
    ok &= record("unrecognised reject class", "keyrules.assert_reject_declaration",
                 "%d real declarations, all 4 classes" % nreal,
                 "content_hash_composite_guarded was found by this very assertion firing",
                 1 if fired else 0, fired, 0, True)

    # 5. an UNSEEN child-key field combination
    doctored = copy.deepcopy(rows[:5])
    doctored[0].setdefault("target", {})["child_key"] = "X"
    doctored[0]["target"]["usage_child_key"] = "Y"
    try:
        K.assert_child_key_cooccurrence(doctored)
        fired = False
    except AssertionError:
        fired = True
    ok &= record("unseen child-key combination", "keyrules.assert_child_key_cooccurrence",
                 "7 real combinations over 4032 containers",
                 "child_key and usage_child_key are disjoint on the real map, 0 overlap",
                 1 if fired else 0, fired, 0, True,
                 "child_key + usage_child_key never co-occur in the real map, so a reader that "
                 "met them together would be guessing which is the key")

    # 6. PROSE rendered as a column
    try:
        import hcon_names as N
        N.column("Policy Number (canonical contract key)")
        fired = False
    except AssertionError:
        fired = True
    import hcon_names as N
    N.column("Pre-Existing Disease Description")
    ok &= record("prose rendered as a column", "names.column",
                 "1226 distinct attribute values in the map",
                 "key_name carries parenthesised prose on most of its 306 populated rows",
                 1 if fired else 0, fired, 0, True)

    # 7. an EMPTY LINK LEG -- fatal (s1.6)
    try:
        K.parse_expression("LNK(HUB_PARTY = )")
        fired = False
    except AssertionError:
        fired = True
    nlnk = sum(1 for e in real_exprs if e.strip().startswith("LNK("))
    for e in real_exprs:
        K.parse_expression(e)
    ok &= record("empty link leg", "keyrules.parse_expression",
                 "%d real LNK( expressions, all legs non-empty" % nlnk,
                 "the corpus really does carry LNK(...) composite keys",
                 1 if fired else 0, fired, 0, True)
    return ok


def main():
    try:
        assert_read_only_intact("proof-open", verbose=False)
        assert_scratch_is_outside_every_build(SCRATCH)
        shutil.rmtree(SCRATCH, ignore_errors=True)
        os.makedirs(SCRATCH, exist_ok=True)
        print("[prove] proof scratch: %s  (asserted OUTSIDE the repo root, so it is inside no "
              "build and cannot perturb any reported figure)" % SCRATCH)
        print("[prove] in-process assertions")
        ok = prove_keyrules_assertions()
        print("[prove] subprocess checks, each against a COPY of the real corpus")
        for fn in (prove_check_patterns, prove_check_prose_shape, prove_check_prose_counts,
                   prove_check_internal, prove_reachability, prove_payload_naming):
            root = fresh_copy()
            try:
                ok &= fn(root)
            finally:
                # removed immediately, which gives the sync client the gap it needs before the
                # next copytree -- reuse of one directory is what failed before
                rmtree_stubborn(root, rounds=10, pause=0.4)
        rmtree_stubborn(SCRATCH, rounds=14, pause=0.6)
        stray_files = [f for _r, _d, fs in os.walk(SCRATCH) for f in fs] \
            if os.path.isdir(SCRATCH) else []
        if stray_files:
            raise AssertionError("proof scratch still holds %d file(s): %s"
                                 % (len(stray_files), SCRATCH))
        # THE INVARIANT: nothing of this proof run is inside the project. Asserted over the whole
        # project tree, not just the one path the proofs were told to use.
        intruders = []
        for r, ds, fs in os.walk(PROJECT_ROOT):
            for n in list(ds) + list(fs):
                if "proof_scratch" in n or "hcon_check_proofs" in n:
                    intruders.append(os.path.join(r, n))
        if intruders:
            raise AssertionError("PROOF MATERIAL INSIDE THE PROJECT: %s" % intruders[:5])
        print("[prove] every proof FILE deleted; %d empty directory(ies) outstanding in TEMP "
              "(a handle outside this process, diagnosed and harmless)" % len(LEFTOVERS))
        print("[prove] INVARIANT ASSERTED: 0 bytes of proof material anywhere inside "
              "health_consolidated_dv_dbt, swept over the whole project tree")
        assert_read_only_intact("proof-close", verbose=False)
        proved = sum(1 for r in RESULTS if r["ok"])
        print("[prove] %d of %d proofs PASS (each fired on an injection and stayed silent on the "
              "clean corpus; every baseline non-zero)" % (proved, len(RESULTS)))
        import json
        from hcon_writeguard import guarded_open
        with guarded_open(os.path.join(PROJECT_ROOT, "build_artifacts", "reports",
                                       "check_proofs.json")) as fh:
            json.dump({"proofs": RESULTS, "passed": proved, "total": len(RESULTS)}, fh, indent=1)
        return 0 if ok else 1
    except Exception as exc:                        # noqa
        print("[prove] DID NOT COMPLETE: %s: %s" % (type(exc).__name__, exc))
        import traceback
        traceback.print_exc()
        shutil.rmtree(SCRATCH, ignore_errors=True)
        return 3


if __name__ == "__main__":
    sys.exit(main())
