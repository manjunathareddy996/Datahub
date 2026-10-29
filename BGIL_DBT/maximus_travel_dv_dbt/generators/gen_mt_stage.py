# -*- coding: utf-8 -*-
"""gen_mt_stage.py -- ONE WIDE stage() per view.

Carries every key the view resolves, and a separately-named hashdiff plus a null-padded payload
for every 1:1 satellite it feeds. Fan-in families (one row per instance) are the unpivot layer's,
not this one's.

Every business key below is the GUARDED rendering from mt_keyrules.render_key(): a CASE over
'coalesce(<each guarded operand>) is not null', so a row whose every operand is blank yields NULL
and the hub feed refuses it. There is deliberately NO predicate comparing a key to a constant from
KEY_DEGENERATE_VALUES.csv -- under Snowflake semantics every key expression in this map is NULL on
an all-blank row, so such a predicate could never fire while looking exactly like a working guard.

include_source_columns is FALSE and every column is listed: a stage that passes its source's
columns through hides the real feeder columns from anything reading the YAML, which is how a set
of child keys went missing on an earlier build (BUILD_RULES 6.2).
"""
import collections
import json
import os
import sys

import mt_names as N
import mt_keyrules as K
import build_mt_spec as S

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


def stage_body(view, spec, slots, sat_feeders, sats):
    src = N.model_name("resolver" if spec["views"][view]["walks"] else "cast", view)
    hashed, derived, notes = [], [], []

    for slot in slots:
        hashed.append("  %s: '%s'" % (slot["hkey"], slot["nk"]))
        derived.append("  %s: %s" % (slot["bk"], N.yaml_scalar(slot["sql"])))
        derived.append("  %s: %s" % (slot["nk"], N.yaml_scalar(slot["nk_sql"])))
        notes.append("--   %-34s %s%s%s"
                     % (slot["hkey"], slot["hub"],
                        "" if slot["instance"] is None else " / %s" % slot["instance"],
                        "  LINK" if slot.get("is_link")
                        else "  (%d row(s) in the map)" % slot.get("rows", 0)))
        # a link's degenerate leg -- the role code -- is part of the link hash and is carried
        # into the link table so the grain is party x role rather than party alone (BD5).
        for leg in (slot.get("legs") or []):
            if leg.get("role") == "degenerate":
                derived.append("  %s: %s" % (leg["column"], N.yaml_scalar(leg["sql"])))

    emitted = {}
    for f, sat in sat_feeders:
        b = f["branches"][0]
        cols = b["stage_columns"]
        hd = []
        for c in sorted(sat["cdk"]):
            stage_col = cols.get(c, c)
            if c not in b["cdk"]:
                raise SystemExit("STAGE REFUSED: %s on %s declares child-key leg %s and the "
                                 "feeder does not supply it; a null leg merges instances "
                                 "(BUILD_RULES 5.3)." % (sat["satellite"], N.short_view(view), c))
            emitted.setdefault(stage_col, b["cdk"][c])
            hd.append(stage_col)
        for c in sat["payload"]:
            stage_col = cols.get(c, c)
            emitted.setdefault(stage_col, S.payload_sql(b["attributes"].get(c)))
            hd.append(stage_col)
        hashed.append("  %s:" % sat["hashdiff_stage"])
        hashed.append("    is_hashdiff: true")
        hashed.append("    columns:")
        for c in sorted(hd):
            hashed.append("      - '%s'" % c)
        live = sum(1 for c in sat["payload"] if b["attributes"].get(c))
        notes.append("--   %-34s %s payload %d of %d live here"
                     % (sat["hashdiff_stage"], sat["satellite"], live, len(sat["payload"])))

    for col in sorted(emitted):
        derived.append("  %s: %s" % (col, N.yaml_scalar(emitted[col])))
    derived.append("  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'")
    derived.append("  RECORD_SOURCE: '!%s'" % view)

    for line in derived:
        K.assert_no_prose(line, "stage %s" % view)

    head = [
        "{{ config(materialized='view') }}",
        "",
        "-- WIDE stage() for Maximus Travel view",
        "--   %s" % view,
        "-- Covers this view's %d key slot(s) and its %d 1:1 satellite target(s) in one pass,"
        % (len(slots), len(sat_feeders)),
        "-- with a separately-named hashdiff per satellite so each is scoped to its own payload.",
        "-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,",
        "-- which is the only place one name can serve one satellite (BD7).",
        "--",
        "-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one",
        "-- row per instance cannot be expressed as columns of one row here.",
        "--",
        "-- Every BK is the guarded rendering. When every non-literal operand is blank the key is",
        "-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per",
        "-- feeder -- so a zero is a measured zero (directive D-REJECT).",
        "--",
    ] + notes
    return "\n".join(head + [
        "",
        "{%- set yaml_metadata -%}",
        "source_model: '%s'" % src,
        "hashed_columns:",
    ] + hashed + ["derived_columns:"] + derived + [
        "{%- endset -%}",
        "",
        "{% set metadata_dict = fromyaml(yaml_metadata) %}",
        "",
        "{{ automate_dv.stage(include_source_columns=false,",
        "                      source_model=metadata_dict['source_model'],",
        "                      hashed_columns=metadata_dict['hashed_columns'],",
        "                      derived_columns=metadata_dict['derived_columns']) }}",
    ])


def main():
    with open(S.SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    sats = {(s["satellite"], s["track"]): s for s in spec["satellites"]}
    by_view_slots = collections.defaultdict(list)
    for slot in spec["key_slots"] + spec["link_slots"]:
        by_view_slots[slot["view"]].append(slot)
    by_view_feeders = collections.defaultdict(list)
    for f in spec["feeders"]:
        sat = sats.get((f["satellite"], f["track"]))
        if sat is None or sat["track"] != "target" or f["mode"] != "wide":
            continue
        by_view_feeders[f["view"]].append((f, sat))

    # Deliberately NOT wiped here: gen_mt_unpivot is the first writer of this directory
    # and has already emptied it. Wiping again would delete the unpivot stages.
    N.ensure_dir(N.LAYER_DIRS["stage"])
    counts = collections.Counter()
    for view in spec["map_views"]:
        slots = sorted(by_view_slots.get(view, []), key=lambda s: s["hkey"])
        feeders = sorted(by_view_feeders.get(view, []), key=lambda x: x[1]["satellite"])
        if not slots and not feeders:
            counts["views_with_nothing_to_stage"] += 1
            continue
        name = N.model_name("stage", view)
        N.write_model(N.model_path("stage", name), stage_body(view, spec, slots, feeders, sats))
        counts["stages"] += 1
        counts["key_slots"] += sum(1 for x in slots if not x.get("is_link"))
        counts["link_slots"] += sum(1 for x in slots if x.get("is_link"))
        counts["sat_feeders"] += len(feeders)

    print("gen_mt_stage: %d wide stage(s)" % counts["stages"])
    print("  hub key slots carried        : %d" % counts["key_slots"])
    print("  link key slots carried       : %d" % counts["link_slots"])
    print("  1:1 satellite feeders carried: %d" % counts["sat_feeders"])
    print("  views with map rows but nothing to stage: %d"
          % counts["views_with_nothing_to_stage"])
    print("  stage column collisions resolved by a satellite suffix: %d"
          % len(spec["census"]["stage_column_collisions"]))
    print("      (two satellites on one view wanting one payload name from different sources;")
    print("       without the rename the second write replaces the first and the other satellite")
    print("       declares an attribute it no longer feeds -- BUILD_RULES 8.3)")


if __name__ == "__main__":
    main()
