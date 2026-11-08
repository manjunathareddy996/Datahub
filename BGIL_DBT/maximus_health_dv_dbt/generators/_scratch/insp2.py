import json, collections, os
OUT = r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\generators\_scratch\insp2.out"
d = json.load(open(r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\build_artifacts\mxh3_spec.json", encoding="utf-8"))
o = []
P = o.append
b = d["blocks"]
P("block key sets: " + str(collections.Counter(tuple(sorted(x.keys())) for x in b).most_common(8)))
P(str(collections.Counter((x.get("kind"), x.get("outcome")) for x in b)))
for kind in ["satellite_attribute", "augmentation", "hub_key", "link_key"]:
    ex = [x for x in b if x["kind"] == kind][:2]
    for e in ex:
        P(kind + ": " + json.dumps(e)[:2500])
P("--- refuse/do_not_build")
n = 0
for x in b:
    if x.get("refuse_row") or any(l.get("do_not_build") for l in x.get("legs") or []):
        n += 1
        if n <= 6:
            P(json.dumps(x)[:1800])
P("n refuse/dnb = %d" % n)
P("refuse_row types: " + str(collections.Counter(repr(x.get("refuse_row"))[:60] for x in b)))
P("dnb leg count: " + str(sum(1 for x in b for l in (x.get("legs") or []) if l.get("do_not_build"))))
P("--- spans in blocks")
cnt = collections.Counter(len(x.get("spans") or []) for x in b)
P("span len dist: " + str(cnt))
sp = [x for x in b if x.get("spans")][:4]
for x in sp:
    P("spans: " + json.dumps(x["spans"])[:800] + " | anchor_expression=" + json.dumps(x.get("anchor_expression"))[:300] + " resolved_key=" + json.dumps(x.get("resolved_key"))[:600])
P("--- top spans")
for s in d["spans"][:6]:
    P(json.dumps(s)[:900])
P("top span key sets: " + str(collections.Counter(tuple(sorted(s.keys())) for s in d["spans"]).most_common(5)))
P("--- resolved_key shapes")
P(str(collections.Counter(tuple(sorted((x.get("resolved_key") or {}).keys())) if isinstance(x.get("resolved_key"), dict) else repr(type(x.get("resolved_key"))) for x in b).most_common(10)))
P("--- legs shapes")
P(str(collections.Counter(tuple(sorted(l.keys())) for x in b for l in (x.get("legs") or [])).most_common(10)))
P("--- views")
for k, v in d["views"].items():
    if isinstance(v, dict):
        for kk in list(v)[:2]:
            P("views.%s[%s] = %s" % (k, kk, json.dumps(v[kk])[:900]))
    else:
        P("views.%s = list[%d]" % (k, len(v)))
P("staging n=%d hopviews n=%d resolvers n=%d" % (len(d["views"]["staging"]), len(d["views"]["hopviews"]), len(d["views"]["resolvers"])))
P("--- unresolved")
P(str(collections.Counter(x.get("kind") for x in d["unresolved"])))
for x in d["unresolved"][:3]:
    P(json.dumps(x)[:700])
P("unresolved key sets: " + str(collections.Counter(tuple(sorted(x.keys())) for x in d["unresolved"]).most_common(6)))
open(OUT, "w", encoding="utf-8").write("\n".join(o))
