# -*- coding: utf-8 -*-
"""gen_mt_staging.py -- LAYER-1 CASTS for the views that carry map rows.

One cast per MAPPED view. The views that appear only on a walk are gen_mt_hopviews.py's, which
imports cast_body() from here so the two layers cannot drift apart.

Every source column is DOUBLE-QUOTED (directive D-QUOTE): seven mapped column names begin with a
digit (1ST_REMINDER_DATE, 2ND_REMINDER_DATE, 3RD_REMINDER_DATE, 64_VB_STATUS ...) and an unquoted
reference to one is a Snowflake syntax error. dbt is out of scope in this workspace, so no static
gate here would catch it -- the quoting is asserted instead.
"""
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

SOURCE_NAME = "maximus_travel_raw"
LINEAGE = ["FOREIGN_KEY", "KEY_HASH", "PARENT_KEY_HASH", "ROOT_HASH", "RECORD_HASH",
           "PARENT_RECORD_HASH", "PARENT_TABLE_NAME"]

# Load/CDC timestamp columns on this source family. These flattened shred / EAV views carry no
# INC_JOB_UPDATED_AT (the other LOBs' watermark); the per-row load stamp here is INC_JOB_CREATED_AT.
# It is a genuine timestamp, so cast it to TIMESTAMP_NTZ rather than trimmed VARCHAR -- a trimmed
# string cannot be range-compared by any downstream incremental window. (The vault's own
# LOAD_DATETIME is still synthesized as CURRENT_TIMESTAMP() in the stage layer; this only makes the
# real source stamp usable as a watermark without re-casting it everywhere it is consumed.)
LOAD_TS = ["INC_JOB_CREATED_AT"]


def load_spec():
    with open(S.SPEC_PATH, encoding="utf-8") as fh:
        return json.load(fh)


def cast_body(view, info, why):
    """The layer-1 cast for one source view.

    Typing: these are flattened JSON shreds and pivoted EAV views, and no source type list was
    supplied, so values are cast to trimmed VARCHAR. An absent EAV label on this feed is the EMPTY
    STRING rather than NULL, which is why every value is nullif(trim(...),'') here -- and why
    every key downstream is guarded AGAIN in mt_keyrules.render_key().
    """
    cols = info["columns"]
    lines = []
    for c in cols:
        if c.upper() in LINEAGE:
            lines.append('    %s as %s,' % (N.quote_source_column(c), N.cast_alias(c)))
    for c in cols:
        if c.upper() in LINEAGE:
            continue
        if c.upper() in LOAD_TS:
            # Load timestamp -> TIMESTAMP_NTZ so it can serve as an incremental watermark.
            lines.append("    try_to_timestamp_ntz(trim(to_varchar(%s))) as %s,"
                         % (N.quote_source_column(c), N.cast_alias(c)))
        else:
            lines.append("    nullif(trim(to_varchar(%s)), '') as %s,"
                         % (N.quote_source_column(c), N.cast_alias(c)))
    if not lines:
        raise SystemExit("cast for %s would select nothing" % view)
    lines[-1] = lines[-1].rstrip(",")

    present = [c for c in LINEAGE if c in {x.upper() for x in cols}]
    header = [
        "{{ config(materialized='view') }}",
        "",
        "-- Layer-1 cast for Maximus Travel source view",
        "--   %s" % view,
        "--",
        "-- %s" % why,
        "--",
        "-- Typing: flattened JSON shreds and pivoted EAV views with no source type list, so every",
        "-- value is cast to a trimmed VARCHAR. An absent EAV label on this feed is the EMPTY",
        "-- STRING, not NULL, which is why each value is nullif(trim(...),'') here and why every",
        "-- key is guarded again in mt_keyrules.render_key().",
        "--",
        "-- Every source identifier is DOUBLE-QUOTED (directive D-QUOTE): seven column names in",
        "-- this feed begin with a digit and do not compile unquoted. Their aliases carry a col_",
        "-- prefix for the same reason -- an alias may not begin with a digit either.",
        "--",
        "-- Shred lineage carried through deliberately (%s): it appears in no row of the map and"
        % (", ".join(present) or "none on this view"),
        "-- the whole sub-document key layer is built on it.",
        "",
        "with source as (",
        "",
        "    select",
    ]
    return "\n".join(header + lines + [
        "    from {{ source('%s', '%s') }}" % (SOURCE_NAME, view),
        "",
        ")",
        "",
        "select * from source",
    ])


def sources_yml(views):
    out = [
        "version: 2",
        "",
        "sources:",
        "  - name: %s" % SOURCE_NAME,
        '    database: "{{ var(\'mt_raw_database\') }}"',
        '    schema: "{{ var(\'mt_raw_schema\') }}"',
        "    description: >",
        "      Maximus Travel flattened source views (UWR + CLM shreds of one nested JSON).",
        "      FOREIGN_KEY carries the document handle; PARENT_KEY_HASH -> parent.KEY_HASH is the",
        "      shred spine every PARENT_KEY_HASH walk in this build climbs. Both are declared here",
        "      because the key layer is built on them and neither appears in any row of the map.",
        "    tables:",
    ]
    for v in views:
        out.append("      - name: %s" % v)
    return "\n".join(out)


def emit(spec, views, why, layer_label):
    N.ensure_dir(N.LAYER_DIRS["cast"])
    written = []
    for v in views:
        info = spec["views"][v]
        path = N.model_path("cast", N.model_name("cast", v))
        N.write_model(path, cast_body(v, info, why))
        written.append(os.path.basename(path))
    print("%s: %d cast(s)" % (layer_label, len(written)))
    return written


def main():
    spec = load_spec()
    # FIRST writer of the cast directory in the run order; gen_mt_hopviews writes the
    # walk-only half into the same directory afterwards and must NOT wipe (BUILD_RULES 6.3).
    stale = N.wipe_layer("cast")
    print("gen_mt_staging: wiped %d stale file(s) from the cast layer" % stale)
    mapped = spec["map_views"]
    written = emit(spec, mapped, "This view CARRIES MAP ROWS; it is a start view for the key and "
                                 "payload layers.", "gen_mt_staging (layer-1 casts, mapped views)")
    # the source list is the WHOLE cast set, not just this layer's -- a source a walk-only cast
    # reads must be declared too, and declaring it twice is a dbt error.
    path = os.path.join(N.LAYER_DIRS["cast"], "_mt_sources.yml")
    N.write_model(path, sources_yml(spec["cast_views"]))
    print("  sources declared      : %d table(s) in %s"
          % (len(spec["cast_views"]), os.path.basename(path)))
    print("  views carrying map rows: %d   walk-only (gen_mt_hopviews): %d   total: %d"
          % (len(mapped), len(spec["walk_only_views"]), len(spec["cast_views"])))
    print("  BUILD_RULES 6.1: a view gets a cast because it is ON A WALK, never because it is in")
    print("  the map. %d of the %d casts this build owes exist for views nothing maps."
          % (len(spec["walk_only_views"]), len(spec["cast_views"])))
    return written


if __name__ == "__main__":
    main()
