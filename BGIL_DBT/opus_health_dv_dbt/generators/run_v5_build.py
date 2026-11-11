# -*- coding: utf-8 -*-
"""The whole build, from an empty models/ directory, twice -- reproducibility proved by deletion.

  python3 generators/run_v5_build.py

1. feeds -> plan -> emit, from empty; take the tree digest
2. delete every model, run the same three again; the digest must be byte-identical
3. verify (which also re-checks that no file outside this project changed)
4. BUILD_STATUS.json
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import v5_common as C  # noqa: E402
import v5_emit  # noqa: E402
import v5_feeds  # noqa: E402
import v5_guard  # noqa: E402
import v5_plan  # noqa: E402
import v5_status  # noqa: E402
import v5_verify  # noqa: E402


def generate():
    C._CACHE.clear()
    v5_feeds.main()
    v5_plan.main()
    v5_emit.main()
    return v5_status.tree_digest()


def main():
    if not os.path.exists(v5_guard.BASELINE):
        raise SystemExit("no baseline of the other builds: run `python3 generators/v5_guard.py "
                         "baseline` BEFORE the first build, or the absolute rule cannot be checked")
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
    rc = v5_verify.main()
    print("[4] status")
    v5_status.main()
    return rc


if __name__ == "__main__":
    sys.exit(main())
