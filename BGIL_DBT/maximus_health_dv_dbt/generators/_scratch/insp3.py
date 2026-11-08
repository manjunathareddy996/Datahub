import json, collections, os, re
OUT = r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\generators\_scratch\insp3.out"
d = json.load(open(r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\build_artifacts\mxh3_spec.json", encoding="utf-8"))
o = []
P = o.append
b = d["blocks"]
P("anchor_state: " + str(collections.Counter(x.get("anchor_state") for x in b)))
P("anchor_resolved_by: " + str(collections.Counter(x.get("anchor_resolved_by") for x in b)))
P("has anchor_expression: " + str(collections.Counter(("anchor_expression" in x, x.get("anchor_expression") is None, x.get("has_resolved_key")) for x in b)))
P("anchor kinds: " + str(collections.Counter((x["anchor"] or "")[:4] for x in b)))
P("resolved_key.hub==anchor: " + str(collections.Counter((x["resolved_key"]["hub"] == x["anchor"], x["has_resolved_key"]) for x in b)))
P("resolved_key.link set: " + str(collections.Counter(bool(x["resolved_key"]["link"]) for x in b)))
P("tier: " + str(collections.Counter(x["resolved_key"]["tier"] for x in b)))
# example with anchor_state
for st in set(x.get("anchor_state") for x in b):
    ex = [x for x in b if x.get("anchor_state") == st][:1]
    for e in ex:
        P("STATE %r: %s" % (st, json.dumps({k: e.get(k) for k in ["view", "column", "satellite", "anchor", "instance", "anchor_expression", "anchor_rendered", "anchor_resolved_by", "anchor_state", "has_resolved_key", "resolved_key", "spans", "kind"]})[:1500]))
# triple groups
g = collections.defaultdict(set)
for x in b:
    rk = x["resolved_key"]
    if x["has_resolved_key"] and rk["hub"]:
        g[(x["view"], rk["hub"], x["instance"])].add(rk["expression"])
P("triples: %d, multi-expr triples: %d" % (len(g), sum(1 for v in g.values() if len(v) > 1)))
for k, v in list(((k, v) for k, v in g.items() if len(v) > 1))[:3]:
    P("MULTI " + str(k) + " -> " + str(v)[:600])
# anchor_expression vs resolved_key.expression
diff = [x for x in b if x.get("anchor_expression") is not None and x["resolved_key"]["expression"] != x["anchor_expression"]]
P("anchor_expression != resolved expr: %d of %d" % (len(diff), sum(1 for x in b if x.get("anchor_expression") is not None)))
for x in diff[:3]:
    P("  " + json.dumps({k: x.get(k) for k in ["anchor_expression", "anchor_rendered"]}) + " rk=" + str(x["resolved_key"]["expression"]))
# blocks without resolved key
nk = [x for x in b if not x["has_resolved_key"]]
P("no resolved key: %d  %s" % (len(nk), collections.Counter((x["kind"], x.get("anchor_state")) for x in nk)))
for x in nk[:2]:
    P("  " + json.dumps({k: x.get(k) for k in ["view", "column", "kind", "anchor", "instance", "anchor_state", "resolved_key", "refuse_row", "refused_legs", "source_gap_block"]})[:900])
# hub_key rows: expression vs bare column
hk = [x for x in b if x["kind"] in ("hub_key", "link_key")]
P("hub/link_key rows: %d; expr != column: %d; source_columns len: %s" % (len(hk), sum(1 for x in hk if x["resolved_key"]["expression"] != x["column"]), collections.Counter(len(x["resolved_key"]["source_columns"]) for x in hk)))
for x in [x for x in hk if x["resolved_key"]["expression"] != x["column"]][:6]:
    P("  col=%s expr=%s sc=%s tier=%s" % (x["column"], x["resolved_key"]["expression"], x["resolved_key"]["source_columns"], x["resolved_key"]["tier"]))
# unresolved kinds fields
for kind in set(u["kind"] for u in d["unresolved"]):
    u = [u for u in d["unresolved"] if u["kind"] == kind][0]
    P("UNRES %s: %s" % (kind, json.dumps(u)[:1200]))
# multi_active / satellite vs model
m = d["model"]
sats = set(m["sat_parent"])
P("sat_parent %d childkey %d attrs %d hist %d" % (len(m["sat_parent"]), len(m["sat_childkey"]), len(m["sat_attrs"]), len(m["sat_hist"])))
P("childkey non-empty: %d" % sum(1 for v in m["sat_childkey"].values() if v))
P("block satellites not in model: " + str(sorted({x["satellite"] for x in b if x["satellite"] and x["satellite"] not in sats})[:20]))
P("block home not in model: " + str(sorted({x["home"] for x in b if x["home"] and x["home"] not in sats})[:20]))
P("new_satellite values: " + str(collections.Counter(x["new_satellite"] for x in b if x["new_satellite"]).most_common(10)))
P("satellite null by kind: " + str(collections.Counter((x["kind"], x["satellite"] is None, x["home"] is None, bool(x["new_satellite"])) for x in b)))
P("hubs (model counts) " + str(m["counts"]))
P("anchors: " + str(sorted({x["anchor"] for x in b if x["anchor"] and x["anchor"].startswith("HUB")})))
P("link anchors: " + str(sorted({x["anchor"] for x in b if x["anchor"] and x["anchor"].startswith("LNK")})))
P("parents set: " + str(collections.Counter(p[:4] for p in m["sat_parent"].values())))
P("distinct parent values: " + str(sorted(set(m["sat_parent"].values()))[:100]))
P("REF targets in blocks: " + str(collections.Counter(x["satellite"][:4] for x in b if x["satellite"])))
P("REF in parent? " + str([s for s in m["sat_parent"] if s.startswith("REF")][:5]) + " ref_attrs " + str(list(m["ref_attrs"])[:3]))
# view sets
vs = {x["view"] for x in b}
st = set(d["views"]["staging"]); hv = set(d["views"]["hopviews"])
P("block views %d; in staging %d; not in staging %s" % (len(vs), len(vs & st), sorted(vs - st)[:5]))
P("staging stems unique: %d/%d; hop stems unique %d/%d; overlap %s" % (len({v['model'] for v in d['views']['staging'].values()}), len(st), len({v['model'] for v in d['views']['hopviews'].values()}), len(hv), len(st & hv)))
allstems = [v["model"] for v in d["views"]["staging"].values()] + [v["model"] for v in d["views"]["hopviews"].values()]
P("all stems unique: %d/%d" % (len(set(allstems)), len(allstems)))
P("longest table names: " + str(max(len(v) for v in st | hv)))
# spans coverage
tops = {s["raw"] for s in d["spans"]}
bs = {sp for x in b for sp in (x["spans"] or [])}
P("block span strings: %d, in top spans: %d" % (len(bs), len(bs & tops)))
P("top span raw distinct: %d of %d" % (len(tops), len(d["spans"])))
P("top spans from_view in staging: %d / %d; terminal in (st|hv): %d" % (sum(1 for s in d["spans"] if s["from_view"] in st), len(d["spans"]), sum(1 for s in d["spans"] if s["terminal_view"] in st | hv)))
hopcols = [h for s in d["spans"] for h in s["climb_real"] + s["descend_real"]]
P("hops not in st|hv: %d" % sum(1 for h in hopcols if h not in st | hv))
P("span kinds: " + str(collections.Counter(s["kind"] for s in d["spans"])))
P("span starts: " + str(collections.Counter(s["start"] for s in d["spans"])))
P("resolvers: " + json.dumps(list(d["views"]["resolvers"].items())[:2])[:500])
P("columns of staging contain KEY_HASH: %d/%d" % (sum(1 for v in d["views"]["staging"].values() if "KEY_HASH" in v["columns"]), len(st)))
P("hop columns contain KEY_HASH: %d/%d" % (sum(1 for v in d["views"]["hopviews"].values() if "KEY_HASH" in v["columns"]), len(hv)))
open(OUT, "w", encoding="utf-8").write("\n".join(o))
