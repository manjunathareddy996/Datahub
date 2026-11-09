# -*- coding: utf-8 -*-
"""Layer 4: the vault. Hub feeds, hubs, links and satellites -- ALL derived from the central views.

This is the user's hub/link extension, implemented: a satellite's primary key goes to its hub, so
the hub comes from the view the satellite is built on; and because several hub keys co-occur on
that same view, the links come from there too. Nothing here reads a source table, and nothing
computes a hash -- every hash key arrives from the stage layer, the single hash site.

  hub_feeds   one per (hub, view carrying that hub's key): the distinct keys that view sees
  hubs        one per hub: the union of its feeds, deduped to one row per key
  links       one per link whose every hub leg co-occurs on one view: the legs taken TOGETHER
              from that one view, which is what makes the relationship a fact of the data rather
              than of a join assembled afterwards
  satellites  one per satellite, reading exactly ONE stage model -- the whole point of rule 2,
              and the thing that makes rule 2 checkable: a satellite with two sources is a
              violation a gate can see.

Every column this layer references comes from the stage layer's MANIFEST. It does not grep the
upstream SQL: payload reaches the stage model through `src.*` and is never aliased there, so a
grep for "as <COL>" finds nothing and reports every satellite as having an empty payload. That
proxy emitted 0 satellites on the previous run.
"""
import collections
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hcon_names as N                                             # noqa: E402
import hcon4_emit as E                                             # noqa: E402
import hcon4_plan as P                                             # noqa: E402

LOAD_TS = "current_timestamp() as LOAD_DATETIME"


def required_hubs(sat):
    blocks = E.map_blocks()
    by_sat = collections.defaultdict(list)
    for b in blocks:
        if b["sat"]:
            by_sat[b["sat"]].append(b)
    return P.required_hubs(sat, blocks, by_sat)


def main():
    plan = E.load_plan()
    stages = E.read_manifest("stage_columns.json")
    views = E.read_manifest("view_columns.json")
    pay = E.payload_index()
    counts = collections.Counter()
    by_ordinal = {str(v["ordinal"]): v for v in plan["stitched_views"]}

    # ---------------------------------------------------------------- hub feeds and hubs
    feeds_of = collections.defaultdict(list)
    for key in sorted(stages, key=int):
        sm, v = stages[key], by_ordinal[key]
        for hub, hk in sorted(sm["hash_keys"].items()):
            model = E.hub_feed_model(hub, v)
            body = E.header("gen_hcon4_vault.py", [
                "HUB FEED -- %s, as central view %s sees it." % (hub, key),
                "reads        : %s   (the hash site; this model computes no hash)" % sm["model"],
                "why from here: the satellites on this view are keyed by %s, so the hub keys this"
                % hk,
                "               view produces ARE the hub population it contributes. Deriving",
                "               the hub anywhere else would key the hub from one place and its",
                "               satellites from another, which is the split rule 5 forbids.",
                "grain        : one row per %s" % hk,
                "null keys    : dropped. A null hash key is not a business key, and loading one",
                "               creates a hub row nothing can ever join to.",
            ]) + ("{{ config(materialized='view') }}\n\nselect distinct\n    %s,\n    %s,\n    %s\n"
                  "from {{ ref(%s) }}\nwhere %s is not null\n"
                  % (hk, "%s as RECORD_SOURCE" % N.sql_literal(sm["view_model"]),
                     LOAD_TS, N.sql_literal(sm["model"]), hk))
            E.write(os.path.join("hub_feeds", model + ".sql"), body)
            feeds_of[hub].append(model)
            counts["hub_feeds"] += 1

    for hub in sorted(feeds_of):
        feeds = sorted(feeds_of[hub])
        hk = N.hash_key(hub)
        unions = "\nunion all\n".join(
            "select %s, RECORD_SOURCE, LOAD_DATETIME from {{ ref(%s) }}" % (hk, N.sql_literal(f))
            for f in feeds)
        body = E.header("gen_hcon4_vault.py", [
            "HUB %s" % hub,
            "feeds        : %d, one per central view carrying this hubs key" % len(feeds),
            "grain        : one row per %s, earliest record source kept" % hk,
            "derived from : the central views, via those feeds. This model reads no source table",
            "               and computes no hash -- rule 5, as the user states it: each",
            "               satellites primary key goes to the hub, so the hub comes from where",
            "               the satellite is built.",
        ]) + ("{{ config(materialized='incremental', unique_key=%s) }}\n\nwith feeds as (\n%s\n)"
              "\n\nselect\n    %s,\n    min(RECORD_SOURCE) as RECORD_SOURCE,\n"
              "    min(LOAD_DATETIME) as LOAD_DATETIME\nfrom feeds\nwhere %s is not null\n"
              "group by %s\n" % (N.sql_literal(hk), unions, hk, hk, hk))
        E.write(os.path.join("vault", "hubs", E.hub_model(hub) + ".sql"), body)
        counts["hubs"] += 1

    # ---------------------------------------------------------------- links
    for key in sorted(stages, key=int):
        sm, v = stages[key], by_ordinal[key]
        for link in sorted(v["links"]):
            legs = P.LINK_LEGS.get(link, [])
            missing = [h for h in legs if h not in sm["hash_keys"]]
            if missing:
                E.refuse("link_leg_not_staged_on_its_view", link,
                         "the plan places this link on central view %s, whose stage model emits "
                         "no hash key for leg(s) %s. The link is NOT emitted from a partial "
                         "grain: a link row missing a leg records a relationship to nothing."
                         % (key, ", ".join(missing)), "mapper", view=int(key), legs=legs)
                continue
            hks = [sm["hash_keys"][h] for h in legs]
            lk = N.hash_key(link)
            key_sql = N.hash_expr(link, " || '|' || ".join(
                "coalesce(%s, '')" % hk for hk in hks))
            body = E.header("gen_hcon4_vault.py", [
                "LINK %s" % link,
                "legs         : %d -- %s" % (len(legs), ", ".join(legs)),
                "reads        : %s   (ONE central view)" % sm["model"],
                "why ONE view : rule 6, as the user states it -- the different hub keys and the",
                "               satellite population come from the same view, so the",
                "               relationship this link records is a fact of that views rows and",
                "               not of a join assembled afterwards. Taking two legs from two",
                "               different views would assert a relationship no row ever carried.",
                "which view   : of every view carrying all %d legs, the SMALLEST was chosen --"
                % len(legs),
                "               the tightest co-occurrence in the plan. First-fit put all 71",
                "               links on one 54-table view, which satisfied the rule and meant",
                "               nothing.",
                "grain        : one row per combination of the %d leg key(s)" % len(legs),
                "null legs    : a row with ANY null leg is dropped.",
            ]) + ("{{ config(materialized='incremental', unique_key=%s) }}\n\n"
                  "with src as (\n    select * from {{ ref(%s) }}\n)\n\nselect distinct\n"
                  "    %s as %s,\n    %s,\n    %s as RECORD_SOURCE,\n    %s\nfrom src\nwhere %s\n"
                  % (N.sql_literal(lk), N.sql_literal(sm["model"]), key_sql, lk,
                     ",\n    ".join(hks), N.sql_literal(sm["view_model"]), LOAD_TS,
                     "\n  and ".join("%s is not null" % hk for hk in hks)))
            E.write(os.path.join("vault", "links", E.link_model(link) + ".sql"), body)
            counts["links"] += 1

    # ---------------------------------------------------------------- satellites
    sat_manifest = {}
    for key in sorted(stages, key=int):
        sm, v, vm = stages[key], by_ordinal[key], views[key]
        for sat in sorted(v["satellites"]):
            if sat not in sm["hashdiffs"]:
                continue                    # refused in the stage layer, with its reason
            hd = sm["hashdiffs"][sat]["column"]
            cols = list(sm["hashdiffs"][sat]["payload_columns"])

            hubs, basis = required_hubs(sat)
            anchors = [sm["hash_keys"][h] for h in hubs if h in sm["hash_keys"]]
            if not anchors:
                E.refuse("satellite_anchor_key_not_staged", sat,
                         "its own central view %s stages no hash key for %s, so the satellite "
                         "cannot be keyed from the view it is built on"
                         % (key, ", ".join(hubs)), "mapper", view=int(key),
                         anchor_basis=basis, hubs_required=hubs,
                         hubs_staged=sorted(sm["hash_keys"]))
                continue

            hist, is_ma, decl = E.model_grain(sat)
            resolved, missing = E.resolve_childkey_columns(sat, set(v["tables"]))
            ck_cols = []
            for r in resolved:
                col = vm["attribute_columns"].get(r["leg"])
                if col and col not in ck_cols:
                    ck_cols.append(col)
            # A child-key leg that is also a payload attribute is part of the GRAIN. Keeping it in
            # both lists would select the same alias twice -- 30 models in a sibling build failed
            # exactly that way -- so the LEG is kept and the payload copy is withheld.
            clash = [c for c in cols if c in ck_cols]
            if clash:
                cols = [c for c in cols if c not in ck_cols]
                E.refuse("payload_column_is_also_a_child_key_leg", sat,
                         "%d column(s) %s are both a child-key leg and a payload attribute. The "
                         "LEG is kept because it is part of the grain; the payload copy is "
                         "WITHHELD rather than selected twice." % (len(clash), clash[:5]),
                         "modeller", view=int(key))
            if not cols:
                E.refuse("satellite_payload_entirely_withheld", sat,
                         "after withholding, no payload column remains for this satellite",
                         "mapper", view=int(key))
                continue

            grain = [anchors[0]] + ck_cols
            body = E.header("gen_hcon4_vault.py", [
                "SATELLITE %s" % sat,
                "anchor       : %s   (%s)" % (", ".join(hubs), basis),
                "history      : %s   (from data_7.js -- the MODEL governs grain, never the map,"
                % (hist or "(not stated)"),
                "               which carries multi_active on 690 blocks. A satellite made",
                "               multi-active by a builder has had its primary key changed by a",
                "               builder.)",
                "reads        : %s   -- ONE stage model, ONE central view." % sm["model"],
                "               That is rule 2 made checkable: this satellite is fed WHOLE from",
                "               one view, so a second source here would be a violation a gate",
                "               can see. No union over feeders, because there is one feeder.",
                "payload      : %d attribute(s), as the central view rendered them" % len(cols),
                "grain        : one row per %s" % ", ".join(grain),
                "child key    : %s" % (("%d leg(s) resolved: %s" % (len(ck_cols),
                                                                    ", ".join(ck_cols)))
                                       if ck_cols else
                                       ("declared %r in the model but NO leg resolved to a column "
                                        "on this view -- registered, not rendered" % decl)
                                       if (is_ma and decl) else "none declared"),
                "hashdiff     : %s, GUARDED in the stage model against an all-null input. A row" % hd,
                "               whose hashdiff is null is DROPPED rather than loaded: an",
                "               unguarded all-null hashdiff collapses the satellite to one row",
                "               and the collapse looks like working change detection.",
            ]) + ("{{ config(materialized='incremental') }}\n\nwith src as (\n"
                  "    select * from {{ ref(%s) }}\n)\n\nselect\n    %s,\n    %s,\n    %s,\n"
                  "    %s as RECORD_SOURCE,\n    %s\nfrom src\nwhere %s is not null\n"
                  "  and %s is not null\n"
                  % (N.sql_literal(sm["model"]), ",\n    ".join(grain), hd, ",\n    ".join(cols),
                     N.sql_literal(sm["view_model"]), LOAD_TS, anchors[0], hd))
            E.write(os.path.join("vault", "satellites", E.sat_model(sat) + ".sql"), body)
            sat_manifest[sat] = {"model": E.sat_model(sat), "view": int(key),
                                 "stage": sm["model"], "anchor_hash_key": anchors[0],
                                 "anchor_hub": anchors[0][:-3], "hashdiff": hd,
                                 "payload_columns": cols, "child_key_columns": ck_cols,
                                 "history": hist}
            counts["satellites"] += 1

    E.write_manifest("satellite_columns.json", sat_manifest)
    print("  vault             : %d hub feed(s), %d hub(s), %d link(s), %d satellite(s)"
          % (counts["hub_feeds"], counts["hubs"], counts["links"], counts["satellites"]))
    return counts


if __name__ == "__main__":
    main()
