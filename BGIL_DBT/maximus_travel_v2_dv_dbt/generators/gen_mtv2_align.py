# -*- coding: utf-8 -*-
"""gen_mtv2_align.py -- DECLARED BESPOKE LAYER: the augmented-track alignment shim.

build_profile.bespoke_layers[0], quoted:

    "OPUS travel_dv_dbt already builds 12 SAT_AUG_* satellites. 94 augmentation rows land on 9
     concepts OPUS already augments, so they must be emitted INTO the OPUS-named SAT_AUG_<X> with
     OPUS's src_pk, single-active grain and bare HASHDIFF, extending its payload, rather than into
     a Maximus-side second satellite. The standard augmented layer builds per-map and cannot
     express that; declared exception under BUILD_RULES 6.5, required by 7.7."

It runs AFTER gen_mtv2_augmented.py, which wipes the augmented directories. Running it before
would write the models and then have them deleted -- leaving a build that reports a satellite it
does not have. The two generators partition the augmented satellites by whether the sibling builds
the concept, so neither can write the other's model; selfcheck_mtv2.py asserts the partition.

The sibling's contract is re-derived from travel_dv_dbt itself on every run. A check that reads
the profile's copy of the sibling's conventions is an echo, not a check (BUILD_RULES 7).
"""
import sys

import mtv2_names as N
import gen_mtv2_augmented as A

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


def main():
    counts, unbuilt, aligned, collisions = A.main(
        only_aligned=True,
        label="gen_mtv2_align (DECLARED BESPOKE -- augmented-track alignment shim, 7.7)")
    sib = N.sibling_satellites()
    aug = sorted(n for n, v in sib.items() if v["track"] == "augmented")
    print("  sibling augmented satellites available to align to: %d" % len(aug))
    print("  every one of them is single-active, has no child key, keys on a HUB key and writes a")
    print("  bare HASHDIFF -- including the two LNK_-named ones, which key on PARTY_HKEY and not")
    print("  on a link key. Re-counted from the build this run, not taken from the profile.")
    print("")
    print("  SHARED-SATELLITE HASHDIFF EXPOSURE (BUILD_RULES 12, routed to the build owner):")
    print("  %d satellite(s) here are written by BOTH this build and travel_dv_dbt. Each writer"
          % len(aligned))
    print("  computes HASHDIFF over ITS OWN payload column list, so a row written by one and read")
    print("  by the other compares as changed on every load. This build matches the sibling's")
    print("  hashdiff COLUMN NAME (BD7); it cannot match its column LIST without declaring")
    print("  attributes it does not populate. Reported, not resolved.")
    return counts, unbuilt, aligned, collisions


if __name__ == "__main__":
    main()
