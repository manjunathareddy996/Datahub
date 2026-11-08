import json, collections, os, re
OUT = r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\generators\_scratch\insp4.out"
d = json.load(open(r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\build_artifacts\mxh3_spec.json", encoding="utf-8"))
o = []
P = o.append
b = d["blocks"]
g = collections.defaultdict(list)
for x in b:
    rk = x["resolved_key"]
    if x["has_resolved_key"] and rk["hub"]:
        g[(x["view"], rk["hub"], x["instance"])].append(x)
for k, v in g.items():
    exprs = {x["resolved_key"]["expression"] for x in v}
    if len(exprs) > 1:
        P("TRIPLE %s %s %s" % (k[0][-50:], k[1], k[2]))
        c = collections.Counter((x["kind"], x["resolved_key"]["expression"], x["resolved_key"]["tier"], x["column"] if x["kind"] != "satellite_attribute" else "") for x in v)
        for kk, n in c.items():
            P("    %d x %s" % (n, kk))
# redundant_of? instance values
P("instances: " + str(collections.Counter(x["instance"] for x in b).most_common(12)))
# hub_key rows: same (view,hub,instance) multiple rows?
hk = collections.defaultdict(list)
for x in b:
    if x["kind"] in ("hub_key", "link_key"):
        hk[(x["view"], x["anchor"], x["instance"])].append(x["column"])
P("hub_key groups: %d; with >1 column: %d" % (len(hk), sum(1 for v in hk.values() if len(v) > 1)))
for k, v in [(k, v) for k, v in hk.items() if len(v) > 1][:6]:
    P("   " + str((k[0][-40:], k[1], k[2], v)))
# satellite-attribute blocks: key for (view,hub,inst) not covered by hub_key rows
P("anchors with resolved_key.hub != anchor but has key: " + str([(x["anchor"], x["resolved_key"]["hub"], x["resolved_key"]["link"], x["kind"]) for x in b if x["has_resolved_key"] and x["resolved_key"]["hub"] != x["anchor"]][:8]))
# link rows
lk = [x for x in b if x["resolved_key"]["link"]]
P("link-resolved blocks: %d kinds %s" % (len(lk), collections.Counter((x["kind"], x["anchor"][:4]) for x in lk)))
for x in lk[:2]:
    P("   " + json.dumps({k: x.get(k) for k in ["view", "column", "kind", "anchor", "satellite", "instance", "resolved_key", "spans"]})[:1200])
# anchor LNK rows
la = [x for x in b if x["anchor"].startswith("LNK")]
P("LNK-anchored: %d kinds %s hub==%s" % (len(la), collections.Counter(x["kind"] for x in la), collections.Counter((x["resolved_key"]["hub"] or "")[:4] for x in la)))
for x in la[:3]:
    P("   " + json.dumps({k: x.get(k) for k in ["view", "column", "kind", "anchor", "satellite", "instance", "resolved_key", "spans"]})[:1200])
# tier4 / tier2 / unresolved examples
for t in ["tier4_content_hash", "tier2_foreign_key", "unresolved"]:
    e = [x for x in b if x["resolved_key"]["tier"] == t][:2]
    for x in e:
        P(t + " " + json.dumps({k: x.get(k) for k in ["view", "column", "kind", "anchor", "instance", "resolved_key", "spans"]})[:900])
# multi-span blocks
ms = [x for x in b if len(x["spans"] or []) > 1][:2]
for x in ms:
    P("MULTISPAN " + json.dumps({k: x.get(k) for k in ["view", "column", "kind", "anchor", "instance", "resolved_key", "spans"]})[:1500])
# span usage: every spine in resolved_key.expression -> is span in block spans?
miss = 0
for x in b:
    ex = x["resolved_key"]["expression"] or ""
    for m in re.finditer(r"spine\[[^\]]*\]\.\w+", ex):
        if m.group(0) not in (x["spans"] or []):
            miss += 1
P("spine refs in resolved expr not in block.spans: %d" % miss)
# do top spans for a block's view start at the block's view?
bad = 0
tops = {}
for s in d["spans"]:
    tops.setdefault(s["raw"], []).append(s)
for x in b:
    for sp in x["spans"] or []:
        cands = tops[sp]
        if not any(c["from_view"] == x["view"] for c in cands):
            bad += 1
P("block span whose top-span from_view != block view: %d" % bad)
# raw spans duplicates differ?
dup = {r: v for r, v in tops.items() if len(v) > 1}
P("raw with multiple top entries: %d ; example from_views differ: %s" % (len(dup), all(len({c['from_view'] for c in v}) == len(v) for v in dup.values())))
# (from_view, raw) unique?
P("(from_view,raw) unique: %d/%d" % (len({(s['from_view'], s['raw']) for s in d['spans']}), len(d['spans'])))
# spine ref format variants
P("spine: format tokens in resolved expr: " + str(collections.Counter(bool(re.search(r"spine:", x["resolved_key"]["expression"] or "")) for x in b)))
P("spine[ in anchor_expression: " + str(sum(1 for x in b if "spine[" in (x.get("anchor_expression") or ""))))
open(OUT, "w", encoding="utf-8").write("\n".join(o))
