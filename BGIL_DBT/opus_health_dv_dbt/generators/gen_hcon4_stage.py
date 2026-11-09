# -*- coding: utf-8 -*-
"""Layer 3: stage. THE ONE PLACE A HASH IS COMPUTED. One model per stitched view.

Why one site: a business key hashed in two models is a business key with two spellings, and two
spellings of one key are two keys. Everything downstream -- hub feeds, hubs, links, satellites --
reads a hash from here and computes none of its own, so there is exactly one place to look when a
key is wrong and exactly one place for it to drift.

What it emits per view:
  * one hash key per hub whose business key the view declared
  * one hashdiff per satellite the view feeds, over that satellite's payload as the view rendered
    it, GUARDED against an all-null input
  * the view's own columns, carried through unchanged

It reads the stitched layer's MANIFEST, not the stitched layer's SQL. Asking the previous layer
what it emitted is a contract; grepping its text for "as <COL>" is a proxy, and that proxy once
reported every payload column as absent -- because this very model passes payload through as
`src.*` and aliases none of it -- which emitted 0 satellites and looked like a finding about the
map rather than a bug in the check.

THE HASHDIFF GUARD, AND WHAT HAPPENS WITHOUT IT
-----------------------------------------------
An unguarded hashdiff over an all-null payload hashes every such row to ONE value. The satellite
then collapses to a single row and the collapse looks exactly like correct change detection --
no error, no empty table, just a satellite that is quietly wrong. So a hashdiff is null when
every one of its inputs is null, and the satellite drops the row instead of loading a fiction.
"""
import collections
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hcon_names as N                                             # noqa: E402
import hcon4_emit as E                                             # noqa: E402


def main():
    plan = E.load_plan()
    views = E.read_manifest("view_columns.json")
    pay = E.payload_index()
    written = 0
    totals = collections.Counter()
    uses_normalise = 0
    manifest = {}

    for v in plan["stitched_views"]:
        key = str(v["ordinal"])
        if key not in views:
            continue                        # the view was refused; its reason is in the register
        vm = views[key]
        view_model = vm["model"]
        view_sql = open(os.path.join(E.MODELS, "stitched", view_model + ".sql"),
                        encoding="utf-8").read()
        if "normalise(" in view_sql:
            uses_normalise += 1

        lines, hash_keys = [], {}
        for hub, bk in sorted(vm["key_columns"].items()):
            hk = N.hash_key(hub)
            lines.append("%s as %s" % (N.hash_expr(hub, bk), hk))
            hash_keys[hub] = hk
            totals["hash_keys"] += 1

        hd, hashdiffs = [], {}
        for sat in sorted(vm["satellites"]):
            cols = []
            for e in pay.get(sat, []):
                col = vm["attribute_columns"].get(e["attr"])
                if col and col not in cols:
                    cols.append(col)
            if not cols:
                E.refuse("satellite_has_no_renderable_payload_on_its_view", sat,
                         "its own central view rendered none of this satellite's attributes, so "
                         "there is nothing to hash and no satellite is emitted", "mapper",
                         view=v["ordinal"],
                         attributes_wanted=sorted({e["attr"] for e in pay.get(sat, [])})[:8])
                continue
            name = N.hashdiff(sat)
            parts = " || '|' || ".join("coalesce(cast(%s as varchar), '')" % c for c in cols)
            guard = " or ".join("%s is not null" % c for c in cols)
            hd.append("case when %s\n              then md5(upper(%s))\n         end as %s"
                      % (guard, parts, name))
            hashdiffs[sat] = {"column": name, "payload_columns": cols}
            totals["hashdiffs"] += 1

        if not lines and not hd:
            E.refuse("stage_would_hash_nothing", "view%d" % v["ordinal"],
                     "this view yielded no hub key and no satellite payload to hash", "mapper")
            continue

        body = ",\n    ".join(["src.*"] + lines + hd)
        sql = E.header("gen_hcon4_stage.py", [
            "THE HASH SITE for central view %d. Nothing else in this build computes a hash."
            % v["ordinal"],
            "reads        : %s" % view_model,
            "hash keys    : %d, one per hub whose business key the view declared" % len(hash_keys),
            "               form md5(upper(HUB_X| || (<bk>))), emitted EXPLICITLY -- no macro",
            "               computes a hash here, so the formula is readable in the SQL.",
            "namespace    : the HUB_X| prefix separates HUBS. Without it the same column under",
            "               two hubs collides; the sibling estate emits exactly that pair.",
            "hashdiffs    : %d, one per satellite this view feeds, each GUARDED against an"
            % len(hd),
            "               all-null input. Unguarded, every all-null row hashes to ONE value",
            "               and the satellite collapses to one row -- which looks like change",
            "               detection and raises nothing.",
            "payload      : carried through by src.*, not re-aliased. Downstream layers learn",
            "               which columns exist from this stages manifest, never by grepping",
            "               this file -- the columns are not named here to be grepped.",
            "grain        : inherited from the view; this model does not re-grain anything.",
        ] + (["normalise() : APPEARS BELOW and is UNDEFINED in this project and in both",
              "               originals. It is carried VERBATIM inside a content-hash expression",
              "               the map supplies, and is introduced into no new expression.",
              "               UNRESOLVED -- registered as open item normalise-udf."]
             if "normalise(" in view_sql else [])
        ) + ("{{ config(materialized='view') }}\n\nwith src as (\n    select * from {{ ref(%s) }}\n)"
             "\n\nselect\n    %s\nfrom src\n" % (N.sql_literal(view_model), body))

        model = E.stage_label(v)
        E.write(os.path.join("stage", model + ".sql"), sql)
        manifest[key] = {"model": model, "view_model": view_model,
                         "hash_keys": hash_keys, "hashdiffs": hashdiffs,
                         "attribute_columns": vm["attribute_columns"],
                         "passthrough_note": "payload columns reach this model via src.* and are "
                                             "listed in attribute_columns, not aliased in the SQL"}
        written += 1

    if uses_normalise:
        E.refuse("undefined_udf_normalise", "normalise()",
                 "normalise() appears in %d stage model(s), carried verbatim from map key "
                 "expressions. It is defined nowhere in this project or in either original. The "
                 "expressions are NOT rewritten -- a tidied key is a different key -- so the UDF "
                 "must exist in the warehouse before these models run." % uses_normalise,
                 "source owner", stage_models_affected=uses_normalise)

    E.write_manifest("stage_columns.json", manifest)
    print("  stage (hash site) : %d model(s), %d hash key(s), %d hashdiff(s)"
          % (written, totals["hash_keys"], totals["hashdiffs"]))
    return written


if __name__ == "__main__":
    main()
