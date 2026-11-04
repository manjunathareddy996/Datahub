# -*- coding: utf-8 -*-
"""Hub feeds, hubs, links and satellites.

A FEEDER IS (view, DECLARED ANCHOR EXPRESSION) -- never (view) alone. On the
calibration sibling a view-only feeder key forced a fallback that picked an
arbitrary key slot from another hub: one satellite emitted the sub-intermediary's
name on the relationship manager's key, five parties collapsed onto one key, four
names were dropped, and it compiled cleanly. Every feeder here is named for its
hub, its view AND the ordinal of the declared key expression it uses, so two
namespaces on one view can never merge.

A satellite's payload is NULL-PADDED TO THE SATELLITE, not to the feeder group:
every feeder selects the satellite's whole attribute union, with NULL where that
feeder supplies nothing. Padding to the feeder group instead makes a satellite's
column list depend on which views happened to feed it.

The hashdiff is GUARDED against an all-null input: without the guard every
all-null row hashes to one value and the whole population collapses onto one row.
"""
import collections

import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N
from gen_mxh3_stage import key_slots

GEN = "gen_mxh3_vault.py"


def _built(b):
    return not (b["refuse_row"] or b["refused_unrenderable_key"]
                or b.get("refused_s54_collision") or b["refused_by_disposition"])


def main():
    sp = E.spec()
    slots = key_slots(sp)
    # expression -> (view, hub, ordinal)
    byexpr = {}
    for (view, hub, i), d in slots.items():
        byexpr[(view, hub, d["expression"])] = i

    n_feed = n_hub = n_link = n_sat = 0

    # ----------------------------------------------------------------- hub feeds
    hub_feeds = collections.defaultdict(list)
    for (view, hub, i), d in sorted(slots.items()):
        name = N.hub_feed_name(hub, view, i)
        bk, fl = E.bk_name(hub, i), E.emit_flag_name("%s_K%d" % (hub, i))
        sql = "\n".join([
            E.config("view"),
            E.header(GEN, [
                "source view : %s" % view,
                "target hub  : %s" % hub,
                "feeder key  : (view, DECLARED ANCHOR EXPRESSION) -- slot ordinal %d" % i,
                "key tier    : %s" % d["tier"],
                "reject class: %s" % d["reject_class"],
                "operands    : %s" % (", ".join(d["source_columns"]) or "none (pure literal)"),
                "",
                "The WHERE below IS the declared emit predicate. A row failing it is",
                "diverted to the reject log and is never silently dropped.",
            ]),
            "",
            "select",
            "    md5(upper(%s)) as %s," % (bk, E.hk_name(hub)),
            "    %s as %s," % (bk, bk),
            "    %s," % E.record_source(view),
            "    %s" % E.LOAD_DT,
            "from {{ ref('%s') }}" % N.stage_name(view),
            "where %s" % fl,
        ])
        E.write_model("vault/hub_feeds", name, sql, GEN)
        hub_feeds[hub].append((name, bk))
        n_feed += 1

    # ---------------------------------------------------------------------- hubs
    for hub in sorted(hub_feeds):
        feeds = sorted(hub_feeds[hub])
        parts = ["    select %s, %s as BUSINESS_KEY, RECORD_SOURCE, LOAD_DATETIME\n"
                 "    from {{ ref('%s') }}" % (E.hk_name(hub), bk, nm)
                 for nm, bk in feeds]
        sql = "\n".join([
            E.config("incremental", ["unique_key='%s'" % E.hk_name(hub)]),
            E.header(GEN, [
                "%s : assembled from %d per-source feed(s)." % (hub, len(feeds)),
                "EVERY feed of this hub is consumed here and nowhere else -- the",
                "completeness invariant is asserted by check_mxh3_hashkeys.py in the",
                "build chain, in BOTH directions.",
            ]),
            "",
            "with feeds as (",
            "\n    union all\n".join(parts),
            ")",
            "",
            "select",
            "    %s," % E.hk_name(hub),
            "    BUSINESS_KEY,",
            "    min(RECORD_SOURCE) as RECORD_SOURCE,",
            "    min(LOAD_DATETIME) as LOAD_DATETIME",
            "from feeds",
            "where %s is not null" % E.hk_name(hub),
            "group by %s, BUSINESS_KEY" % E.hk_name(hub),
        ])
        E.write_model("vault/hubs", N.hub_name(hub), sql, GEN)
        n_hub += 1

    # --------------------------------------------------------------------- links
    link_feeds = collections.defaultdict(list)
    for b in sp["blocks"]:
        rl = b["resolved_key"]
        if not rl.get("link") or not b.get("rendered_legs"):
            continue
        if not _built(b):
            continue
        link = rl["link"]
        legs = {h: v for h, v in b["rendered_legs"].items() if v}
        if len(legs) != len(rl["legs"]):
            continue
        sig = tuple(sorted(legs.items()))
        link_feeds[link].append((b["view"], sig, b))

    for link in sorted(link_feeds):
        seen, feeds = set(), []
        for view, sig, b in sorted(link_feeds[link], key=lambda x: (x[0], str(x[1]))):
            if (view, sig) in seen:
                continue
            seen.add((view, sig))
            i = len(feeds)
            name = N.link_feed_name(link, view, i)
            hubs = [h for h, _ in sig]
            hkcols = ", ".join("md5(upper(%s)) as %s" % (v, E.hk_name(h)) for h, v in sig)
            concat = " || '||' || ".join("coalesce(%s,'')" % v for _h, v in sig)
            sql = "\n".join([
                E.config("view"),
                E.header(GEN, [
                    "source view : %s" % view,
                    "target link : %s" % link,
                    "legs        : %d -- %s" % (len(sig), ", ".join(hubs)),
                    "feeder key  : (view, DECLARED LEG EXPRESSIONS), ordinal %d" % i,
                    "",
                    "11 leg entries in this map are PURE LITERALS (all the HUB_COVERAGE leg",
                    "of LNK_POLICY_COVERAGE_RISK); in every one the sibling legs carry real",
                    "operands, so the composite link key still discriminates. Accepted.",
                ]),
                "",
                "select",
                "    md5(upper(%s)) as %s," % (concat, E.hk_name(link)),
                "    %s," % hkcols,
                "    %s," % E.record_source(view),
                "    %s" % E.LOAD_DT,
                "from {{ ref('%s') }}" % N.stage_name(view),
                "where %s is not null" % concat.split(" || ")[0],
            ])
            E.write_model("vault/link_feeds", name, sql, GEN)
            feeds.append((name, hubs))
            n_feed += 1

        allhubs = sorted({h for _n, hs in feeds for h in hs})
        parts = []
        for nm, hs in feeds:
            cols = [E.hk_name(link)] + [E.hk_name(h) for h in allhubs]
            sel = ", ".join(
                (c if (c == E.hk_name(link) or c in [E.hk_name(x) for x in hs])
                 else "null::varchar as %s" % c) for c in cols)
            parts.append("    select %s, RECORD_SOURCE, LOAD_DATETIME\n    from {{ ref('%s') }}"
                         % (sel, nm))
        sql = "\n".join([
            E.config("incremental", ["unique_key='%s'" % E.hk_name(link)]),
            E.header(GEN, [
                "%s : assembled from %d per-source feed(s)." % (link, len(feeds)),
                "hub legs    : %s" % ", ".join(allhubs),
                "EVERY per-source link feed is consumed HERE. The sibling unioned 4",
                "per-source link feeds into ZERO assembled links because the link layer",
                "had no completeness invariant; this build asserts one in both directions.",
            ]),
            "",
            "with feeds as (",
            "\n    union all\n".join(parts),
            ")",
            "",
            "select",
            "    %s," % E.hk_name(link),
            ",\n".join("    %s" % E.hk_name(h) for h in allhubs) + ",",
            "    min(RECORD_SOURCE) as RECORD_SOURCE,",
            "    min(LOAD_DATETIME) as LOAD_DATETIME",
            "from feeds",
            "where %s is not null" % E.hk_name(link),
            "group by %s" % ", ".join([E.hk_name(link)] +
                                      [E.hk_name(h) for h in allhubs]),
        ])
        E.write_model("vault/links", N.link_name(link), sql, GEN)
        n_link += 1

    # ---------------------------------------------------------------- satellites
    n_sat, skipped = _satellites(sp, slots, byexpr)

    print("hub feeds / link feeds emitted: %d" % n_feed)
    print("hubs emitted                  : %d" % n_hub)
    print("links emitted                 : %d" % n_link)
    print("satellites emitted            : %d" % n_sat)
    print("satellites SKIPPED, with reason: %d" % len(skipped))
    for s in skipped[:12]:
        print("   %-40s %s" % (s[0], s[1]))
    E.checkpoint("vault", n_feed + n_hub + n_link + n_sat,
                 {"hub_feeds_and_link_feeds": n_feed, "hubs": n_hub,
                  "links": n_link, "satellites": n_sat,
                  "satellites_skipped": len(skipped)})
    return n_feed + n_hub + n_link + n_sat


def _satellites(sp, slots, byexpr):
    model_attrs = sp["model"]["sat_attrs"]
    model_hist = sp["model"]["sat_hist"]
    model_parent = sp["model"]["sat_parent"]
    model_ck = sp["model"]["sat_childkey"]

    # group BUILT blocks by satellite
    bysat = collections.defaultdict(list)
    for b in sp["blocks"]:
        if not b["home"] or not b["attribute"]:
            continue
        if not _built(b):
            continue
        if (b["home"], b["attribute"]) in {tuple(x) for x in
                                           [("SAT_CLAIM_COVER_SECTION_ASSESSMENT",
                                             "Last EMI Paid Date"),
                                            ("SAT_CLAIM_COVER_SECTION_ASSESSMENT",
                                             "Outstanding Loan Amount")]}:
            continue                       # BI-4.1 attribute routing
        bysat[b["home"]].append(b)

    n = 0
    skipped = []
    for sat in sorted(bysat):
        blocks = bysat[sat]
        ratified = sat in model_attrs
        if not ratified:
            continue                       # the augmented track owns these
        union = [a for a in model_attrs[sat]
                 if a in {b["attribute"] for b in blocks}]
        if not union:
            sides = {b["side"] for b in blocks}
            proposed = sorted({b["attribute"] for b in blocks
                               if b["attribute"] not in model_attrs[sat]})
            if sides == {"augmentation"}:
                why = ("every attribute reaching it is augmentation-PROPOSED and not "
                       "canonical for this satellite (%d: %s) -- the AUGMENTED track owns "
                       "these, so this is a routing outcome, not a source gap"
                       % (len(proposed), ", ".join(proposed[:3])))
            else:
                why = ("%d block(s) reach it but none supplies a canonical attribute; "
                       "proposed-but-not-canonical: %s"
                       % (len(blocks), ", ".join(proposed[:3])))
            skipped.append((sat, why))
            continue
        parent = model_parent.get(sat)
        declared_ck = N.split_declared_childkey(model_ck.get(sat, ""))

        feeders = collections.defaultdict(list)
        for b in blocks:
            rk = b["resolved_key"]
            hub = rk["hub"] or b["anchor"]
            expr = rk["expression"] or b.get("anchor_expression")
            if not hub or not expr:
                continue
            i = byexpr.get((b["view"], hub, expr))
            if i is None:
                continue
            feeders[(b["view"], hub, i)].append(b)
        if not feeders:
            skipped.append((sat, "no built block resolves to a declared anchor slot "
                                 "(anchor refused or ambiguous)"))
            continue

        parts = []
        for (view, hub, i), bs in sorted(feeders.items()):
            bk = E.bk_name(hub, i)
            fl = E.emit_flag_name("%s_K%d" % (hub, i))
            supplied = {}
            for b in bs:
                if b["attribute"] in union:
                    supplied[b["attribute"]] = b["column"]
            ck = {}
            for b in bs:
                for leg, sql in (b.get("rendered_child_key") or {}).items():
                    ck.setdefault(leg, sql)
            cols = ["        md5(upper(%s)) as %s" % (bk, E.hk_name(hub))]
            emitted = {E.hk_name(hub)}
            for leg in declared_ck:
                c = N.childkey_column(leg)
                if c in emitted:
                    continue
                emitted.add(c)
                if leg in ck:
                    cols.append("        %s as %s" % (ck[leg], c))
                else:
                    cols.append("        null::varchar as %s" % c)
            for a in union:
                col = N.attribute_column(a)
                # ONE column per name: a declared leg already emitted above must not
                # be emitted again as a payload attribute. Two columns with one name
                # is the shape the sibling ships on 7 models.
                if col in emitted:
                    continue
                emitted.add(col)
                if a in supplied:
                    cols.append("        %s as %s"
                                % (N.quote_ident(supplied[a]), col))
                else:
                    # NULL-PADDED TO THE SATELLITE, not to the feeder group.
                    cols.append("        null::varchar as %s" % col)
            cols.append("        %s" % E.record_source(view))
            cols.append("        %s" % E.LOAD_DT)
            parts.append("    select\n" + ",\n".join(cols) +
                         "\n    from {{ ref('%s') }}\n    where %s"
                         % (N.stage_name(view), fl))

        payload = [N.attribute_column(a) for a in union
                   if not (a in declared_ck)]
        hd = E.hashdiff_name(sat)
        guard = " or ".join("%s is not null" % c for c in payload) or "true"
        hashin = " || '||' || ".join("coalesce(%s::varchar,'')" % c
                                     for c in payload) or "''"
        ckcols = [N.childkey_column(l) for l in declared_ck]
        sql = "\n".join([
            E.config("incremental"),
            E.header(GEN, [
                "%s" % sat,
                "anchor      : %s" % parent,
                "grain       : %s (data_7.js sats[].hist)" % model_hist.get(sat),
                "child key   : %s" % (model_ck.get(sat) or "(none declared)"),
                "feeders     : %d -- one per (view, DECLARED ANCHOR EXPRESSION)" % len(parts),
                "payload     : %d attribute(s), NULL-PADDED TO THE SATELLITE" % len(union),
                "",
                "The child key is the MODEL'S declared key, read from data_7.js",
                "sats[].childkey keyed by sats[].code. target.key_name is the HUB key",
                "name and is null on all 1,888 satellite rows, so it is never read here.",
                "",
                "The hashdiff is GUARDED against an all-null input: without the guard",
                "every all-null row hashes to ONE value and the population collapses.",
            ]),
            "",
            "with feeders as (select * from (",
            "\n    union all\n".join(parts),
            ")), hashed as (select *,",
            "        case when %s" % guard,
            "             then md5(upper(%s))" % hashin,
            "        end as %s" % hd,
            "    from feeders)",
            "",
            "select * from hashed",
            "where %s is not null" % E.hk_name(parent or "HUB_UNKNOWN"),
            "  and %s is not null" % hd,
        ] + (["  and %s is not null" % c for c in ckcols]))
        E.write_model("vault/satellites", N.sat_name(sat), sql, GEN)
        n += 1
    return n, skipped


if __name__ == "__main__":
    main()
