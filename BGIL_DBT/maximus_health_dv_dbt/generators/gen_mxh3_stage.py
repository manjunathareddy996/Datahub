# -*- coding: utf-8 -*-
"""One wide stage per view: the cast columns, the resolved walk columns, and every
declared key slot with its EMIT FLAG.

THE EMIT FLAG IS THE HEART OF THIS BUILD. 2,100 key blocks render NULL on a blank
row, and on Snowflake the load DROPS a NULL key -- unlogged data loss that reads
as a sparse source. Each key slot therefore carries a boolean

    case when <emit predicate> then true else false end as <slot>__EMIT

which is NEVER NULL, so `flag` and `not flag` partition every row exactly. The
reject log selects `not (<the identical predicate>)`, which makes the two exact
boolean complements BY CONSTRUCTION rather than by inspection: a row is emitted
or rejected, never both and never neither.

A FEEDER IS (view, DECLARED ANCHOR EXPRESSION), never (view) alone: a view that
reaches one hub through several declared key expressions gets one slot per
expression, ordinal-numbered, so two namespaces on one view stay distinct instead
of one becoming unreachable.
"""
import collections

import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N

GEN = "gen_mxh3_stage.py"


def key_slots(sp):
    """(view, hub, instance, expression) -> stable ordinal within (view, hub)."""
    per = collections.defaultdict(set)
    for b in sp["blocks"]:
        rk = b["resolved_key"]
        if b.get("has_resolved_key") and rk["expression"] and rk["hub"]:
            per[(b["view"], rk["hub"])].add(
                (rk["expression"], b["rendered"], b["emit"], b["reject"],
                 b["reject_class"], rk["tier"], tuple(rk["source_columns"])))
    out = {}
    for (view, hub), exprs in per.items():
        for i, e in enumerate(sorted(exprs)):
            out[(view, hub, i)] = {
                "expression": e[0], "rendered": e[1], "emit": e[2], "reject": e[3],
                "reject_class": e[4], "tier": e[5], "source_columns": list(e[6]),
            }
    return out


def main():
    sp = E.spec()
    slots = key_slots(sp)
    staging = sp["views"]["staging"]
    hop = sp["views"]["hopviews"]
    resolvers = sp["views"]["resolvers"]

    by_view = collections.defaultdict(list)
    for (view, hub, i), d in slots.items():
        by_view[view].append((hub, i, d))

    n = flags = 0
    for view in sorted(set(list(staging) + list(by_view))):
        src = (staging.get(view) or hop.get(view))
        if src is None:
            continue
        res = resolvers.get(view)
        cols = ["    src.*"]
        if res:
            wcols = sorted({N.fit("W%03d_%s" % (s["ordinal"],
                                                s["terminal_column"] or "VALUE"))
                            for s in sp["spans"] if s["from_view"] == view})
            ncols = sorted({N.fit("W%03d_N" % s["ordinal"])
                            for s in sp["spans"] if s["from_view"] == view})
            for cc in wcols + ncols:
                cols.append("    res.%s as %s" % (cc, cc))
        declared = sorted(by_view.get(view, []), key=lambda x: (x[0], x[1]))
        for hub, i, d in declared:
            bk = E.bk_name(hub, i)
            fl = E.emit_flag_name("%s_K%d" % (hub, i))
            cols.append("    %s as %s" % (d["rendered"], bk))
            # NEVER NULL: case/else guarantees a two-valued flag, so the reject
            # predicate is an exact complement.
            cols.append("    case when %s then true else false end as %s"
                        % (d["emit"], fl))
            flags += 1

        lines = [
            E.config("view"),
            E.header(GEN, [
                "source view : %s" % view,
                "cast        : %s" % src["model"],
                "resolver    : %s" % (res["model"] if res else "none -- no walk on this view"),
                "key slots   : %d (one per DECLARED ANCHOR EXPRESSION, never one per view)"
                % len(declared),
                "",
                E.ENGINE_NOTE,
                "",
                "Key expressions are emitted VERBATIM from the map: no separator is tidied,",
                "no inner coalesce of a content hash is removed, and no population namespace",
                "(MEMBER:/AGENT:/PROVIDER:/IMD:/EMP:/COV:/USER:/SPECIFIED_PERSON:/DOCTOR:/",
                "PROPOSAL:) is stripped -- removing one merges identifier spaces on one hub",
                "and is unrecoverable.",
            ] + ["slot %-26s %-18s tier=%s reject_class=%s"
                 % (E.bk_name(h, i), "", d["tier"], d["reject_class"])
                 for h, i, d in declared[:8]]),
            "",
            "with src as (select * from {{ ref('%s') }})" % src["model"],
        ]
        if res:
            lines += [", res as (select * from {{ ref('%s') }})" % res["model"]]
        lines += ["", "select", ",\n".join(cols), "from src"]
        if res:
            lines.append("left join res on src.%s = res.%s"
                         % (res["join_key"], res["join_key"]))
        E.write_model("stage", N.stage_name(view), "\n".join(lines), GEN)
        n += 1

    print("wide stages emitted          : %d" % n)
    print("  key slots with an EMIT flag: %d  (UNIT=slots, POPULATION=(view,hub,expression))"
          % flags)
    E.checkpoint("stage", n, {"key_slots": flags})
    return n


if __name__ == "__main__":
    main()
