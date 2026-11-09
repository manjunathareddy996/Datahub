# -*- coding: utf-8 -*-
"""WALK-ONLY CASTS -- casts for views that appear ANYWHERE on a walk, including intervening levels
no expression names. health_consolidated.

THIS LAYER IS EMPTY, AND THE ZERO IS PROVEN RATHER THAN OMITTED.

The layer exists in this file because omitting the file would make the absence of the layer
indistinguishable from an oversight. A walk-bearing grammar needs this layer badly -- a named
destination may skip levels, and every intervening level still needs a cast (BUILD_RULES.md s4) --
so the decision not to build it has to be a MEASUREMENT, not a memory.

The measurement: every walk operator counts ZERO over every key-bearing string in the settled map.
hcon_keyrules.assert_no_walk_operators sweeps the operator SET and RAISES if any of them appears,
so the day a walk arrives this build fails loudly instead of silently skipping levels.
"""
import json
import os
import sys

import hcon_keyrules as K
from hcon_writeguard import PROJECT_ROOT

SPEC_PATH = os.path.join(PROJECT_ROOT, "build_artifacts", "hcon_spec.json")


def main():
    with open(SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    counts = spec["meta"]["walk_operator_counts"]
    # re-prove it here, from the map, rather than trusting the spec's copy
    rows = K.load_map()
    strings = []
    for r in rows:
        for cont in ("target", "augmentation"):
            o = r.get(cont)
            if not isinstance(o, dict):
                continue
            rk = o.get("resolved_key")
            if isinstance(rk, dict) and isinstance(rk.get("expression"), str):
                strings.append(rk["expression"])
            for f in ("child_key", "child_key_value", "usage_child_key"):
                v = o.get(f)
                if isinstance(v, str):
                    strings.append(v)
    reproven = K.assert_no_walk_operators(strings, "gen_hcon_hopviews re-proof")
    if reproven != counts:
        raise AssertionError("walk-operator counts differ between the spec and this re-proof: "
                             "%s vs %s" % (counts, reproven))
    print("[hopviews] walk-only casts: 0 models.")
    print("[hopviews] THE ZERO IS PROVEN, not assumed. Operator counts over %d key-bearing "
          "strings: %s" % (len(strings), reproven))
    print("[hopviews] population = resolved_key.expression + child_key + child_key_value + "
          "usage_child_key, every container of every one of the %d map rows. "
          "MATCHER = literal substring per operator." % len(rows))
    print("[hopviews] profile.hierarchy_walk_token = %s"
          % K.PROFILE["hierarchy_walk_token"])
    print("[hopviews] If a walk operator ever appears, assert_no_walk_operators RAISES and this "
          "layer must be built before the build can proceed -- a named destination may skip "
          "levels and every intervening level needs its own cast (s4).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
