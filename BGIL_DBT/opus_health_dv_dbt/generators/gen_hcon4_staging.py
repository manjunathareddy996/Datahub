# -*- coding: utf-8 -*-
"""Layer 1: staging. One model per source table that any stitched view joins.

A staging model does NOTHING but name and type its columns. No business logic, no keys, no
hashes -- a key computed here would be computed again in the stage layer and the two spellings
would drift, which is the defect the single-hash-site rule exists to prevent.

Every column is cast to varchar. The pinned bundle carries no datatype catalogue, and a type
inferred from a column name is a fabricated datum (v3 builder decision BD3, carried).
"""
import collections
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hcon4_emit as E                                             # noqa: E402


def main():
    plan = E.load_plan()
    # A table is staged only where some view ACTUALLY JOINS it -- that is, where it is on a
    # view's spine or reached by a planned second-step join. Staging every table the plan
    # GROUPED emitted a model for each table that was then refused from its join, and nothing
    # read those models: 3 dead staging models, caught by the orphan check. Dead code looks
    # exactly like work, so the fix belongs here rather than in a note.
    consumers = collections.defaultdict(list)
    for v in plan["stitched_views"]:
        jp = v["join_plan"]
        for t in list(jp["spine_tables"]) + [s["table"] for s in jp["second_step_joins"]]:
            consumers[t].append(v["ordinal"])
    tables = sorted(consumers)

    grouped = {t for v in plan["stitched_views"] for t in v["tables"]}
    not_staged = sorted(grouped - set(tables))
    for t in not_staged:
        E.refuse("source_table_grouped_but_never_joined", t,
                 "every view that needed this table refused it from its join, so no model reads "
                 "it and no staging model is emitted for it. Emitting one would be dead code "
                 "that reads as work. The reason it was refused is registered against the view.",
                 "mapper",
                 views_that_wanted_it=[v["ordinal"] for v in plan["stitched_views"]
                                       if t in v["tables"]])

    written = 0
    for t in tables:
        cols = E.cols_of(t)
        if not cols:
            E.refuse("source_table_names_no_column", t,
                     "the map names this table but no column on it, so there is nothing to stage",
                     "mapper")
            continue
        run = E.run_of(t)
        sel = ",\n    ".join("cast(%s as varchar) as %s" % (E.q(c), E.q(c)) for c in cols)
        sql = E.header("gen_hcon4_staging.py", [
            "source table : %s" % t,
            "source run   : %s   (one dbt source per run; no table in this map spans runs)" % run,
            "columns      : %d, every one named by the map" % len(cols),
            "consumed by  : stitched view(s) %s -- this model is staged BECAUSE a view joins it;"
            % ", ".join(str(x) for x in consumers[t]),
            "               a table grouped but refused from every join is NOT staged, because",
            "               an unread staging model is dead code that reads as work.",
            "datatypes    : every column cast to varchar. The pinned bundle carries NO datatype",
            "               catalogue, and a type inferred from a column name is a fabricated",
            "               datum (builder decision BD3, carried from v3).",
            "no keys here : this model computes no business key and no hash. Hashing happens",
            "               exactly once, in the stage layer, after the stitch has produced one",
            "               clean row per key.",
        ]) + "{{ config(materialized='view') }}\n\nselect\n    %s\nfrom {{ source(%s, %s) }}\n" % (
            sel, N_lit(run), N_lit(t))
        E.write(os.path.join("staging", E.staging_label(t) + ".sql"), sql)
        written += 1

    print("  staging           : %d model(s) for %d source table(s)" % (written, len(tables)))
    return written


def N_lit(s):
    import hcon_names as N
    return N.sql_literal(s)


if __name__ == "__main__":
    main()
