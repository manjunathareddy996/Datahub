# -*- coding: utf-8 -*-
"""THE UNRATIFIED TRACK. health_consolidated.

A satellite unit lands here when its payload is a PROPOSAL: the attribute is not declared on that
satellite in data_7.js, or it arrived through an `augmentation` block rather than `target.satellite`.
One satellite may legitimately have BOTH a ratified unit (in models/vault/satellites) and an
unratified one here -- the track is a property of the BLOCK, not of the satellite.

Nothing here is part of the ratified vault, every model says so in its own header, and every model
carries config(tags=['unratified']) so the two tracks can never be selected together by accident.

Reads build_artifacts/hcon_spec.json. Never the map.
"""
import collections
import json
import os
import sys

import gen_hcon_vault as V
import hcon_names as N
from hcon_writeguard import PROJECT_ROOT, guarded_open, guarded_makedirs

SPEC_PATH = os.path.join(PROJECT_ROOT, "build_artifacts", "hcon_spec.json")
OUT_DIR = os.path.join(PROJECT_ROOT, "models", "augmented")


def render(S):
    sql = V.render_satellite(S, generator_label="gen_hcon_augmented.py")
    if sql is None:
        return None
    sql = sql.replace("{{ config(materialized='incremental') }}",
                      "{{ config(materialized='incremental', tags=['unratified']) }}", 1)
    return sql


def main():
    with open(SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    guarded_makedirs(OUT_DIR)
    built = 0
    skipped = []
    collide = []
    ratified_names = {S["code"] for S in spec["satellites"] if S["track"] != "unratified"}
    for S in spec["satellites"]:
        if S["track"] != "unratified":
            continue
        sql = render(S)
        if sql is None:
            why = ("no anchor: no block declares one and data_7.js declares no parent"
                   if not S["anchor"] else
                   "no payload attribute survived" if not S["payload"] else
                   "every one of its %d feeder(s) lacks an anchor key slot, so no row of it can "
                   "reach %s" % (len(S["feeders"]), S["anchor"]))
            skipped.append((S, why))
            continue
        if S["code"] in ratified_names:
            # the SAME satellite has a ratified unit too. Filed under a distinct model name so one
            # track can never silently overwrite the other's table.
            name = S["code"].lower() + "__unratified"
            collide.append(S["code"])
        else:
            name = S["code"].lower()
        with guarded_open(os.path.join(OUT_DIR, name + ".sql")) as fh:
            fh.write(sql)
        built += 1
    print("[augmented] unratified satellites: %d models written" % built)
    print("[augmented] %d of them share a code with a RATIFIED unit and are suffixed "
          "__unratified so one track cannot overwrite the other's table: %s"
          % (len(collide), sorted(collide)[:8] + (["..."] if len(collide) > 8 else [])))
    for S, why in skipped:
        print("  NOT BUILT %-42s %s" % (S["code"], why))
    byreason = collections.Counter(w.split(":")[0].split(",")[0] for _S, w in skipped)
    print("[augmented] unratified satellites NOT BUILT: %d -- %s" % (len(skipped), dict(byreason)))
    print("[augmented] unit = one (satellite, track) build unit; population = the %d units in "
          "the spec, of which %d are unratified"
          % (len(spec["satellites"]),
             sum(1 for S in spec["satellites"] if S["track"] == "unratified")))
    return 0


if __name__ == "__main__":
    sys.exit(main())
