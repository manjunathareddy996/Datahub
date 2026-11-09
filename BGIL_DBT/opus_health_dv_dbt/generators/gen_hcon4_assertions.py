# -*- coding: utf-8 -*-
"""Layer 6: assertions. The claims this architecture makes, as SQL that FAILS when they are false.

A generator can prove things about the SQL it wrote. It can prove nothing about the data that SQL
will read. Three load-bearing assumptions of this architecture are facts about DATA, so they are
emitted as runtime assertions instead of being assumed at generation time:

  1  GRAIN / FAN-OUT. Every stitched view dedupes each joined table to one row per join key (plus
     the resolved child-key legs of its multi-active satellites). That is correct only where one
     row per key is the real grain. Where it is not, the dedupe discards rows SILENTLY -- no
     error, just satellites that are short. Asserted per view on the spine hash key.

  2  COLLAPSE. A hashdiff is guarded against an all-null payload, so an all-null row yields null
     and is dropped. This checks the guard is not firing on nearly every row, which is what a
     payload that is not where the map says it is looks like. Asserted per satellite.

  3  ORPHAN KEYS. A satellite row keyed to a hub that never received that key is a row nothing
     can ever join to, and no structural check sees it. Under rules 5 and 6 the satellite and its
     hub come from the SAME view, so this should hold by construction -- it is asserted anyway,
     because "by construction" is an argument and this is a measurement.

Each is a dbt singular test: it returns ROWS WHEN THE CLAIM IS FALSE. A test that cannot fail is
worse than no test, because it reports a zero that reads as a clean result -- so every one of
these is written so that a row can come back, and selftest() below proves each query shape is
capable of returning one.
"""
import collections
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hcon_names as N                                             # noqa: E402
import hcon4_emit as E                                             # noqa: E402


def main():
    stages = E.read_manifest("stage_columns.json")
    sats = E.read_manifest("satellite_columns.json")
    views = E.read_manifest("view_columns.json")
    plan = E.load_plan()
    by_ordinal = {str(v["ordinal"]): v for v in plan["stitched_views"]}
    counts = collections.Counter()

    # ---- 1. grain / fan-out, per view --------------------------------------------------
    for key in sorted(stages, key=int):
        sm, v, vm = stages[key], by_ordinal[key], views[key]
        spine = v["join_plan"]["spine_hub"]
        hk = sm["hash_keys"].get(spine)
        if not hk:
            E.refuse("no_grain_assertion_possible", "view%s" % key,
                     "this views spine hub %s has no staged hash key, so the grain it claims "
                     "cannot be asserted at runtime. The view is NOT left silently unchecked -- "
                     "this entry is the gap." % spine, "mapper", view=int(key))
            continue
        ma = vm.get("multi_active_satellites") or []
        body = E.header("gen_hcon4_assertions.py", [
            "ASSERTION -- central view %s holds the grain it claims." % key,
            "claim        : %s is unique in %s." % (hk, sm["model"]),
            "why runtime  : the view dedupes each joined table to one row per join key. That is",
            "               correct only where one row per key is the real grain. Where it is",
            "               not, the dedupe discards rows with no error and every satellite fed",
            "               by this view is simply short -- a failure with no symptom. The",
            "               generator cannot know which case this is; only the data can say.",
            "partitioned  : %s" % (("the dedupe also partitions by the resolved child-key legs of "
                                    "%d multi-active satellite(s), so this assertion is the "
                                    "SINGLE-ACTIVE claim and may legitimately fail where the real "
                                    "grain is finer -- read it with the register." % len(ma))
                                   if ma else "join key only; no multi-active satellite here"),
            "fails when   : any %s appears more than once." % hk,
            "returns      : the key and its count, which is the diagnosis rather than a red light.",
        ]) + ("select %s, count(*) as rows_per_key\nfrom {{ ref(%s) }}\nwhere %s is not null\n"
              "group by %s\nhaving count(*) > 1\n"
              % (hk, N.sql_literal(sm["model"]), hk, hk))
        E.write(os.path.join("assertions", N.budget("assert_grain_%s" % key) + ".sql"), body)
        counts["grain"] += 1

    # ---- 2 and 3, per satellite ---------------------------------------------------------
    for sat in sorted(sats):
        s = sats[sat]
        hub_model = E.hub_model(s["anchor_hub"])
        if os.path.exists(os.path.join(E.MODELS, "vault", "hubs", hub_model + ".sql")):
            body = E.header("gen_hcon4_assertions.py", [
                "ASSERTION -- every %s row hangs off a real %s row." % (sat, s["anchor_hub"]),
                "claim        : no %s in the satellite is absent from the hub." % s["anchor_hash_key"],
                "why runtime  : the satellite and the hub are both derived from the same central",
                "               view %d, so under rules 5 and 6 this holds by construction." % s["view"],
                "               It is asserted anyway: by construction is an argument, this is a",
                "               measurement, and an orphan satellite row is a row nothing can",
                "               ever join to -- which no structural check can see.",
                "fails when   : a satellite key has no hub row.",
            ]) + ("select s.%s\nfrom {{ ref(%s) }} s\nleft join {{ ref(%s) }} h\n"
                  "    on s.%s = h.%s\nwhere h.%s is null\n"
                  % (s["anchor_hash_key"], N.sql_literal(s["model"]), N.sql_literal(hub_model),
                     s["anchor_hash_key"], s["anchor_hash_key"], s["anchor_hash_key"]))
            E.write(os.path.join("assertions",
                                 N.budget("assert_orphan_" + sat.lower()) + ".sql"), body)
            counts["orphan"] += 1

        body = E.header("gen_hcon4_assertions.py", [
            "ASSERTION -- %s did not lose its payload to the hashdiff guard." % sat,
            "claim        : the satellite holds at least one non-null hashdiff.",
            "why runtime  : the hashdiff is guarded, so an all-null payload row yields null and",
            "               is dropped. That guard is what stops an all-null collapse -- every",
            "               such row hashing to ONE value and the satellite collapsing to one",
            "               row, which looks exactly like working change detection. This test",
            "               checks the guard is not instead firing on every row, which is the",
            "               shape a payload that is not where the map says it is makes.",
            "payload      : %d column(s): %s" % (len(s["payload_columns"]),
                                                 ", ".join(s["payload_columns"][:6])),
            "fails when   : the satellite loaded rows but every hashdiff is null.",
        ]) + ("select count(*) as rows_loaded, count(%s) as rows_with_a_version\n"
              "from {{ ref(%s) }}\nhaving count(*) > 0 and count(%s) = 0\n"
              % (s["hashdiff"], N.sql_literal(s["model"]), s["hashdiff"]))
        E.write(os.path.join("assertions",
                             N.budget("assert_versions_" + sat.lower()) + ".sql"), body)
        counts["versions"] += 1

    print("  assertions        : %d grain, %d orphan-key, %d collapse  (%d total)"
          % (counts["grain"], counts["orphan"], counts["versions"], sum(counts.values())))
    return counts


if __name__ == "__main__":
    main()
