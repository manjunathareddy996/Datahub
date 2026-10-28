# -*- coding: utf-8 -*-
"""gen_mtv2_augmented.py -- THE UNRATIFIED TRACK.

Augmentation rows are build-side proposals: not ratified against data_7.js, per-column reversible,
and NEVER mixed into the standard track. They get their own staging models -- one per
(view, satellite), the sibling's own augmented shape -- so removing one proposal is removing one
model, not editing a shared wide stage.

This generator WIPES models/automate_dv/augmented before writing (BUILD_RULES 6.3) and creates
every directory it writes (6.4). gen_mtv2_align.py runs AFTER it and adds the satellites whose
concept the OPUS sibling already augments; this generator deliberately leaves those alone and
names them, so the two cannot both write one model.
"""
import collections
import json
import os
import shutil
import sys

import mtv2_names as N
import mtv2_keyrules as K
import build_mtv2_spec as S
import gen_mtv2_vault as V

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

AUG_DIRS = ["aug_stage", "aug_satfeed", "aug_sat"]


def _aug_stability_caveat(sat):
    """The same ONE modeller question on the augmented track (BUILD_RULES 9.8). Imported from the
    vault emitter so the two tracks cannot drift into two different caveats for one fact."""
    import gen_mtv2_vault
    return gen_mtv2_vault._stability_caveat(sat)


def wipe():
    """Remove the FILES this generator owns, leaving the directories in place.

    shutil.rmtree on the directory itself fails intermittently under OneDrive's sync lock, and a
    wipe that raises halfway leaves a half-built vault that looks like a source gap. Emptying the
    directory achieves the same thing (BUILD_RULES 6.3) and cannot half-fail in that way.
    """
    for key in AUG_DIRS:
        d = N.LAYER_DIRS[key]
        N.assert_writable(d)
        N.ensure_dir(d)
        for f in os.listdir(d):
            p = os.path.join(d, f)
            if os.path.isfile(p):
                os.remove(p)
            else:
                shutil.rmtree(p)


def branch_select(branch, sat, view, spec, source_model):
    lines = ["        %s as %s," % (branch["slot"]["sql"], branch["slot"]["bk"])]
    for col in sat["cdk"]:
        sql = branch["cdk"].get(col)
        if sql is None:
            return None
        lines.append("        %s as %s," % (sql, col))
    contributing = []
    for col in sat["payload"]:
        srcs = branch["attributes"].get(col)
        if srcs:
            lines.append("        %s as %s," % (S.payload_sql(srcs), col))
            contributing.extend(srcs)
        else:
            lines.append("        cast(null as varchar) as %s," % col)
    lines.append("        '%s' as record_source" % view)
    guard = " or ".join("%s is not null" % c for c in sorted(set(contributing))) or "1 = 1"
    return ("    select\n" + "\n".join(lines)
            + "\n    from {{ ref('%s') }}\n    where %s" % (source_model, guard))


def aug_fanout_body(feeder, sat, spec, aligned_note):
    """One row per instance for a fanned-out augmented feeder. A REAL model, because
    automate_dv.stage() resolves source_model with ref() and a CTE name would not compile."""
    view = feeder["view"]
    source_model = N.model_name("resolver" if spec["views"][view]["walks"] else "cast", view)
    selects = [branch_select(b, sat, view, spec, source_model) for b in feeder["branches"]]
    if any(x is None for x in selects):
        return None
    head = [
        "{{ config(materialized='view') }}",
        "",
        "-- AUGMENTED instance fan-out for %s from" % sat["emit_name"],
        "--   %s" % view,
        "-- %d branch(es): a column-as-instance family on the unratified track."
        % len(feeder["branches"]),
        "--",
        "-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).",
        "",
    ]
    return "\n".join(head) + "\n" + "\nunion all\n".join(selects)


def aug_stage_body(feeder, sat, spec, aligned_note, fanout_model=None):
    """The augmented stage for one (view, satellite).

    source_model is always a REAL model: the resolver/cast for a single-instance feeder, or the
    fan-out model for a column-as-instance family.
    """
    view = feeder["view"]
    branches = feeder["branches"]
    slot = branches[0]["slot"]
    if fanout_model:
        src = fanout_model
        derived = [
            "  %s: %s" % (slot["nk"], N.yaml_scalar(N.natural_key(slot["hub"], slot["bk"]))),
            "  %s: '%s'" % (slot["bk"], slot["bk"]),
        ]
        for c in list(sat["cdk"]) + list(sat["payload"]):
            derived.append("  %s: '%s'" % (c, c))
        derived.append("  RECORD_SOURCE: 'record_source'")
    else:
        src = N.model_name("resolver" if spec["views"][view]["walks"] else "cast", view)
        b = branches[0]
        derived = ["  %s: %s" % (slot["bk"], N.yaml_scalar(slot["sql"])),
                   "  %s: %s" % (slot["nk"], N.yaml_scalar(slot["nk_sql"]))]
        for c in sat["cdk"]:
            sql = b["cdk"].get(c)
            if sql is None:
                return None
            derived.append("  %s: %s" % (c, N.yaml_scalar(sql)))
        for c in sat["payload"]:
            derived.append("  %s: %s" % (c, N.yaml_scalar(S.payload_sql(b["attributes"].get(c)))))
        derived.append("  RECORD_SOURCE: '!%s'" % view)
    derived.append("  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'")
    for line in derived:
        K.assert_no_prose(line, "augmented stage %s / %s" % (view, sat["emit_name"]))

    hashed = ["  %s: '%s'" % (slot["hkey"], slot["nk"]),
              "  %s:" % sat["hashdiff_stage"], "    is_hashdiff: true", "    columns:"]
    for c in sorted(list(sat["cdk"]) + list(sat["payload"])):
        hashed.append("      - '%s'" % c)

    head = [
        "{{ config(materialized='view') }}",
        "",
        "-- MAXIMUS TRAVEL V2 AUGMENTED stage for %s from" % sat["emit_name"],
        "--   %s" % view,
        "--",
        "-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),",
        "-- so withdrawing a proposal is deleting a model rather than editing the standard",
        "-- track's wide stage. Nothing here feeds a standard satellite.",
    ]
    if aligned_note:
        head += ["--"] + ["-- " + line for line in aligned_note]
    if fanout_model:
        head += ["--",
                 "-- Reads the fan-out model %s: %d instance(s) on this view."
                 % (fanout_model, len(branches))]
    head += [
        "--",
        "-- %d payload column(s); the child key is %s."
        % (len(sat["payload"]), ", ".join(sat["cdk"]) or "absent (single-active)"),
    ] + [line for _leg in (sat.get("unstable_cdk") or []) for line in (
        "--",
        "-- ** UNSTABLE CHILD KEY (BUILD_RULES 5.2): %s is defined below from a RENUMBERING"
        % _leg,
        "-- ** ORDINAL. An ordinal is never a discriminator: a row inserted or removed",
        "-- ** renumbers the rest and re-attaches their history. BUILT AS MAPPED (5.7) and",
        "-- ** routed BLOCKING to the MODELLER.",
    )] + _aug_stability_caveat(sat) + [
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
    ]
    return "\n".join(head)


def aug_satfeed_body(sat, stage_models, slot_by_model):
    pk = sat["src_pk"]
    parts = []
    for m in stage_models:
        slot = slot_by_model[m]
        sel = ["%s as %s" % (slot["hkey"], pk)]
        for c in sat["cdk"]:
            sel.append(c)
        for c in sat["payload"]:
            sel.append(c)
        sel.append("%s as %s" % (sat["hashdiff_stage"], sat["hashdiff_sat"]))
        parts.append("    select\n        " + ",\n        ".join(sel)
                     + ",\n        LOAD_DATETIME, RECORD_SOURCE\n"
                       "    from {{ ref('%s') }}\n    where %s is not null" % (m, slot["hkey"]))
    head = [
        "{{ config(materialized='view') }}",
        "",
        "-- AUGMENTED FEED for %s: unions %d per-view stage model(s)."
        % (sat["emit_name"], len(stage_models)),
        "-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare %s the"
        % sat["hashdiff_sat"],
        "-- sibling writes on its augmented track too -- both of its tracks use the bare name,",
        "-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).",
        "",
    ]
    return "\n".join(head) + "\n" + "\nunion all\n".join(parts)


def main(only_aligned=False, label="gen_mtv2_augmented"):
    with open(S.SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    if not only_aligned:
        wipe()
    sats = {(s["satellite"], s["track"]): s for s in spec["satellites"]}
    by_sat = collections.defaultdict(list)
    for f in spec["feeders"]:
        sat = sats.get((f["satellite"], f["track"]))
        if sat is None or sat["track"] != "augmentation":
            continue
        by_sat[(f["satellite"], f["track"])].append(f)

    counts = collections.Counter()
    unbuilt, aligned, collisions = [], [], []
    for key, sat in sorted(sats.items()):
        if sat["track"] != "augmentation":
            continue
        is_aligned = sat["sibling_built"]
        if is_aligned != only_aligned:
            continue
        feeders = by_sat.get(key, [])
        if not feeders:
            unbuilt.append((sat["emit_name"], "no feeder reached the augmented layer"))
            continue

        note = None
        payload = list(sat["payload"])
        if is_aligned:
            contract = N.sibling_contract(sat["satellite"], track="augmentation")
            sib_payload = set(contract.get("src_payload") or [])
            drop = sorted(set(payload) & sib_payload)
            if drop:
                collisions.append((sat["emit_name"], drop))
                payload = [c for c in payload if c not in sib_payload]
            note = [
                "ALIGNED to the OPUS sibling (BUILD_RULES 7.7). travel_dv_dbt already builds",
                "%s with src_pk %s, single-active, no child key and a bare" % (sat["emit_name"],
                                                                              sat["src_pk"]),
                "HASHDIFF. This EXTENDS that satellite's payload; a second Maximus-side satellite",
                "for the same concept would be model invention wearing an AUG_ prefix.",
            ]
            if drop:
                note.append("%d attribute(s) already in the sibling's payload were dropped in "
                            "favour of OPUS's: %s." % (len(drop), ", ".join(drop)))
        if not payload:
            unbuilt.append((sat["emit_name"],
                            "every proposed attribute is already in the sibling's payload or "
                            "collided with a child-key leg; nothing is left to add"))
            continue

        emit_sat = dict(sat, payload=payload)
        stage_models, slot_by_model = [], {}
        for f in feeders:
            slug = N.sat_slug(sat["emit_name"])
            name = N.model_name("aug_stage", f["view"], slug)
            fanout = None
            if len(f["branches"]) > 1:
                fanout = N.model_name("unpivot", f["view"], "aug_" + slug)
                fbody = aug_fanout_body(f, emit_sat, spec, note)
                if fbody is not None:
                    N.write_model(os.path.join(N.LAYER_DIRS["aug_stage"], fanout + ".sql"), fbody)
                    counts["aug_fanouts"] += 1
                else:
                    fanout = None
            body = aug_stage_body(f, emit_sat, spec, note, fanout_model=fanout)
            if body is None:
                unbuilt.append((sat["emit_name"],
                                "a feeder on %s does not supply every declared child-key leg; a "
                                "null leg merges the instances the key exists to separate "
                                "(BUILD_RULES 5.3)" % N.short_view(f["view"])))
                continue
            N.write_model(N.model_path("aug_stage", name), body)
            stage_models.append(name)
            slot_by_model[name] = f["branches"][0]["slot"]
            counts["aug_stages"] += 1
        if not stage_models:
            continue
        feed = "satfeed_%s_aug_%s" % (N.PREFIX, N.sat_slug(sat["emit_name"]))
        N.write_model(os.path.join(N.LAYER_DIRS["aug_satfeed"], feed + ".sql"),
                      aug_satfeed_body(emit_sat, stage_models, slot_by_model))
        N.write_model(os.path.join(N.LAYER_DIRS["aug_sat"],
                                   "%s.sql" % N.sat_slug(sat["emit_name"])),
                      V.satellite_body(emit_sat, feed))
        counts["aug_satellites"] += 1
        counts["aug_multi_active"] += bool(sat["multi_active"])
        if is_aligned:
            aligned.append(sat["emit_name"])

    print(label)
    print("  augmented satellites : %d  (multi-active %d)"
          % (counts["aug_satellites"], counts["aug_multi_active"]))
    print("  augmented stages     : %d  (one per view per satellite, per-column reversible)"
          % counts["aug_stages"])
    print("  augmented fan-out models: %d  (column-as-instance families on the unratified track)"
          % counts["aug_fanouts"])
    if only_aligned:
        print("  aligned to an OPUS SAT_AUG_* : %d" % len(aligned))
        for a in aligned:
            print("      %s" % a)
        print("  attribute collisions dropped in favour of OPUS's payload: %d" % len(collisions))
        for name, drop in collisions:
            print("      %-42s %s" % (name, ", ".join(drop)))
    else:
        print("  Concepts the sibling ALREADY augments are NOT written here -- gen_mtv2_align.py")
        print("  writes them into the OPUS-named SAT_AUG_* under OPUS's contract (BUILD_RULES 7.7).")
    print("  augmented satellites NOT built: %d" % len(unbuilt))
    for name, why in unbuilt:
        print("      %-42s %s" % (name, why))
    return counts, unbuilt, aligned, collisions


if __name__ == "__main__":
    main(only_aligned=False)
