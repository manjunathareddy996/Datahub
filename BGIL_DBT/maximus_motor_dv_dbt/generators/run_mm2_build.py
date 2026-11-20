# -*- coding: utf-8 -*-
"""The whole build, from an empty models/ directory, twice -- reproducibility proved by deletion.

  python3 generators/run_mm2_build.py
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mm2_common as C  # noqa: E402
import mm2_emit  # noqa: E402
import mm2_feeds  # noqa: E402
import mm2_guard  # noqa: E402
import mm2_plan  # noqa: E402
import mm2_status  # noqa: E402
import mm2_verify  # noqa: E402


def generate():
    C._CACHE.clear()
    mm2_feeds.main()
    mm2_plan.main()
    mm2_emit.main()
    return mm2_status.tree_digest()


def main():
    if not os.path.exists(mm2_guard.BASELINE):
        raise SystemExit("no baseline of the other builds: run `python3 generators/mm2_guard.py "
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
    rc = mm2_verify.main()
    print("[4] status")
    mm2_status.main()
    return rc


if __name__ == "__main__":
    sys.exit(main())
