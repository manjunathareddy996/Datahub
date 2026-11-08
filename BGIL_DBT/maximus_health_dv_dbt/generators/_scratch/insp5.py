import json, collections, os, re
OUT = r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\generators\_scratch\insp5.out"
d = json.load(open(r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\build_artifacts\mxh3_spec.json", encoding="utf-8"))
o = []
P = o.append
b = d["blocks"]
P("i==index: %s" % all(x["i"] == k for k, x in enumerate(b)))
P("leg backing: " + str(collections.Counter(l["backing"] for x in b for l in x["legs"])))
P("leg state: " + str(collections.Counter(l["state"] for x in b for l in x["leg_status"])))
P("leg from: " + str(collections.Counter(l["from"] for x in b for l in x["legs"])))
for bk in set(l["backing"] for x in b for l in x["legs"]):
    ex = [(x, l) for x in b for l in x["legs"] if l["backing"] == bk][:2]
    for x, l in ex:
        P("LEG %s: value=%r rendered=%r status=%s" % (bk, l["value"], x["rendered_child_key"].get(l["leg"]), [s for s in x["leg_status"] if s["leg"] == l["leg"]]))
P("leg count vs rendered_child_key: " + str(collections.Counter((len(x["legs"]), len(x["rendered_child_key"])) for x in b)))
P("multi_active vs declared_child_key: " + str(collections.Counter((x["multi_active"], bool(x["declared_child_key"])) for x in b)))
# rendered missing for ok legs?
miss = [(x["i"], l["leg"]) for x in b for l in x["legs"] if any(s["leg"] == l["leg"] and s["state"] == "ok" for s in x["leg_status"]) and l["leg"] not in x["rendered_child_key"]]
P("ok legs without rendered: %d %s" % (len(miss), miss[:5]))
P("rendered but state not ok: %s" % collections.Counter(s["state"] for x in b for s in x["leg_status"] if s["leg"] in x["rendered_child_key"]))
# sat declared child key vs model
m = d["model"]
bad = [(x["i"], x["satellite"], x["declared_child_key"], m["sat_childkey"].get(x["satellite"])) for x in b if x["satellite"] and (x["declared_child_key"] or "") != (m["sat_childkey"].get(x["satellite"]) or "")]
P("declared_child_key != model childkey: %d %s" % (len(bad), bad[:4]))
# no-satellite rows
ns = [x for x in b if x["kind"] in ("satellite_attribute", "augmentation") and not x["satellite"] and not x["home"] and not x["new_satellite"]]
P("no-sat sat rows: %d" % len(ns))
for x in ns[:4]:
    P("   " + json.dumps({k: x.get(k) for k in ["i", "view", "column", "outcome", "kind", "attribute", "anchor", "instance", "satellite", "home", "new_satellite"]}))
P("outcome by kind with sat none: " + str(collections.Counter((x["kind"], x["outcome"]) for x in ns)))
# new_satellite consistency
ns2 = collections.defaultdict(list)
for x in b:
    if x["new_satellite"]:
        ns2[x["new_satellite"]].append(x)
for k, v in ns2.items():
    P("NEWSAT %s rows=%d anchors=%s childkeys=%s multi=%s homes=%s satellite=%s" % (k, len(v), sorted({r["anchor"] for r in v}), sorted({r["declared_child_key"] for r in v}), sorted({str(r["multi_active"]) for r in v}), sorted({str(r["home"]) for r in v}), sorted({str(r["satellite"]) for r in v})))
# aug rows with home sat: satellite==home?
P("aug rows home!=satellite: %d" % sum(1 for x in b if x["kind"] == "augmentation" and x["home"] and x["home"] != x["satellite"]))
# aug row anchor vs model parent
bp = [(x["satellite"], x["anchor"], m["sat_parent"][x["satellite"]]) for x in b if x["satellite"] and x["anchor"] != m["sat_parent"][x["satellite"]]]
P("row anchor != model parent: %d %s" % (len(bp), collections.Counter(bp).most_common(5)))
# coverage of columns
sv = d["views"]["staging"]
hv = d["views"]["hopviews"]
cols_missing = [(x["i"], x["view"][-30:], x["column"]) for x in b if x["column"] not in sv[x["view"]]["columns"]]
P("block columns not in staging columns: %d %s" % (len(cols_missing), cols_missing[:5]))
nm = []
for x in b:
    for c in x["needs_columns"]:
        if c not in sv[x["view"]]["columns"]:
            nm.append((x["view"][-30:], c))
P("needs_columns not in staging: %d %s" % (len(nm), collections.Counter(nm).most_common(5)))
tm = [(s["terminal_view"][-30:], s["terminal_column"]) for s in d["spans"] if s["terminal_column"] not in (sv.get(s["terminal_view"]) or hv[s["terminal_view"]])["columns"]]
P("terminal columns not in terminal table columns: %d %s" % (len(tm), tm[:5]))
# legacy dirs
base = r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\legacy_v3\models"
for sub in os.listdir(base):
    P("legacy %s: %d files" % (sub, len(os.listdir(os.path.join(base, sub)))))
# legacy staging sample header and source calls
sd = os.path.join(base, "staging")
fn = sorted(os.listdir(sd))[0]
P(open(os.path.join(sd, fn), encoding="utf-8").read()[:1500])
hd = os.path.join(base, "hopviews")
fn = sorted(os.listdir(hd))[0]
P(open(os.path.join(hd, fn), encoding="utf-8").read()[:1200])
P("stem files: staging model stems == files? " + str(sorted(f[:-4] for f in os.listdir(sd)) == sorted(v["model"] for v in sv.values())))
open(OUT, "w", encoding="utf-8").write("\n".join(o))
