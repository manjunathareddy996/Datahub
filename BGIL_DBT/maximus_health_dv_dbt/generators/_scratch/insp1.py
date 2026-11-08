import json, collections, os
OUT = r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\generators\_scratch\insp1.out"
d = json.load(open(r"d:\Projects\BAGIC\Datahub\BGIL_DBT\maximus_health_dv_dbt\build_artifacts\mxh3_spec.json", encoding="utf-8"))
o = []
P = o.append
def desc(v):
    if isinstance(v, dict):
        return "dict[%d] keys=%s" % (len(v), list(v)[:12])
    if isinstance(v, list):
        return "list[%d]" % len(v)
    return repr(v)[:80]
for k, v in d.items():
    P("TOP %s: %s" % (k, desc(v)))
try:
    for k, v in d.items():
        if isinstance(v, dict):
            for k2, v2 in list(v.items())[:20]:
                P("  %s.%s: %s" % (k, k2, (json.dumps(v2)[:300])))
except Exception as e:
    P("ERR %r" % e)
open(OUT, "w", encoding="utf-8").write("\n".join(o))
