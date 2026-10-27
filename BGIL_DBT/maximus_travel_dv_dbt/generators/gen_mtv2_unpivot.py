# -*- coding: utf-8 -*-
"""gen_mtv2_unpivot.py -- ONE ROW PER INSTANCE, for column-as-instance families only.

A pivoted EAV view carries several INSTANCES of one satellite side by side as columns of a single
row: AADHAAR_NUMBER, DRIVING_LICENSE_NUMBER and PASSPORT_NUMBER are three instances of
SAT_PARTY_IDENTIFICATION, not three attributes of one. A wide stage cannot express that, so those
families are fanned out here -- one SELECT branch per instance, each carrying that instance's own
attributes on one row.

DECLARED BESPOKE LAYER (build_profile.bespoke_layers[1], 'EAV instance fan-out driven by a
literal leg'): 593 child-key legs in this bundle are pure LITERALS that NAME the instance. There
is no source column to unpivot FROM -- the literal IS the instance name -- and 44 of those legs
carry no `expression` field at all, so the quoted literal is synthesised from `value` by
mtv2_keyrules.render_child_leg(). That is why this layer is not a generic unpivot.

Payload is null-padded to the SATELLITE's full payload, never to this branch's own columns, so
every feeder of the satellite is union-compatible (BUILD_RULES 6).
"""
import collections
import json
import os
import sys

import mtv2_names as N
import mtv2_keyrules as K
import build_mtv2_spec as S

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


def source_model_for(view, spec):
    return N.model_name("resolver" if spec["views"][view]["walks"] else "cast", view)


def branch_sql(branch, sat, view, spec):
    """One instance."""
    lines = []
    slot = branch["slot"]
    lines.append("        %s as %s," % (slot["sql"], slot["bk"]))
    for col in sorted(sat["cdk"]):
        sql = branch["cdk"].get(col)
        if sql is None:
            # the satellite declares this leg and this branch does not supply it. Emitting NULL
            # would merge every such row onto one child key -- exactly what BUILD_RULES 5.3
            # forbids -- so the branch is refused rather than null-padded on a KEY column.
            raise SystemExit("UNPIVOT REFUSED: %s branch %r on %s does not supply child-key leg "
                             "%s. A null child-key leg merges the instances the key exists to "
                             "separate (BUILD_RULES 5.3)."
                             % (sat["satellite"], branch["slug"], N.short_view(view), col))
        lines.append("        %s as %s," % (sql, col))
    contributing = []
    for col in sat["payload"]:
        srcs = branch["attributes"].get(col)
        if srcs:
            lines.append("        %s as %s," % (S.payload_sql(srcs), col))
            contributing.extend(srcs)
        else:
            lines.append("        cast(null as varchar) as %s," % col)
    lines.append("        '%s%s' as record_source" % (N.RECORD_SOURCE_PREFIX, view))
    guard = " or ".join("%s is not null" % c for c in sorted(set(contributing))) or "1 = 1"
    return ("    select\n" + "\n".join(lines)
            + "\n    from {{ ref('%s') }}\n    where %s" % (source_model_for(view, spec), guard))


def unpivot_body(feeder, sat, spec):
    view = feeder["view"]
    branches = feeder["branches"]
    head = [
        "{{ config(materialized='view') }}",
        "",
        "-- UNPIVOT for %s from" % sat["satellite"],
        "--   %s" % view,
        "-- one row PER INSTANCE: %d branch(es)." % len(branches),
        "--",
        "-- Each branch below is ONE instance of the satellite, carrying all of its own",
        "-- attributes on a single row and discriminated by %s."
        % (", ".join(sat["cdk"]) or "(no child key -- see the satellite header)"),
        "-- The hash is taken once, downstream, by %s."
        % N.model_name("unpivot_stage", view, N.sat_slug(sat["satellite"])),
        "--",
        "-- Payload is null-padded to the SATELLITE's full payload (%d column(s)), not to this"
        % len(sat["payload"]),
        "-- feeder's columns, so every feeder of %s is union-compatible (BUILD_RULES 6)."
        % sat["satellite"],
        "--",
        "-- Instances on this view:",
    ]
    for b in branches:
        head.append("--   %-40s %d attribute(s)"
                    % (b["slug"], sum(1 for c in sat["payload"] if b["attributes"].get(c))))
    return "\n".join(head) + "\n\n" + "\nunion all\n".join(
        branch_sql(b, sat, view, spec) for b in branches)


def stage_body(feeder, sat, spec):
    view = feeder["view"]
    src = N.model_name("unpivot", view, N.sat_slug(sat["satellite"]))
    slot = feeder["branches"][0]["slot"]
    hashed = ["  %s: '%s'" % (slot["hkey"], slot["nk"])]
    hd_cols = sorted(sat["cdk"]) + sorted(sat["payload"])
    hashed.append("  %s:" % sat["hashdiff_stage"])
    hashed.append("    is_hashdiff: true")
    hashed.append("    columns:")
    for c in hd_cols:
        hashed.append("      - '%s'" % c)
    derived = ["  %s: %s" % (slot["nk"], N.yaml_scalar(N.natural_key(slot["hub"], slot["bk"])))]
    derived.append("  %s: '%s'" % (slot["bk"], slot["bk"]))
    for c in sorted(sat["cdk"]) + sorted(sat["payload"]):
        derived.append("  %s: '%s'" % (c, c))
    derived.append("  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'")
    derived.append("  RECORD_SOURCE: 'record_source'")
    return "\n".join([
        "{{ config(materialized='view') }}",
        "",
        "-- UNPIVOT STAGE for %s from %s." % (sat["satellite"], N.short_view(view)),
        "-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every",
        "-- column is listed explicitly: a stage that passes its source's columns through makes",
        "-- the satellite's real feeder columns invisible to anything reading the YAML, which is",
        "-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).",
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
    # FIRST writer of BOTH directories. gen_mtv2_stage writes the wide stages into the
    # stage directory afterwards and must NOT wipe it (BUILD_RULES 6.3).
    stale = N.wipe_layer("unpivot", "stage")
    print("gen_mtv2_unpivot: wiped %d stale file(s) from the unpivot and stage layers"
          % stale)

    counts = collections.Counter()
    families = []
    for f in spec["feeders"]:
        if f["mode"] != "unpivot":
            continue
        sat = sats.get((f["satellite"], f["track"]))
        if sat is None:
            counts["feeder_without_a_satellite"] += 1
            continue
        if sat["track"] != "target":
            continue            # the augmented track is gen_mtv2_augmented's
        slug = N.sat_slug(sat["satellite"])
        N.write_model(N.model_path("unpivot", N.model_name("unpivot", f["view"], slug)),
                      unpivot_body(f, sat, spec))
        N.write_model(N.model_path("stage", N.model_name("unpivot_stage", f["view"], slug)),
                      stage_body(f, sat, spec))
        counts["unpivot_models"] += 1
        counts["branches"] += len(f["branches"])
        families.append((f["view"], sat["satellite"], len(f["branches"])))

    print("gen_mtv2_unpivot (DECLARED BESPOKE -- EAV instance fan-out driven by a literal leg)")
    print("  column-as-instance families fanned out : %d" % counts["unpivot_models"])
    print("  instance branches emitted              : %d" % counts["branches"])
    print("  The map does not GROUP these families -- membership is derived here from the")
    print("  (satellite, constant-leg tuple) co-occurrence on each view. Too few branches drops")
    print("  instances silently, so the grouping is PRINTED (BUILD_RULES 9.5):")
    for view, sat, n in sorted(families, key=lambda x: (-x[2], x[1]))[:14]:
        print("      %-34s %-44s %d instance(s)" % (N.short_view(view), sat, n))
    if len(families) > 14:
        print("      ... %d more, all in build_artifacts/mtv2_spec.json" % (len(families) - 14))
    print("  (view, satellite) pairs with a constant leg but only ONE instance stay in the WIDE")
    print("  stage: one instance IS one row, and a model per constant is noise.")


if __name__ == "__main__":
    main()
