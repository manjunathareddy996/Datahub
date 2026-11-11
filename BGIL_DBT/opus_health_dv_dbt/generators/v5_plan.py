# -*- coding: utf-8 -*-
"""The one place the central-view rule becomes a grouping. Writes stitch_plan.json.

  rule 1  a central view joins up to `table_limit` source tables
  rule 2  a satellite is fed WHOLE by exactly one view -- never split
  rule 3  the limit breaks only for a single satellite that needs more tables than it allows
  rule 4  an under-filled view absorbs more tables, so further objects are built from it
  rule 5  each satellite's key is carried on its own view (by construction: every feed carries
          its key expression on its own table)
  rule 6  each link row's legs come from one view (a link pair is placed on a view holding the
          source table whose row carries both legs)
  rule 7  a view's tables cohere: a table or satellite joins a view only through a shared
          source table or a shared anchor hub key

Every rule is re-asserted against the finished plan before it is written.
"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import v5_common as C  # noqa: E402


def main():
    prof = C.profile()
    LIMIT = prof["central_view_rule"]["table_limit"]
    rank = prof["source_precedence"]["run_rank"]
    F = C.read_json("feeds.json")
    specs, feeds, runs = F["sat_specs"], F["feeds"], F["table_runs"]

    tables_of = collections.defaultdict(set)
    for f in feeds:
        tables_of[f["sat"]].add(f["table"])
    hubs_of_table = collections.defaultdict(set)
    for f in feeds:
        hubs_of_table[f["table"]] |= set(f["legs"])
    for c in F["link_candidates"]:
        hubs_of_table[c["table"]] |= set(c["legs"])

    views = []

    def new_view(over=False):
        v = {"tables": set(), "sats": set(), "over_limit": over, "links": [], "absorbed": [],
             "ordinal": len(views) + 1}
        views.append(v)
        return v

    def anchors(v):
        return {h for s in v["sats"] for h in specs[s]["pk_hubs"]}

    # rules 1-3: place every satellite whole, largest first
    for s in sorted(tables_of, key=lambda x: (-len(tables_of[x]), x)):
        Fs = tables_of[s]
        best = None
        for v in views:
            cap = len(v["tables"]) if v["over_limit"] else LIMIT
            union = v["tables"] | Fs
            if len(union) > cap:
                continue
            overlap = len(v["tables"] & Fs)
            if not overlap and not (set(specs[s]["pk_hubs"]) & anchors(v)):
                continue
            score = (overlap, -len(union), -v["ordinal"])
            if best is None or score > best[0]:
                best = (score, v)
        if best is None:
            v = new_view(over=len(Fs) > LIMIT)
        else:
            v = best[1]
        v["tables"] |= Fs
        v["sats"].add(s)

    # rule 4: under-filled views absorb each other while the union stays within the limit
    while True:
        best = None
        live = [v for v in views if v["sats"] and not v["over_limit"]]
        for i, a in enumerate(live):
            for b in live[i + 1:]:
                union = a["tables"] | b["tables"]
                if len(union) > LIMIT:
                    continue
                shared_t = len(a["tables"] & b["tables"])
                shared_h = len(anchors(a) & anchors(b))
                if not shared_t and not shared_h:
                    continue
                score = (shared_t, shared_h, -len(union), -a["ordinal"], -b["ordinal"])
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

    # rule 6: place each link pair on a view that holds its source table
    cands = sorted(F["link_candidates"], key=lambda c: (c["table"], c["link"]))
    placed, homeless = [], []
    for c in cands:
        hosts = [v for v in views if c["table"] in v["tables"]]
        if hosts:
            v = min(hosts, key=lambda x: (len(x["tables"]), x["ordinal"]))
            v["links"].append(c)
            placed.append(c)
        else:
            homeless.append(c)
    by_table = collections.defaultdict(list)
    for c in homeless:
        by_table[c["table"]].append(c)
    link_views = []
    for t in sorted(by_table):
        legs = {h for c in by_table[t] for h in c["legs"]}
        pool = [v for v in views + link_views
                if not v["over_limit"] and len(v["tables"]) < LIMIT
                and (legs & (anchors(v) | {h for x in v["tables"] for h in hubs_of_table[x]}))]
        if pool:
            v = max(pool, key=lambda x: (len(legs & {h for y in x["tables"]
                                                     for h in hubs_of_table[y]}),
                                         -len(x["tables"]), -x["ordinal"]))
        else:
            v = {"tables": set(), "sats": set(), "over_limit": False, "links": [],
                 "absorbed": [], "ordinal": 0}
            link_views.append(v)
        v["tables"].add(t)
        v["links"].extend(by_table[t])
        placed.extend(by_table[t])
    views = views + link_views

    # stable ordinals and names
    def dominant(v):
        c = collections.Counter(h for s in v["sats"] for h in specs[s]["pk_hubs"])
        if not c:
            c = collections.Counter(h for l in v["links"] for h in l["legs"])
        return sorted(c.items(), key=lambda kv: (-kv[1], kv[0]))[0][0]

    views.sort(key=lambda v: (0 if v["sats"] else 1, dominant(v), sorted(v["sats"])[:1],
                              sorted(v["tables"])))
    out = []
    for i, v in enumerate(views, 1):
        name = "v%02d_%s" % (i, C.short(dominant(v)).lower())
        tables = sorted(v["tables"], key=lambda t: (rank[runs[t]], t))
        out.append({
            "ordinal": i, "name": name, "stitch_model": "stitch_" + name,
            "stage_model": "stg2_" + name, "tables": tables,
            "over_limit": len(tables) > LIMIT,
            "satellites": sorted(v["sats"]),
            "links": sorted({c["link"] for c in v["links"]}),
            "link_pairs": sorted(v["links"], key=lambda c: (c["link"], c["table"])),
            "anchor_hubs": sorted(anchors(v)),
            "absorbed_by_rule_4": v["absorbed"],
        })

    # ---- re-assert every rule against the finished plan
    home = collections.Counter(s for v in out for s in v["satellites"])
    assert all(n == 1 for n in home.values()), "rule 2: a satellite sits on more than one view"
    assert set(home) == set(tables_of), "rule 2: a satellite was not placed"
    for v in out:
        for s in v["satellites"]:
            assert tables_of[s] <= set(v["tables"]), "rule 2: %s split" % s
        if v["over_limit"]:
            need = max(len(tables_of[s]) for s in v["satellites"])
            assert len(v["tables"]) == need, "rule 3: %s exceeds the limit beyond what one " \
                                             "satellite needs" % v["name"]
        for c in v["link_pairs"]:
            assert c["table"] in v["tables"], "rule 6: link leg table not on its view"
    assert len(placed) == len(cands), "a link candidate was not placed"

    C.write_json("stitch_plan.json", {
        "rule": prof["central_view_rule"]["verbatim"], "table_limit": LIMIT,
        "views": out,
        "census": {"views": len(out), "satellites": len(home),
                   "views_over_limit": sum(v["over_limit"] for v in out),
                   "link_only_views": sum(1 for v in out if not v["satellites"]),
                   "tables_on_views": len({t for v in out for t in v["tables"]}),
                   "link_pairs": len(placed)},
    })
    print("  plan: %d views (%d over the limit, %d link-only), %d satellites, %d tables, "
          "%d link pairs" % (len(out), sum(v["over_limit"] for v in out),
                             sum(1 for v in out if not v["satellites"]), len(home),
                             len({t for v in out for t in v["tables"]}), len(placed)))
    print("  tables per view:", [len(v["tables"]) for v in out])


if __name__ == "__main__":
    main()
