# -*- coding: utf-8 -*-
"""One resolver per START VIEW. Joins EXPANDED PER REAL LEVEL (s4).

A named destination may skip levels, and on this feed that is the DOMINANT case:
only 52 of 1,812 climbs name the direct parent. Every intervening level the
expression does not name is materialised as its own join here. A single join
spanning several levels would silently read a different node's value.

DIRECTION IS CLASSIFIED FROM THE GRAPH, NEVER FROM THE ARROW TOKEN. A climb
ascends child.PARENT_KEY_HASH = parent.KEY_HASH one real level at a time. A cross
climbs to the lowest common ancestor and then DESCENDS into another branch.

A CROSS CAN MATCH N ROWS PER SOURCE ROW. The crossed value is therefore exposed
ONLY when it matches exactly one row, and the match COUNT is always exposed
beside it so a fan-out is COUNTED rather than silently resolved to an arbitrary
branch. A fallback that guesses converts a loud gap into a silent corruption.
"""
import mxh3_emit as E
import mxh3_keyrules as K
import mxh3_names as N

GEN = "gen_mxh3_resolvers.py"


def _cast_models(sp):
    out = {}
    for v, d in sp["views"]["staging"].items():
        out[v] = d["model"]
    for v, d in sp["views"]["hopviews"].items():
        out.setdefault(v, d["model"])
    return out


def _span_sql(s, casts, ordinal):
    """One LEFT JOIN subquery materialising a single span, level by level."""
    climb = list(s["climb_real"])
    desc = list(s["descend_real"])
    chain = [("c%d" % i, v) for i, v in enumerate(climb)] + \
            [("d%d" % i, v) for i, v in enumerate(desc)]
    for _a, v in chain:
        if v not in casts:
            raise AssertionError("span level %r has no cast model" % v)

    lines = []
    first_alias, first_view = chain[0]
    # The join key back to the source row.
    if climb:
        jk = "%s.KEY_HASH" % first_alias
        on_src = s["start"]
    else:
        jk = "%s.PARENT_KEY_HASH" % first_alias
        on_src = "KEY_HASH"

    term_alias = chain[-1][0]
    term_col = s["terminal_column"]
    is_cross = bool(desc)

    jkc, vc, nc = "_JK%03d" % ordinal, "_V%03d" % ordinal, "_N%03d" % ordinal
    lines.append("    select")
    lines.append("        %s as %s," % (jk, jkc))
    if is_cross:
        lines.append("        count(*) as %s," % nc)
        lines.append("        max(%s.%s) as %s" % (term_alias, term_col, vc))
    else:
        lines.append("        max(%s.%s) as %s," % (term_alias, term_col, vc))
        lines.append("        count(*) as %s" % nc)
    lines.append("    from {{ ref('%s') }} %s" % (casts[first_view], first_alias))
    prev_alias, prev_view = first_alias, first_view
    for i in range(1, len(climb)):
        a, v = chain[i]
        lines.append("    join {{ ref('%s') }} %s"
                     "\n        on %s.PARENT_KEY_HASH = %s.KEY_HASH   /* real level %d */"
                     % (casts[v], a, prev_alias, a, i))
        prev_alias = a
    if desc:
        # climb[-1] (the LCA) -> descend[0]
        d0_alias = "d0"
        if climb:
            lines.append("    join {{ ref('%s') }} %s"
                         "\n        on %s.KEY_HASH = %s.PARENT_KEY_HASH"
                         "   /* LCA -> other branch */"
                         % (casts[desc[0]], d0_alias, prev_alias, d0_alias))
        prev_alias = d0_alias
        for i in range(1, len(desc)):
            a = "d%d" % i
            lines.append("    join {{ ref('%s') }} %s"
                         "\n        on %s.KEY_HASH = %s.PARENT_KEY_HASH"
                         "   /* descend real level %d */"
                         % (casts[desc[i]], a, prev_alias, a, i))
            prev_alias = a
    lines.append("    group by %s" % jk)
    return on_src, "\n".join(lines), is_cross, jkc, vc, nc


def main():
    sp = E.spec()
    casts = _cast_models(sp)
    spans_by_view = {}
    for s in sp["spans"]:
        spans_by_view.setdefault(s["from_view"], []).append(s)

    n = cross_n = climb_n = 0
    for view in sorted(sp["views"]["resolvers"]):
        d = sp["views"]["resolvers"][view]
        spans = sorted(spans_by_view.get(view, []), key=lambda x: x["ordinal"])
        if not spans:
            continue
        src = casts[view]
        selects, joins = [], []
        for s in spans:
            on_src, sub, is_cross, jkc, vc, nc = _span_sql(s, casts, s["ordinal"])
            w = "w%03d" % s["ordinal"]
            col = N.fit("W%03d_%s" % (s["ordinal"], s["terminal_column"] or "VALUE"))
            cnt = N.fit("W%03d_N" % s["ordinal"])
            if is_cross:
                cross_n += 1
                selects.append(
                    "    case when %s.%s = 1 then %s.%s else null end as %s,"
                    % (w, nc, w, vc, col))
            else:
                climb_n += 1
                selects.append("    %s.%s as %s," % (w, vc, col))
            selects.append("    %s.%s as %s," % (w, nc, cnt))
            joins.append("left join (\n%s\n) %s on src.%s = %s.%s"
                         % (sub, w, on_src, w, jkc))

        jk = d["join_key"]
        # Every start token the spans join on must be exposed by the CTE, not just
        # the join key: a climb starts at PARENT_KEY_HASH or FOREIGN_KEY, and a bare
        # descend starts at KEY_HASH.
        starts = sorted({s["start"] for s in spans} | {jk})
        starts = [c for c in starts if c in K.view_columns(view)]
        missing = sorted({s["start"] for s in spans} - set(starts))
        if missing:
            raise AssertionError(
                "resolver for %s needs start token(s) %s which the view does not carry"
                % (view, missing))
        sql = "\n".join([
            E.config("view"),
            E.header(GEN, [
                "start view  : %s" % view,
                "spans       : %d (%d climb, %d cross) -- one LEFT JOIN each"
                % (len(spans),
                   sum(1 for s in spans if s["kind"] == "climb"),
                   sum(1 for s in spans if s["kind"] == "cross")),
                "real levels : %s"
                % ", ".join("W%03d=%d named/%d real"
                            % (s["ordinal"], s["levels_named"], s["levels_real"])
                            for s in spans[:6]),
                "EVERY intervening level is its own join: only 52 of 1,812 climbs name",
                "the direct parent, so a single multi-level join would read the wrong node.",
                "Direction is classified FROM THE GRAPH (shred.parent_table_candidate),",
                "never from the arrow token.",
                "A cross exposes W###_N beside every value; the value is NULL unless the",
                "match is UNIQUE, so a 1:N cross is COUNTED, not silently resolved.",
            ]),
            "",
            "with src as (",
            "    select %s from {{ ref('%s') }}" % (", ".join(starts), src),
            ")",
            "",
            "select",
            "    src.%s as %s," % (jk, jk),
            "\n".join(selects).rstrip(","),
            "from src",
            "\n".join(joins),
        ])
        # trailing comma guard
        sql = sql.replace(",\nfrom src", "\nfrom src")
        E.write_model("resolvers", d["model"], sql, GEN)
        n += 1

    print("resolvers emitted            : %d  (one per START view)" % n)
    print("  span joins: climb / cross  : %d / %d" % (climb_n, cross_n))
    print("  cross spans expose a match COUNT and NULL the value unless unique")
    E.checkpoint("resolvers", n, {"climb_span_joins": climb_n, "cross_span_joins": cross_n})
    return n


if __name__ == "__main__":
    main()
