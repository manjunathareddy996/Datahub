# -*- coding: utf-8 -*-
"""Is each stitched view actually JOINABLE? Measured before one line of join SQL is written.

The grouping packs tables by which satellite needs them. Nothing in that forces the tables of one
view to share a key, and a view whose tables share no key cannot be joined -- it can only be
cross-joined, which multiplies rows, or union-ed, which is not a stitch. Either would produce a
view that loads and a satellite whose population is wrong, and a wrong population passes every
structural gate.

So this asks three questions per view, and reports the distribution rather than a verdict:
  (a) which hub key, if any, is carried by EVERY table in the view -- the natural join spine;
  (b) failing that, what is the largest subset of tables sharing one key, and what is left over;
  (c) for each leftover table, is there ANY hub key it shares with any table already in the spine
      -- i.e. can it be reached in a second join step rather than not at all.

Writes nothing. The answer decides whether the plan needs a seventh requirement.
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

PLAN = json.load(io.open(P.PLAN_PATH, encoding="utf-8"))
rows = P.load_map()
blocks = P.read_blocks(rows)
hub_tables, _non, _prov = P.hub_key_tables(blocks)

# table -> set of hubs keyed on it (both sources, as the plan uses)
tbl_hubs = collections.defaultdict(set)
for h, ts in hub_tables.items():
    for t in ts:
        tbl_hubs[t].add(h)

views = PLAN["stitched_views"]
print("views: %d" % len(views))

full_spine, partial, unjoinable = [], [], []
spine_hist = collections.Counter()
leftover_hist = collections.Counter()
reachable_total = unreachable_total = 0
unreachable_detail = []

for v in views:
    tabs = v["tables"]
    common = set.intersection(*[tbl_hubs.get(t, set()) for t in tabs]) if tabs else set()
    if common:
        full_spine.append(v)
        spine_hist[len(tabs)] += 1
        continue
    # largest subset sharing one hub key
    best_hub, best_set = None, set()
    for h in v["hubs_on_view"]:
        s = {t for t in tabs if h in tbl_hubs.get(t, set())}
        if len(s) > len(best_set):
            best_hub, best_set = h, s
    left = [t for t in tabs if t not in best_set]
    leftover_hist[len(left)] += 1
    reach, unreach = [], []
    for t in left:
        th = tbl_hubs.get(t, set())
        if th & set().union(*[tbl_hubs.get(x, set()) for x in best_set]) if best_set else False:
            reach.append(t)
        elif th:
            reach.append(t) if (th & set(v["hubs_on_view"])) else unreach.append(t)
        else:
            unreach.append(t)
    reachable_total += len(reach)
    unreachable_total += len(unreach)
    if unreach:
        unjoinable.append({"ordinal": v["ordinal"], "tables": len(tabs),
                           "spine_hub": best_hub, "spine_tables": len(best_set),
                           "unreachable": unreach[:6],
                           "satellites": v["satellites"][:3]})
    else:
        partial.append({"ordinal": v["ordinal"], "tables": len(tabs), "spine_hub": best_hub,
                        "spine_tables": len(best_set), "second_step": len(reach)})

print()
print("=" * 94)
print("(a) VIEWS WITH A FULL JOIN SPINE -- one hub key carried by EVERY table")
print("=" * 94)
print("views: %d of %d" % (len(full_spine), len(views)))
print("   by table count: %s" % dict(sorted(spine_hist.items())))

print()
print("=" * 94)
print("(b) VIEWS NEEDING MORE THAN ONE JOIN STEP")
print("=" * 94)
print("views: %d" % len(partial))
print("   leftover tables per such view: %s" % dict(sorted(leftover_hist.items())))
for x in partial[:8]:
    print("   view %-3d %2d tables, spine %-26s covers %2d, %d reachable in a 2nd step"
          % (x["ordinal"], x["tables"], x["spine_hub"], x["spine_tables"], x["second_step"]))

print()
print("=" * 94)
print("(c) TABLES THAT CANNOT BE REACHED BY ANY KEY -- these would need a cross join")
print("=" * 94)
print("views containing at least one unreachable table : %d" % len(unjoinable))
print("unreachable tables, total                       : %d" % unreachable_total)
print("tables reachable only in a second join step     : %d" % reachable_total)
for x in unjoinable[:12]:
    print("   view %-3d %2d tables, spine %-24s unreachable: %s"
          % (x["ordinal"], x["tables"], str(x["spine_hub"]), ", ".join(x["unreachable"][:3])))

print()
print("tables carrying NO hub key at all (in any view) : %d"
      % len({t for v in views for t in v["tables"] if not tbl_hubs.get(t)}))
nk = sorted({t for v in views for t in v["tables"] if not tbl_hubs.get(t)})
for t in nk[:12]:
    print("   %s" % t)
