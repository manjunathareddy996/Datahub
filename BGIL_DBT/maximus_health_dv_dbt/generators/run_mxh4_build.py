# -*- coding: utf-8 -*-
"""The whole build, from an empty models/ directory, twice -- reproducibility proved by deletion.

  python3 generators/run_mxh4_build.py
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mxh4_common as C  # noqa: E402
import mxh4_emit  # noqa: E402
import mxh4_feeds  # noqa: E402
import mxh4_guard  # noqa: E402
import mxh4_plan  # noqa: E402
import mxh4_status  # noqa: E402
import mxh4_verify  # noqa: E402


def generate():
    C._CACHE.clear()
    mxh4_feeds.main()
    mxh4_plan.main()
    mxh4_emit.main()
    return mxh4_status.tree_digest()


def main():
    if not os.path.exists(mxh4_guard.BASELINE):
        raise SystemExit("no baseline of the other builds: run `python3 generators/mxh4_guard.py "
                         "baseline` BEFORE the first build")
    print("[1] generate from empty")
    C.wipe_models()
    d1, n1 = generate()
    print("    digest %s over %d models" % (d1, n1))
    print("[2] delete every model and generate again")
    C.wipe_models()
    d2, n2 = generate()
    if (d1, n1) != (d2, n2):
        raise SystemExit("NOT REPRODUCIBLE: %s/%d then %s/%d" % (d1, n1, d2, n2))
    print("    reproduced byte-identically: %s" % d2)
    C.write_json("reproducibility.json", {"method": "delete models/, regenerate, compare tree digest",
                                          "first": d1, "second": d2, "models": n2, "status": "PASS"})
    print("[3] verify")
    rc = mxh4_verify.main()
    print("[4] status")
    mxh4_status.main()
    return rc


if __name__ == "__main__":
    sys.exit(main())
