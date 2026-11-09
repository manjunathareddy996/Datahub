# -*- coding: utf-8 -*-
"""The build. Runs every stage in order, from empty, and writes what it did.

FROM EMPTY, every time. The models tree is deleted before anything is written, because
reproducibility is proved by DELETION: a build that can only regenerate on top of its own previous
output is not reproducible, it is incremental, and the difference is invisible until someone needs
to rebuild from a clean checkout.
"""
import collections
import io
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hcon4_emit as E                                             # noqa: E402

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


def run(script):
    r = subprocess.run([sys.executable, "-I", os.path.join(HERE, script)],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.returncode != 0:
        print(r.stdout)
        print(r.stderr, file=sys.stderr)
        raise SystemExit("STAGE FAILED: %s" % script)
    return r.stdout


def main():
    print("=" * 92)
    print("BUILD health_consolidated_v4_dv_dbt -- the central-view architecture")
    print("=" * 92)

    print()
    print("stage 0: inputs and profile")
    print(run("amend_hcon4_profile.py").rstrip())

    print()
    print("stage 1: the stitch plan (the rule, applied)")
    out = run("hcon4_plan.py")
    for line in out.splitlines():
        if line.strip() and not line.startswith("="):
            print("  " + line.strip() if not line.startswith("  ") else line)

    print()
    print("stage 2: emit the models, from empty")
    import hcon4_plan                                              # noqa: F401
    E.wipe_models()
    import gen_hcon4_staging
    import gen_hcon4_stitched
    import gen_hcon4_stage
    import gen_hcon4_vault
    import gen_hcon4_augmented
    import gen_hcon4_assertions
    gen_hcon4_staging.main()
    gen_hcon4_stitched.main()
    gen_hcon4_stage.main()
    gen_hcon4_vault.main()
    gen_hcon4_augmented.main()
    gen_hcon4_assertions.main()

    reg = E.write_register()
    print()
    print("  register          : %d entry/entries refused rather than defaulted" % reg["count"])
    for k, c in sorted(reg["by_kind"].items()):
        print("        %-48s %d" % (k, c))
    print("     by whose call  : %s" % reg["by_whose_call"])

    counts = collections.Counter()
    for root, _dirs, files in os.walk(E.MODELS):
        for f in files:
            if f.endswith(".sql"):
                rel = os.path.relpath(root, E.MODELS).replace("\\", "/")
                counts[rel] += 1
    print()
    print("  models emitted:")
    for k in sorted(counts):
        print("     %-26s %4d" % (k, counts[k]))
    print("     %-26s %4d" % ("TOTAL", sum(counts.values())))
    return 0


if __name__ == "__main__":
    sys.exit(main())
