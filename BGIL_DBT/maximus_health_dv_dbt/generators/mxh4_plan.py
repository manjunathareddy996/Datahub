# -*- coding: utf-8 -*-
"""The one place the central-view rule becomes a grouping. Writes stitch_plan.json.

  rule 1  a central view's FEEDING tables number at most `table_limit`
  rule 2  a satellite is fed WHOLE by exactly one view
  rule 3  the limit breaks only for one satellite that needs more feeding tables than it allows
  rule 4  under-filled views absorb each other while the union stays within the limit
  rule 5  every satellite's key is carried on its own view (each feed carries its own key)
  rule 6  each link pair is placed on a view holding the table whose row carries both legs
  rule 7  a satellite joins a view only through a shared table or a shared anchor hub

Ancestor/sibling tables a spine walk joins are lookups for a key, not feeding tables; they are
listed per view (walk_tables) and do not count toward the limit. Every rule is re-asserted.
"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mxh4_common as C  # noqa: E402


def main():
    prof = C.profile()
    LIMIT = prof["central_view_rule"]["table_limit"]
    F = C.read_json("feeds.json")
    specs, feeds = F["sat_specs"], F["feeds"]
    tables_of = collections.defaultdict(set)
    for f in feeds:
        tables_of[f["sat"]].add(f["table"])
    hubs_of_table = collections.defaultdict(set)
    for f in feeds:
        hubs_of_table[f["table"]] |= set(f["legs"])
    for c in F["link_candidates"]:
        hubs_of_table[c["table"]] |= set(c["legs"])

    views = []

    def anchors(v):
        return {h for s in v["sats"] for h in specs[s]["pk_hubs"]}

    for s in sorted(tables_of, key=lambda x: (-len(tables_of[x]), x)):
        Fs = tables_of[s]
        best = None
        for v in views:
            cap = len(v["tables"]) if v["over"] else LIMIT
            union = v["tables"] | Fs
            if len(union) > cap:
                continue
            ov = len(v["tables"] & Fs)
            if not ov and not (set(specs[s]["pk_hubs"]) & anchors(v)):
                continue
            score = (ov, -len(union), -v["n"])
            if best is None or score > best[0]:
                best = (score, v)
        v = best[1] if best else None
        if v is None:
            v = {"tables": set(), "sats": set(), "over": len(Fs) > LIMIT, "links": [],
                 "absorbed": [], "n": len(views) + 1}
            views.append(v)
        v["tables"] |= Fs
        v["sats"].add(s)

    while True:
        best = None
        live = [v for v in views if v["sats"] and not v["over"]]
        for i, a in enumerate(live):
            for b in live[i + 1:]:
                union = a["tables"] | b["tables"]
                if len(union) > LIMIT:
                    continue
                st, sh = len(a["tables"] & b["tables"]), len(anchors(a) & anchors(b))
                if not st and not sh:
                    continue
                score = (st, sh, -len(union), -a["n"], -b["n"])
                if best is None or score > best[0]:
                    best = (score, a, b)
        if best is None:
            break
        _s, a, b = best
        a["tables"] |= b["tables"]
        a["sats"] |= b["sats"]
        a["absorbed"].append(sorted(b["sats"]))
        b["tables"], b["sats"] = set(), set()
    views = [v for v in views if v["sats"]]

    cands = sorted(F["link_candidates"], key=lambda c: (c["table"], c["link"], sorted(c["legs"])))
    homeless = collections.defaultdict(list)
    for c in cands:
        hosts = [v for v in views if c["table"] in v["tables"]]
        if hosts:
            min(hosts, key=lambda x: (len(x["tables"]), x["n"]))["links"].append(c)
        else:
            homeless[c["table"]].append(c)
    link_views = []
    for t in sorted(homeless):
        legs = {h for c in homeless[t] for h in c["legs"]}
        pool = [v for v in views + link_views if not v["over"] and len(v["tables"]) < LIMIT
                and legs & (anchors(v) | {h for x in v["tables"] for h in hubs_of_table[x]})]
        if pool:
            v = max(pool, key=lambda x: (len(legs & {h for y in x["tables"] for h in hubs_of_table[y]}),
                                         -len(x["tables"]), -x["n"]))
        else:
            v = {"tables": set(), "sats": set(), "over": False, "links": [], "absorbed": [], "n": 0}
            link_views.append(v)
        v["tables"].add(t)
        v["links"].extend(homeless[t])
    views += link_views

    def dominant(v):
        c = collections.Counter(h for s in v["sats"] for h in specs[s]["pk_hubs"]) or \
            collections.Counter(h for l in v["links"] for h in l["legs"])
        return sorted(c.items(), key=lambda kv: (-kv[1], kv[0]))[0][0]

    views.sort(key=lambda v: (0 if v["sats"] else 1, dominant(v), sorted(v["sats"])[:1], sorted(v["tables"])))
    out = []
    for i, v in enumerate(views, 1):
        name = "v%02d_%s" % (i, C.short(dominant(v)).lower())
        out.append({"ordinal": i, "name": name, "stitch_model": "stitch_" + name,
                    "stage_model": "stg2_" + name, "tables": sorted(v["tables"]),
                    "over_limit": len(v["tables"]) > LIMIT, "satellites": sorted(v["sats"]),
                    "links": sorted({c["link"] for c in v["links"]}),
                    "link_pairs": v["links"], "anchor_hubs": sorted(anchors(v)),
                    "absorbed_by_rule_4": v["absorbed"]})

    home = collections.Counter(s for v in out for s in v["satellites"])
    assert all(n == 1 for n in home.values()) and set(home) == set(tables_of), "rule 2"
    for v in out:
        for s in v["satellites"]:
            assert tables_of[s] <= set(v["tables"]), "rule 2: %s split" % s
        if v["over_limit"]:
            assert len(v["tables"]) == max(len(tables_of[s]) for s in v["satellites"]), "rule 3"
        for c in v["link_pairs"]:
            assert c["table"] in v["tables"], "rule 6"
    assert sum(len(v["link_pairs"]) for v in out) == len(cands), "a link pair was not placed"
    C.write_json("stitch_plan.json", {
        "rule": prof["central_view_rule"]["verbatim"], "table_limit": LIMIT, "views": out,
        "census": {"views": len(out), "satellites": len(home),
                   "views_over_limit": sum(v["over_limit"] for v in out),
                   "link_only_views": sum(1 for v in out if not v["satellites"]),
                   "feeding_tables": len({t for v in out for t in v["tables"]}),
                   "link_pairs": len(cands)}})
    print("  plan: %d views (%d over the limit, %d link-only), %d satellites, %d feeding tables" % (
        len(out), sum(v["over_limit"] for v in out), sum(1 for v in out if not v["satellites"]),
        len(home), len({t for v in out for t in v["tables"]})))
    print("  feeding tables per view:", [len(v["tables"]) for v in out])


if __name__ == "__main__":
    main()
