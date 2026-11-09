# -*- coding: utf-8 -*-
"""The UNRATIFIED track: 948 augmentation blocks, all tier 'build-side'.

The authoritative not-yet-applied test is tier == 'build-side' (948 of 948).
augmentation.applied exists on only 4 of 948 blocks and is False on all four, so a
reader filtering `applied is False` finds 4, not 948 -- true in intent, false as a
field test.

ONE BUILD-SIDE SATELLITE PER CONCEPT across both feeds, never two. 113
augmentation homes write into satellites that exist in data_7.js; 16 propose NEW
satellites totalling 156 columns.

Two directives land here:
  * SAT_CLAIM_STATUS_TRANSITION is caller-ratified multi-active at the Maximus
    grain, child key 'Status Code | Transition Date', and the attribute union is
    SEVEN not eight -- 'Transition Actor User Reference' and 'Transition Performed
    By Reference' are the SAME FACT fed from both sides.
  * 13 compound-declared blocks resolve ZERO declared legs on satellites absent
    from data_7.js. They are promotion preconditions, not build defects, and they
    ship WITH AN EXPLICIT UNRESOLVED-CHILD-KEY MARKER so the gap travels with the
    rows.
"""
import collections

import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N
from gen_mxh3_stage import key_slots

GEN = "gen_mxh3_augmented.py"

SUPPRESS = {("SAT_CLAIM_COVER_SECTION_ASSESSMENT", "Last EMI Paid Date"),
            ("SAT_CLAIM_COVER_SECTION_ASSESSMENT", "Outstanding Loan Amount")}


def main():
    sp = E.spec()
    slots = key_slots(sp)
    byexpr = {}
    for (view, hub, i), d in slots.items():
        byexpr[(view, hub, d["expression"])] = i

    model_attrs = sp["model"]["sat_attrs"]
    aliases = K.ATTRIBUTE_UNION_ALIASES

    bysat = collections.defaultdict(list)
    suppressed = 0
    for b in sp["blocks"]:
        if b["side"] != "augmentation" or not b["home"] or not b["attribute"]:
            continue
        if (b["home"], b["attribute"]) in SUPPRESS:
            suppressed += 1
            continue
        if b["refuse_row"] or b.get("refused_s54_collision"):
            continue
        bysat[b["home"]].append(b)

    n = 0
    newsat = unresolved_marked = 0
    skipped = []
    for sat in sorted(bysat):
        blocks = bysat[sat]
        in_model = sat in model_attrs
        if not in_model:
            newsat += 1
        # the attribute union, with the declared same-fact aliases COLLAPSED
        union = []
        for b in blocks:
            a = aliases.get(b["attribute"], b["attribute"])
            if a not in union:
                union.append(a)

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
            skipped.append((sat, "no augmentation block resolves to a declared anchor slot: "
                                 "the anchor is refused or ambiguous, and a feeder is "
                                 "(view, DECLARED ANCHOR EXPRESSION) -- never keyed on a guess"))
            continue

        # declared child-key legs: from the model where it speaks, else the map's own
        declared_ck = N.split_declared_childkey(sp["model"]["sat_childkey"].get(sat, ""))
        map_ck = []
        for b in blocks:
            for leg in (b.get("rendered_child_key") or {}):
                if leg not in map_ck:
                    map_ck.append(leg)
        legs = declared_ck or map_ck
        unresolved_legs = sorted({ls["leg"] for b in blocks for ls in b["leg_status"]
                                  if ls["state"] == "unresolved" and ls["leg"]})

        parts = []
        for (view, hub, i), bs in sorted(feeders.items()):
            bk = E.bk_name(hub, i)
            fl = E.emit_flag_name("%s_K%d" % (hub, i))
            supplied, ck = {}, {}
            for b in bs:
                a = aliases.get(b["attribute"], b["attribute"])
                supplied.setdefault(a, b["column"])
                for leg, sql in (b.get("rendered_child_key") or {}).items():
                    ck.setdefault(leg, sql)
            cols = ["        md5(upper(%s)) as %s" % (bk, E.hk_name(hub))]
            emitted = {E.hk_name(hub)}
            for leg in legs:
                c = N.childkey_column(leg)
                if c in emitted:
                    continue
                emitted.add(c)
                cols.append("        %s as %s" % (ck.get(leg, "null::varchar"), c))
            for a in union:
                col = N.attribute_column(a)
                # ONE column per name -- see gen_mxh3_vault.py for why.
                if col in emitted:
                    continue
                emitted.add(col)
                cols.append("        %s as %s"
                            % (N.quote_ident(supplied[a]) if a in supplied
                               else "null::varchar", col))
            # THE UNRESOLVED-CHILD-KEY MARKER travels with the rows.
            cols.append("        %s as CHILD_KEY_RESOLUTION"
                        % K.sql_literal("UNRESOLVED_DECLARED_LEGS: " +
                                        ", ".join(unresolved_legs)
                                        if unresolved_legs else "RESOLVED"))
            cols.append("        %s as TRACK" % K.sql_literal("build-side_unratified"))
            cols.append("        %s" % E.record_source(view))
            cols.append("        %s" % E.LOAD_DT)
            parts.append("    select\n" + ",\n".join(cols) +
                         "\n    from {{ ref('%s') }}\n    where %s"
                         % (N.stage_name(view), fl))
        if unresolved_legs:
            unresolved_marked += 1

        payload = [N.attribute_column(a) for a in union if a not in legs]
        hd = E.hashdiff_name(sat)
        guard = " or ".join("%s is not null" % c for c in payload) or "true"
        hashin = " || '||' || ".join("coalesce(%s::varchar,'')" % c
                                     for c in payload) or "''"
        anchor_hub = sorted({h for (_v, h, _i) in feeders})[0]
        hdr = [
            "%s  [UNRATIFIED build-side track]" % sat,
            "in data_7.js : %s" % ("YES -- augmentation writes into an EXISTING model "
                                   "satellite" if in_model else
                                   "NO -- PROPOSED new satellite"),
            "anchor       : %s" % anchor_hub,
            "feeders      : %d -- one per (view, DECLARED ANCHOR EXPRESSION)" % len(parts),
            "payload      : %d attribute(s), NULL-PADDED TO THE SATELLITE" % len(union),
            "child key    : %s" % (" + ".join(legs) if legs else "(none declared)"),
            "tier         : build-side (948 of 948 -- the authoritative",
            "               not-yet-applied test; augmentation.applied is present on",
            "               only 4 blocks and would report 4, not 948)",
        ]
        if unresolved_legs:
            hdr += ["",
                    "UNRESOLVED CHILD KEY: declared leg(s) %s resolve NOTHING on the"
                    % ", ".join(unresolved_legs),
                    "feeding view(s). The rows ship WITH the CHILD_KEY_RESOLUTION marker",
                    "below rather than silently at the wrong grain. This is a promotion",
                    "precondition, not a build defect."]
        if sat == "SAT_CLAIM_STATUS_TRANSITION":
            hdr += ["",
                    "CALLER-RATIFIED multi-active at the Maximus grain. The attribute union",
                    "is SEVEN, not eight: 'Transition Actor User Reference' (OPUS) and",
                    "'Transition Performed By Reference' (Maximus) are the SAME FACT and are",
                    "collapsed onto one column. VERSION_NO is DROPPED as an ordinal."]
        sql = "\n".join([
            E.config("incremental"),
            E.header(GEN, hdr),
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
            "where %s is not null" % E.hk_name(anchor_hub),
        ])
        E.write_model("augmented", N.augmented_name(sat), sql, GEN)
        n += 1

    print("augmented models emitted     : %d" % n)
    print("  proposing a NEW satellite  : %d" % newsat)
    print("  carrying an UNRESOLVED-child-key marker: %d" % unresolved_marked)
    print("  attributes suppressed by BI-4.1 routing : %d  (built on the ratified "
          "SAT_CLAIM_BENEFIT_HEAD instead)" % suppressed)
    print("  SKIPPED, with reason       : %d" % len(skipped))
    for s in skipped[:10]:
        print("     %-38s %s" % (s[0], s[1][:96]))
    E.checkpoint("augmented", n, {"new_satellites": newsat,
                                  "unresolved_child_key_marked": unresolved_marked,
                                  "bi41_suppressed": suppressed,
                                  "skipped": len(skipped)})
    return n


if __name__ == "__main__":
    main()
