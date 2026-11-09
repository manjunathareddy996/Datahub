# -*- coding: utf-8 -*-
"""Layer 2: THE CENTRAL VIEWS. This is the layer the governing rule is about.

One model per stitched view. It joins that view's source tables on a planned key path and merges
their attributes sideways, producing ONE clean row per key for the satellites it feeds -- whole,
never split. Nothing is hashed here: there is nothing to hash until this join has produced the
row, which is why the hash site is the next layer and not this one.

HOW THE JOIN IS BUILT
---------------------
Each table becomes a CTE that renders its key slots as business-key columns and selects only the
columns this view's objects actually want. The CTEs are then joined on the planned path from the
frozen plan: a spine of tables sharing one unambiguous key, FULL OUTER JOINed so no side is
privileged, then second-step tables joined on a key they share with something already joined.

WHY FULL OUTER AND NOT INNER
----------------------------
A sideways merge must not lose a key that exists on one side only. An inner join would silently
drop those rows and the satellite would look clean while being short -- the failure mode with no
symptom. This is the same choice gen 1 made in health_dv_dbt's stitched views.

THE FAN-OUT PROBLEM, AND WHY A DEDUPE IS NOT ENOUGH ON ITS OWN
--------------------------------------------------------------
If a table has several rows per join key, the FULL OUTER JOIN multiplies rows and every satellite
fed by this view inherits the multiplication. A `qualify row_number() = 1` prevents that, but it
is only CORRECT where one row per key is the real grain; where it is not, it silently discards
rows. So the dedupe partitions by the join key PLUS the child-key legs of this view's multi-active
satellites wherever those legs are real columns of that table, and every leg that could not be
resolved is REFUSED into the register rather than dropped from the partition in silence. On top of
that, gen_hcon4_assertions.py emits a runtime fan-out count per table per view, so the thing this
dedupe assumes is MEASURED when the model runs instead of being assumed at generation time.
"""
import collections
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hcon_names as N                                             # noqa: E402
import hcon4_emit as E                                             # noqa: E402


def table_cte(name, table, slots, view, join_hubs, wanted_cols, partition_extra):
    """One table's CTE: its key slots, the columns this view wants, one row per grain."""
    lines = []
    bk_names = []
    for hub in sorted(join_hubs):
        slot = slots.get((table, hub))
        if not slot:
            continue
        for i in range(len(slot["exprs"])):
            col, sql = E.render_slot(table, hub, slot, i)
            lines.append("%s as %s" % (sql, col))
            bk_names.append((hub, col, len(slot["exprs"])))
    cols = [E.q(c) for c in sorted(wanted_cols)]
    sel = ",\n        ".join(lines + cols) if (lines or cols) else "1 as placeholder"

    # the join key column for this table in this view, if it has exactly one slot for its join hub
    part = [c for _h, c, nslots in bk_names if nslots == 1]
    part = part + [E.q(c) for c in sorted(partition_extra)]
    qual = ""
    if part:
        qual = ("\n    qualify row_number() over (partition by %s order by %s) = 1"
                % (", ".join(part), ", ".join(part)))
    return ("%s as (\n    select\n        %s\n    from {{ ref(%s) }}%s\n)"
            % (name, sel, N.sql_literal(E.staging_label(table)), qual)), bk_names


def main():
    plan = E.load_plan()
    slots = E.slots_of(plan)
    pay = E.payload_index()
    written = 0
    totals = collections.Counter()
    # What each view ACTUALLY emits, declared for the layers downstream. See the note on
    # write_manifest in hcon4_emit: grepping the emitted SQL for an alias is a proxy, and it
    # reported a false zero for every payload column.
    manifest = {}

    for v in plan["stitched_views"]:
        jp = v["join_plan"]
        spine_hub = jp["spine_hub"]
        refused_tables = {r["table"] for r in jp["refused_tables"]}
        joined_tables = [t for t in jp["spine_tables"]] + \
                        [s["table"] for s in jp["second_step_joins"]]
        if not joined_tables:
            E.refuse("stitched_view_has_no_joinable_table", "view%d" % v["ordinal"],
                     "every table of this view was refused from the join; no central view can be "
                     "built for it", "mapper", satellites=v["satellites"])
            continue

        # ---- which columns does this view actually need, per table? --------------------
        objects = list(v["satellites"])
        wanted = collections.defaultdict(set)
        withheld = collections.defaultdict(set)
        attr_sources = collections.defaultdict(list)     # attribute -> [(table, column, run)]
        for sat in objects:
            for e in pay.get(sat, []):
                if e["table"] in refused_tables:
                    withheld[sat].add((e["table"], e["column"], e["attr"]))
                    continue
                if e["table"] not in joined_tables:
                    continue
                wanted[e["table"]].add(e["column"])
                attr_sources[e["attr"]].append((e["table"], e["column"], e["run"]))
        for sat, items in sorted(withheld.items()):
            E.refuse("payload_withheld_table_not_joinable", sat,
                     "%d attribute(s) of this satellite sit on table(s) refused from its own "
                     "view's join, so they are WITHHELD rather than reached by a cross join"
                     % len(items), "mapper", view=v["ordinal"],
                     attributes=sorted({a for _t, _c, a in items})[:12],
                     tables=sorted({t for t, _c, _a in items}))

        # ---- grain: child-key legs of this view's multi-active satellites ---------------
        partition_extra = collections.defaultdict(set)
        ma_sats = []
        for sat in objects:
            hist, is_ma, decl = E.model_grain(sat)
            if not is_ma:
                continue
            ma_sats.append(sat)
            resolved, missing = E.resolve_childkey_columns(sat, set(joined_tables))
            for r in resolved:
                partition_extra[r["table"]].add(r["column"])
            if missing:
                E.refuse("child_key_leg_unresolved", sat,
                         "data_7.js declares this satellite %s with child key %r, and %d leg(s) "
                         "resolve to no column on any table of its own view. The legs are NOT "
                         "rendered: a wrong child key is unrecoverable after load. The view "
                         "dedupes on the legs it could resolve, which is RECORDED here as a "
                         "narrower grain than the model declares."
                         % (hist, decl, len(missing)), "mapper",
                         view=v["ordinal"], unresolved_legs=missing,
                         resolved_legs=[r["leg"] for r in resolved])

        # ---- build the CTEs -------------------------------------------------------------
        ctes, bk_index, aliases = [], {}, {}
        for i, t in enumerate(joined_tables):
            alias = "t%d" % i
            aliases[t] = alias
            hubs_here = {h for (tt, h) in slots if tt == t} & set(v["hubs_on_view"])
            cte, bks = table_cte(alias, t, slots, v, hubs_here, wanted.get(t, set()),
                                 partition_extra.get(t, set()))
            ctes.append(cte)
            bk_index[t] = bks

        # ---- the join path --------------------------------------------------------------
        def join_col(table, hub):
            for h, col, nslots in bk_index.get(table, []):
                if h == hub and nslots == 1:
                    return col
            return None

        first = joined_tables[0]
        join_sql = [aliases[first]]
        placed = [first]
        join_log = []
        for t in joined_tables[1:]:
            hub = spine_hub if t in jp["spine_tables"] else next(
                (s["on_hub"] for s in jp["second_step_joins"] if s["table"] == t), None)
            mine = join_col(t, hub)
            # THE JOIN KEY IS THE RUNNING COALESCE OVER EVERY TABLE ALREADY JOINED, not the first
            # table's column.
            #
            # In a chain of FULL OUTER joins, a row contributed only by t1 has t0's key column
            # NULL. If t2 then joins ON t2.key = t0.key, it cannot match that row even when
            # t2.key equals t1.key -- so t2's row comes out as a SEPARATE row instead of merging
            # into it. The view then holds several partial rows per business key where it should
            # hold one, every satellite fed by it inherits the split, and the dedupe downstream
            # picks one of them arbitrarily. Nothing raises: the model builds, the satellite
            # loads, and the payload is silently scattered.
            #
            # Coalescing over all placed tables that carry this hub's key makes every FULL OUTER
            # join see the key wherever it arrived from.
            partners = [p for p in placed if join_col(p, hub)]
            if mine is None or not partners:
                E.refuse("join_column_not_renderable", "%s@view%d" % (t, v["ordinal"]),
                         "the plan joins this table on %s but no single key slot renders a join "
                         "column for it, or no table already in the view carries that key. The "
                         "table is left OUT of the view rather than joined on a guess."
                         % hub, "mapper")
                continue
            refs = ["%s.%s" % (aliases[p], join_col(p, hub)) for p in partners]
            lhs = refs[0] if len(refs) == 1 else "coalesce(%s)" % ", ".join(refs)
            join_sql.append("full outer join %s on %s.%s = %s"
                            % (aliases[t], aliases[t], mine, lhs))
            join_log.append({"table": t, "alias": aliases[t], "on_hub": hub,
                             "my_column": mine,
                             "coalesced_over": [aliases[x] for x in partners],
                             "partners_carrying_this_key": len(partners)})
            placed.append(t)

        # ---- the select: keys coalesced, attributes merged in run precedence ------------
        out = []
        emitted_keys, emitted_attrs, emitted_ambiguous = {}, {}, []
        for hub in sorted(v["hubs_on_view"]):
            cols = [(aliases[t], c) for t in placed
                    for h, c, ns in bk_index.get(t, []) if h == hub and ns == 1]
            if not cols:
                continue
            name = "%s_BK" % hub
            if len(cols) == 1:
                out.append("%s.%s as %s" % (cols[0][0], cols[0][1], name))
            else:
                out.append("coalesce(%s) as %s"
                           % (", ".join("%s.%s" % c for c in cols), name))
            emitted_keys[hub] = name
            # every ambiguous slot is still emitted, named, so a modeller can rule on it
        for t in placed:
            for h, c, ns in bk_index.get(t, []):
                if ns > 1:
                    alias = "%s__%s" % (aliases[t].upper(), c)
                    out.append("%s.%s as %s" % (aliases[t], c, alias))
                    emitted_ambiguous.append({"hub": h, "table": t, "column": alias,
                                              "slots_on_this_table": ns})

        for attr in sorted(attr_sources):
            srcs = [s for s in attr_sources[attr] if s[0] in placed]
            if not srcs:
                continue
            srcs.sort(key=lambda s: (E.RUN_RANK.get(s[2], 9), s[0], s[1]))
            try:
                col = N.column(attr)
            except AssertionError as exc:
                E.refuse("attribute_name_is_prose", attr, str(exc), "mapper", view=v["ordinal"])
                continue
            refs = ["%s.%s" % (aliases[t], E.q(c)) for t, c, _r in srcs]
            if len(refs) == 1:
                out.append("%s as %s" % (refs[0], col))
            else:
                out.append("coalesce(%s) as %s" % (", ".join(refs), col))
            emitted_attrs[attr] = col
            totals["merged_attributes"] += 1 if len(refs) > 1 else 0

        if not out:
            E.refuse("stitched_view_selects_nothing", "view%d" % v["ordinal"],
                     "no key and no attribute could be rendered for this view", "mapper")
            continue

        sql = E.header("gen_hcon4_stitched.py", [
            "CENTRAL VIEW %d -- the layer the governing rule is about." % v["ordinal"],
            "spine hub    : %s   (%d of %d table(s) join on it unambiguously)"
            % (spine_hub, len(jp["spine_tables"]), len(v["tables"])),
            "tables joined: %d of %d in the group; %d refused from the join"
            % (len(placed), len(v["tables"]), len(refused_tables)),
            "rule 1/3     : %s" % ("OVER the limit of 10 by rule 3, because a single object in "
                                   "this group needs more" if v["over_limit"]
                                   else "within the limit of 10"),
            "rule 2       : feeds %d satellite(s) WHOLE. No satellite in this build is split"
            % len(v["satellites"]),
            "               across views; the plan asserts that by re-counting homes.",
            "rules 5/6    : %d hub key(s) resolve on this view, so its hubs and its %d link(s)"
            % (len(v["hubs_on_view"]), len(v["links"])),
            "               are derived FROM here and not from anywhere else.",
            "satellites   : %s" % (", ".join(sorted(v["satellites"])[:6]) or "(none)"),
            "links        : %s" % (", ".join(sorted(v["links"])[:6]) or "(none)"),
            "join type    : FULL OUTER. An inner join would silently drop a key present on one",
            "               side only, leaving a satellite that looks clean and is short.",
            "merge order  : %s" % E.RUN_RANK_NOTE,
            "grain        : one row per join key%s"
            % (" plus the resolved child-key legs of %d multi-active satellite(s)" % len(ma_sats)
               if ma_sats else ""),
            "NOT hashed   : this view computes no hash. Hashing happens exactly once, downstream,",
            "               in %s." % E.stage_label(v),
        ]) + "{{ config(materialized='view') }}\n\nwith %s\n\nselect\n    %s\nfrom %s\n" % (
            ",\n\n".join(ctes), ",\n    ".join(out), "\n".join(join_sql))

        E.write(os.path.join("stitched", E.view_label(v) + ".sql"), sql)
        manifest[str(v["ordinal"])] = {
            "model": E.view_label(v),
            "spine_hub": spine_hub,
            "tables_joined": placed,
            "tables_refused": sorted(refused_tables),
            "key_columns": emitted_keys,
            "attribute_columns": emitted_attrs,
            "ambiguous_key_columns": emitted_ambiguous,
            "satellites": sorted(v["satellites"]),
            "links": sorted(v["links"]),
            "multi_active_satellites": sorted(ma_sats),
            "join_conditions": join_log,
            "join_conditions_note": "Each FULL OUTER join keys on the COALESCE over every "
                                    "already-joined table carrying that hubs key, never on the "
                                    "first tables column alone. Keying on the first table lets a "
                                    "row contributed only by a later table fail to match -- its "
                                    "key arrives in a column that is NULL on that row -- so the "
                                    "view holds several partial rows per business key and every "
                                    "satellite fed by it inherits the split, silently.",
            "dedupe_partition_extra": {t: sorted(c) for t, c in sorted(partition_extra.items())},
        }
        written += 1
        totals["tables_joined"] += len(placed)

    E.write_manifest("view_columns.json", manifest)
    print("  stitched (central): %d view(s), %d table join(s), %d attribute(s) merged across "
          "tables" % (written, totals["tables_joined"], totals["merged_attributes"]))
    return written


if __name__ == "__main__":
    main()
