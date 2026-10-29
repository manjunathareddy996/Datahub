# -*- coding: utf-8 -*-
"""gen_mt_hopviews.py -- WALK-ONLY CASTS.

One cast per view that appears anywhere on a walk and is NEVER a map row's table_name, including
the intervening levels no expression names (BUILD_RULES 6, layer 2).

This is the layer BUILD_RULES 6.1 exists for: a view can be in the map and have no cast, and --
far more often here -- a view can be in no row of the map and still owe one. Sizing the cast layer
from the views the map names under-builds it; sizing it from NAMED walk destinations alone still
under-builds it, because a named destination skips levels.

It reuses cast_body() from gen_mt_staging so the two halves of one layer cannot drift.
"""
import sys

import mt_names as N
import mt_keyrules as K
import gen_mt_staging as L1

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


def main():
    spec = L1.load_spec()
    walk_only = spec["walk_only_views"]
    provisioned = set(spec["provisioned_not_joined"])

    overlap = sorted(set(walk_only) & set(spec["map_views"]))
    if overlap:
        raise SystemExit("LAYER OVERLAP: %d view(s) would be written by both cast generators: %s"
                         % (len(overlap), overlap[:5]))

    joined, prov = [], []
    for v in walk_only:
        if v in provisioned:
            why = ("This view is on the PARENT CHAIN between a hop's start and its named "
                   "destination. Under FK_HOP_MODE='document_handle' (BD1) the emitted join goes "
                   "straight to the destination on the document handle, so no resolver joins this "
                   "cast today; it is provisioned so BD1 is reversible in one line (BD2).")
            prov.append(v)
        else:
            why = ("This view is NEVER a map row's table_name. It exists because a walk passes "
                   "through it -- BUILD_RULES 6.1.")
            joined.append(v)
        path = N.model_path("cast", N.model_name("cast", v))
        N.write_model(path, L1.cast_body(v, spec["views"][v], why))

    print("gen_mt_hopviews (walk-only casts): %d" % len(walk_only))
    print("  joined by a resolver today      : %d" % len(joined))
    print("  provisioned, not joined (BD2)   : %d" % len(prov))
    for v in prov:
        print("      %s" % N.short_view(v))
    print("  These are NOT dead models: they are the reversal path for BD1. Set")
    print("  FK_HOP_MODE = 'parent_chain' in mt_keyrules.py and every one of them is joined.")
    return walk_only


if __name__ == "__main__":
    main()
