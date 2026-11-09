# -*- coding: utf-8 -*-
"""The last three questions the emitters need answered from the data. Writes nothing.

  1. RUNS PER TABLE. Each run is its own dbt source. A table present in more than one run must
     have its feeds reconciled somewhere, and under the central-view rule that somewhere is the
     stitched view, not the satellite loader.
  2. KEY EXPRESSION AVAILABILITY per (table, hub). The spine join needs ONE renderable expression
     per table for the spine hub. Two sources supply them and they have different shapes: the map
     gives a full expression verbatim, legacy archaeology gives a bare column name. A (table, hub)
     with several candidate expressions is several key SLOTS, and picking one would assert they
     are one identifier population.
  3. PAYLOAD per satellite, with the grain fields that decide whether a dedupe is safe.
"""
import collections
import io
import json
import os
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hcon4_plan as P                                             # noqa: E402

rows = P.load_map()
blocks = P.read_blocks(rows)
PLAN = json.load(io.open(P.PLAN_PATH, encoding="utf-8"))
in_view = {t for v in PLAN["stitched_views"] for t in v["tables"]}

print("=" * 94)
print("1. RUNS PER TABLE")
print("=" * 94)
runs_of = collections.defaultdict(set)
for r in rows:
    t = P.n(r.get("table_name"))
    run = P.n(r.get("source_run"))
    if t:
        runs_of[t].add(run or "(no source_run)")
print("distinct source_run values: %s"
      % dict(collections.Counter(x for v in runs_of.values() for x in v)))
multi = {t: sorted(v) for t, v in runs_of.items() if len(v) > 1}
print("tables in MORE THAN ONE run : %d" % len(multi))
for t, v in sorted(multi.items())[:8]:
    print("   %-40s %s" % (t, v))
print("tables in a view            : %d" % len(in_view))
print("   of those, multi-run      : %d" % len(set(multi) & in_view))

print()
print("=" * 94)
print("2. KEY EXPRESSION AVAILABILITY per (table, hub)")
print("=" * 94)
from_map = collections.defaultdict(set)
for b in blocks:
    if b["expr"] and b["hub"]:
        from_map[(b["table"], b["hub"])].add(b["expr"])
import hcon_keyrules as K                                          # noqa: E402
recovered, stats = K.legacy_key_forms()
upper = {t.upper(): t for t in {P.n(r.get("table_name")) for r in rows if r.get("table_name")}}
from_legacy = {}
for (stem, hub), exprs in recovered.items():
    t = upper.get(stem.upper())
    if t:
        from_legacy[(t, hub)] = sorted(exprs)

print("(table,hub) slots from the map          : %d" % len(from_map))
print("(table,hub) slots from legacy SQL       : %d" % len(from_legacy))
print("overlap (both sources have the slot)    : %d" % len(set(from_map) & set(from_legacy)))
amb_map = {k: sorted(v) for k, v in from_map.items() if len(v) > 1}
amb_leg = {k: v for k, v in from_legacy.items() if len(v) > 1}
print("map slots with MORE THAN ONE expression : %d" % len(amb_map))
for k, v in sorted(amb_map.items())[:4]:
    print("   %s / %s -> %d expressions" % (k[0], k[1], len(v)))
    for e in v[:2]:
        print("        %s" % e[:110])
print("legacy slots with >1 recovered column   : %d" % len(amb_leg))
for k, v in sorted(amb_leg.items())[:4]:
    print("   %s / %s -> %s" % (k[0], k[1], v))

print()
print("spine coverage: can every spine table render its spine key?")
miss = []
for v in PLAN["stitched_views"]:
    h = v["join_plan"]["spine_hub"]
    for t in v["join_plan"]["spine_tables"]:
        if (t, h) not in from_map and (t, h) not in from_legacy:
            miss.append((v["ordinal"], t, h))
print("   spine (table,hub) pairs with NO renderable expression: %d" % len(miss))
for x in miss[:8]:
    print("      view %-3d %-38s %s" % x)
step_miss = []
for v in PLAN["stitched_views"]:
    for s in v["join_plan"]["second_step_joins"]:
        if (s["table"], s["on_hub"]) not in from_map \
                and (s["table"], s["on_hub"]) not in from_legacy:
            step_miss.append((v["ordinal"], s["table"], s["on_hub"]))
print("   second-step (table,hub) pairs with NO expression    : %d" % len(step_miss))
for x in step_miss[:8]:
    print("      view %-3d %-38s %s" % x)

print()
print("=" * 94)
print("3. PAYLOAD per satellite, and the grain fields")
print("=" * 94)
pay = collections.defaultdict(list)
for r in rows:
    t = P.n(r.get("table_name"))
    col = P.n(r.get("column_name"))
    for tr in ("target", "augmentation"):
        o = r.get(tr)
        if not isinstance(o, dict):
            continue
        sat = (P.n(o.get("satellite")) or P.n(o.get("new_satellite"))
               or P.n(o.get("best_home_satellite")))
        attr = P.n(o.get("attribute")) or P.n(o.get("proposed_attribute"))
        if sat and attr and t and col:
            pay[sat].append({"table": t, "column": col, "attr": attr, "track": tr,
                             "multi_active": P.n(o.get("multi_active")),
                             "child_key": P.n(o.get("child_key"))})
print("satellites with payload       : %d" % len(pay))
print("payload entries               : %d" % sum(len(v) for v in pay.values()))
dist = collections.Counter(len(v) for v in pay.values())
print("attributes per satellite (top): %s" % dict(sorted(dist.items())[:10]))

ma_model = {s["code"]: P.n(s.get("hist")) for s in P.MODEL["sats"]}
print()
print("grain, from data_7.js hist (the model governs grain, not the map):")
placed = {s for v in PLAN["stitched_views"] for s in v["satellites"]}
c = collections.Counter(ma_model.get(s, "(not in model)") for s in placed)
print("   %s" % dict(c))
print()
print("satellites PLACED but carrying no model entry: %d"
      % sum(1 for s in placed if s not in ma_model))
nm = sorted(s for s in placed if s not in ma_model)
for s in nm[:10]:
    print("   %s" % s)
print()
print("satellites placed with child_key declared on any block: %d"
      % sum(1 for s in placed if any(e["child_key"] for e in pay.get(s, []))))
