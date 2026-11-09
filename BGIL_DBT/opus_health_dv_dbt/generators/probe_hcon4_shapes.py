# -*- coding: utf-8 -*-
"""Probe the shapes the emitters must render, from the pinned contracts. Writes nothing.

Run before the emitters are written, not after. Every figure the emitters assume about the map --
the key-expression forms, how a payload block names its column, the child-key fields, the grain
flags -- is read here first, because an emitter that assumes a shape the map does not have emits
valid SQL for data that is not there.
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
raw = []
for r in rows:
    for tr in ("target", "augmentation"):
        o = r.get(tr)
        if isinstance(o, dict):
            raw.append((r, tr, o))

print("map rows %d, (row,track) blocks %d" % (len(rows), len(raw)))

print()
print("=" * 90)
print("1. resolved_key SHAPE -- what the emitters read to render a hash key")
print("=" * 90)
rk_keys = collections.Counter()
rk_count = 0
for _, _, o in raw:
    rk = o.get("resolved_key")
    if isinstance(rk, dict):
        rk_count += 1
        for k, v in rk.items():
            if v not in (None, "", [], {}):
                rk_keys[k] += 1
print("blocks carrying a resolved_key dict: %d" % rk_count)
for k, c in rk_keys.most_common():
    print("   %-24s populated on %d" % (k, c))

print()
print("sample key expressions, grouped by shape:")
forms = collections.defaultdict(list)
for _, _, o in raw:
    rk = o.get("resolved_key")
    if not isinstance(rk, dict):
        continue
    e = P.n(rk.get("expression"))
    if not e:
        continue
    shape = ("md5" if e.startswith("md5") else
             "concat" if "||" in e else
             "nullif" if e.startswith("nullif") else
             "bare")
    forms[shape].append((P.n(rk.get("hub")), e))
for shape in sorted(forms):
    print("   --- %s : %d" % (shape, len(forms[shape])))
    seen = set()
    for hub, e in forms[shape]:
        if e in seen:
            continue
        seen.add(e)
        print("       %-26s %s" % (hub, e[:120]))
        if len(seen) >= 4:
            break

print()
print("=" * 90)
print("2. PAYLOAD -- how a block names the column it writes")
print("=" * 90)
pay = [(r, tr, o) for r, tr, o in raw
       if (P.n(o.get("satellite")) or P.n(o.get("new_satellite"))
           or P.n(o.get("best_home_satellite")))]
print("blocks naming a satellite: %d" % len(pay))
has_attr = sum(1 for r, tr, o in pay if P.n(o.get("attribute")))
has_prop = sum(1 for r, tr, o in pay if P.n(o.get("proposed_attribute")))
has_col = sum(1 for r, tr, o in pay if P.n(r.get("column_name")))
print("   with target.attribute          : %d" % has_attr)
print("   with proposed_attribute        : %d" % has_prop)
print("   with row.column_name           : %d" % has_col)
print("   with NEITHER attribute form    : %d"
      % sum(1 for r, tr, o in pay
            if not P.n(o.get("attribute")) and not P.n(o.get("proposed_attribute"))))

print()
print("outcome / kind values on payload blocks:")
for f in ("outcome", "kind", "transformation"):
    c = collections.Counter()
    for r, tr, o in pay:
        v = P.n(o.get(f)) if f != "outcome" else P.n(r.get("outcome"))
        c[v or "(empty)"] += 1
    print("   %-16s %s" % (f, dict(c.most_common(6))))

print()
print("=" * 90)
print("3. GRAIN -- multi-active flags and child keys, which set a satellite's grain")
print("=" * 90)
for f in ("multi_active", "proposed_multi_active", "child_key", "child_key_value",
          "child_key_components", "instance"):
    pres = sum(1 for _, _, o in raw if f in o)
    popd = sum(1 for _, _, o in raw if o.get(f) not in (None, "", [], {}, "None"))
    print("   %-24s present on %5d   populated on %5d" % (f, pres, popd))

print()
print("model grain flags in data_7.js (hist field on sats):")
hc = collections.Counter()
for s in P.MODEL["sats"]:
    hc[P.n(s.get("hist")) or "(none)"] += 1
print("   %s" % dict(hc.most_common(8)))
print()
print("sat fields in data_7.js: %s" % sorted(P.MODEL["sats"][0]))
print("hub fields in data_7.js: %s" % sorted(P.MODEL["hubs"][0]))
print("link fields in data_7.js: %s" % sorted(P.MODEL["links"][0]))

print()
print("=" * 90)
print("4. SOURCE TABLE COLUMN availability -- can a stitched view actually select these?")
print("=" * 90)
idx_path = os.path.join(P.INPUTS, "00_tables_index.DELTA3.json")
if os.path.exists(idx_path):
    idx = json.load(io.open(idx_path, encoding="utf-8"))
    print("tables index type: %s, top-level keys/len: %s"
          % (type(idx).__name__,
             (sorted(idx)[:8] if isinstance(idx, dict) else len(idx))))
    if isinstance(idx, dict):
        for k in sorted(idx)[:3]:
            print("   %s -> %s" % (k, str(idx[k])[:200]))
    elif idx:
        print("   first entry: %s" % str(idx[0])[:300])
cols_per_table = collections.defaultdict(set)
for r in rows:
    t = P.n(r.get("table_name"))
    c = P.n(r.get("column_name"))
    if t and c:
        cols_per_table[t].add(c)
print("tables named in the map            : %d" % len(cols_per_table))
print("columns the map names, total       : %d" % sum(len(v) for v in cols_per_table.values()))
print("median columns per table           : %d"
      % sorted(len(v) for v in cols_per_table.values())[len(cols_per_table) // 2])
