# -*- coding: utf-8 -*-
"""Layer 5: the augmented track, kept SEPARATE from the ratified vault.

The augmentation track proposes attributes and satellites the canonical model does not carry. They
are emitted so the work is visible and reviewable, into their own tree, and they are never mixed
into a ratified satellite -- a proposal loaded beside a ratified attribute becomes indistinguishable
from it the moment anyone queries the satellite.

RATIFIED requires BOTH conditions, not either
---------------------------------------------
An attribute is ratified only where the TARGET track names it AND data_7.js already carries it on
that satellite. Testing one condition alone promotes proposals: the target track names plenty of
attributes the model does not have, and the model has plenty the target track does not name.
"""
import collections
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hcon_names as N                                             # noqa: E402
import hcon4_emit as E                                             # noqa: E402
import hcon4_plan as P                                             # noqa: E402


def model_attrs(code):
    s = next((x for x in P.MODEL["sats"] if x["code"] == code.upper()), None) or \
        next((x for x in P.MODEL.get("refs", []) if x["code"] == code.upper()), None)
    if not s:
        return set()
    a = s.get("attrs") or []
    return {P.n(x).strip().lower() for x in a} if isinstance(a, list) else set()


def main():
    plan = E.load_plan()
    stages = E.read_manifest("stage_columns.json")
    views = E.read_manifest("view_columns.json")
    pay = E.payload_index()
    placed = {s: v for v in plan["stitched_views"] for s in v["satellites"]}
    counts = collections.Counter()

    # Everything the map names that is NOT a ratified satellite-attribute pair on a placed
    # satellite. Grouped by satellite so a reviewer sees one proposal per satellite.
    proposals = collections.defaultdict(list)
    for sat, entries in sorted(pay.items()):
        known = model_attrs(sat)
        for e in entries:
            ratified = (e["track"] == "target" and e["attr"].strip().lower() in known)
            if ratified and sat in placed:
                continue
            proposals[sat].append(e)

    for sat, entries in sorted(proposals.items()):
        v = placed.get(sat)
        if v is None:
            E.refuse("proposed_satellite_has_no_central_view", sat,
                     "the map proposes %d attribute(s) for this satellite but no central view "
                     "feeds it, so there is nothing to propose them FROM. The proposal is "
                     "registered, not emitted against a view that does not exist."
                     % len(entries), "modeller",
                     attributes=sorted({e["attr"] for e in entries})[:12])
            counts["proposals_with_no_view"] += 1
            continue
        key = str(v["ordinal"])
        if key not in stages:
            continue
        sm, vm = stages[key], views[key]
        stage = sm["model"]
        # Columns come from the stitched views DECLARATION, not from grepping the stage SQL:
        # payload reaches the stage model through src.* and is aliased nowhere in it.
        cols, unrendered = [], []
        for e in entries:
            col = vm["attribute_columns"].get(e["attr"])
            if col is None:
                try:
                    N.column(e["attr"])
                except AssertionError:
                    unrendered.append(e["attr"])
                continue
            if col not in cols:
                cols.append(col)
        if unrendered:
            E.refuse("proposed_attribute_name_is_prose", sat,
                     "%d proposed attribute name(s) are descriptive phrases, not attribute "
                     "names, and are NOT rendered into a column: a phrase in an identifier "
                     "position becomes a column that cannot exist." % len(unrendered),
                     "mapper", attributes=unrendered[:8])
        if not cols:
            counts["proposals_nothing_renderable"] += 1
            continue

        hubs, basis = _required(sat)
        hks = [sm["hash_keys"][h] for h in hubs if h in sm["hash_keys"]]
        if not hks:
            E.refuse("proposed_satellite_anchor_not_staged", sat,
                     "no hash key for %s is staged on this satellites own view, so the proposal "
                     "cannot be keyed" % ", ".join(hubs), "mapper", view=v["ordinal"])
            continue
        hd = N.budget("AUG_" + sat + "_HASHDIFF")
        parts = " || '|' || ".join("coalesce(cast(%s as varchar), '')" % c for c in cols)
        guard = " or ".join("%s is not null" % c for c in cols)
        body = E.header("gen_hcon4_augmented.py", [
            "PROPOSED satellite payload for %s -- NOT part of the ratified vault." % sat,
            "anchor       : %s   (%s)" % (", ".join(hubs), basis),
            "reads        : %s   (the same central view the ratified satellite uses)" % stage,
            "attributes   : %d proposed" % len(cols),
            "status       : PROPOSED. Emitted in its own tree so the mapping work is visible and",
            "               reviewable, and kept OUT of the ratified satellite so a proposal can",
            "               never be mistaken for a ratified attribute once loaded.",
            "ratified test: an attribute counts as ratified only where the TARGET track names it",
            "               AND data_7.js already carries it on this satellite. Testing either",
            "               condition alone promotes proposals into the vault.",
        ]) + ("{{ config(materialized='view') }}\n\nwith src as (\n    select * from {{ ref(%s) }}\n)"
              "\n\nselect\n    %s,\n    case when %s\n         then md5(upper(%s))\n    end as %s,\n"
              "    %s,\n    %s as RECORD_SOURCE,\n    %s\nfrom src\nwhere %s is not null\n"
              % (N.sql_literal(stage), hks[0], guard, parts, hd, ",\n    ".join(cols),
                 N.sql_literal(E.view_label(v)), "current_timestamp() as LOAD_DATETIME", hks[0]))
        E.write(os.path.join("augmented", N.budget("aug_" + sat.lower()) + ".sql"), body)
        counts["augmented"] += 1

    print("  augmented         : %d model(s)  (%d proposal(s) with no central view, %d with "
          "nothing renderable)" % (counts["augmented"], counts["proposals_with_no_view"],
                                   counts["proposals_nothing_renderable"]))
    return counts


def _required(sat):
    blocks = E.map_blocks()
    by_sat = collections.defaultdict(list)
    for b in blocks:
        if b["sat"]:
            by_sat[b["sat"]].append(b)
    return P.required_hubs(sat, blocks, by_sat)


if __name__ == "__main__":
    main()
