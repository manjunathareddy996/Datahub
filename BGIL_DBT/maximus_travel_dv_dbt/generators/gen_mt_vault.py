# -*- coding: utf-8 -*-
"""gen_mt_vault.py -- hub feeds, hubs, link feeds, links, satellite feeds, satellites, audit.

WIPES hubfeed/ hubs/ links/ satfeed/ satellites/ audit/ before writing, so it must run AFTER the
stage and unpivot layers (BUILD_RULES 6.3) and it creates every directory it writes (6.4).

Two things here are not the Maximus house pattern and are deliberate:

  * satfeed -- one view per satellite that unions its feeders and renames the wide stage's
    uniquely-named HASHDIFF_<SAT> to the BARE HASHDIFF the sibling writes on all 45 of its
    satellites. 27 views feed more than one sibling-built satellite (max 11), so a bare name
    cannot come from the wide stage itself. This is what keeps BUILD_RULES 12's shared-vault
    hashdiff divergence out of this build (BD7).
  * a link's degenerate role leg is carried into the link table so the grain is party x role
    rather than party alone (BD5).
"""
import collections
import json
import os
import shutil
import sys

import mt_names as N
import mt_keyrules as K
import build_mt_spec as S

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

WIPES = ["hubfeed", "hub", "link", "satfeed", "satellite", "audit"]

SHARED_VAULT_NOTE = [
    "-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,",
    "-- separate pipelines, one shared vault. This model declares ONLY this project's own",
    "-- sources and only the payload it populates -- it does not union the sibling's models.",
]


def wipe():
    """Remove the FILES this generator owns, leaving the directories in place.

    shutil.rmtree on the directory itself fails intermittently under OneDrive's sync lock, and a
    wipe that raises halfway leaves a half-built vault that looks like a source gap. Emptying the
    directory achieves the same thing (BUILD_RULES 6.3) and cannot half-fail in that way.
    """
    for key in WIPES:
        d = N.LAYER_DIRS[key]
        N.assert_writable(d)
        N.ensure_dir(d)
        for f in os.listdir(d):
            p = os.path.join(d, f)
            if os.path.isfile(p):
                os.remove(p)
            else:
                shutil.rmtree(p)


def stage_model_for(feeder, spec, sat):
    if feeder["mode"] == "unpivot":
        return N.model_name("unpivot_stage", feeder["view"], N.sat_slug(sat["satellite"]))
    return N.model_name("stage", feeder["view"])


# --------------------------------------------------------------------------- hubs
def hubfeed_body(hub, sources):
    lines = [
        "{{ config(materialized='view') }}",
        "",
        "-- FEED for %s: unions every INSTANCE of the hub into one key pair and DROPS null" % hub,
        "-- business keys. %d feeder(s)." % len(sources),
        "--",
        "-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging",
        "-- models: both projects populate one set of columns in the shared table rather than two.",
        "-- The NK string hashed upstream is the sibling's too ('%s|' || <business key>); a" % hub,
        "-- different NK spelling is a different hash for the same key.",
        "--",
        "-- `where <BK> is not null` is where the key-rejection directive actually bites. A key",
        "-- whose every operand was blank was already turned into NULL by render_key()'s CASE",
        "-- guard, and this is the line that refuses to write it. audit_mt_key_rejections",
        "-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.",
        "",
    ]
    parts = []
    for model, hkey, bk, instance in sources:
        parts.append(
            "    select %s as %s, %s as PARENT_BK,\n"
            "           LOAD_DATETIME, RECORD_SOURCE\n"
            "    from {{ ref('%s') }}\n"
            "    where %s is not null"
            % (hkey, N.hub_key_column(hub), bk, model, bk))
    return "\n".join(lines) + "\n" + "\nunion all\n".join(parts)


def hub_body(hub, feed):
    return "\n".join([
        "{{ config(materialized='incremental') }}",
        "",
        "-- MAXIMUS TRAVEL hub() for %s." % hub,
    ] + SHARED_VAULT_NOTE + [
        "--",
        "-- The key is a business code, never a hash, with ONE ratified exception: HUB_LOCATION's",
        "-- address content hash. Where the code needed a spine join it was recovered upstream in",
        "-- resolved_mt__*, so by here it is just a column.",
        "",
        "{%- set yaml_metadata -%}",
        "source_model:",
        "  - '%s'" % feed,
        "src_pk: '%s'" % N.hub_key_column(hub),
        "src_nk: 'PARENT_BK'",
        "src_ldts: 'LOAD_DATETIME'",
        "src_source: 'RECORD_SOURCE'",
        "{%- endset -%}",
        "",
        "{% set metadata_dict = fromyaml(yaml_metadata) %}",
        "",
        "{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],",
        "                    src_nk=metadata_dict['src_nk'],",
        "                    src_ldts=metadata_dict['src_ldts'],",
        "                    src_source=metadata_dict['src_source'],",
        "                    source_model=metadata_dict['source_model']) }}",
    ])


# --------------------------------------------------------------------------- links
def linkfeed_body(link, entry, stage_of_view):
    hubs = entry["hubs"]
    degen = entry["degenerate_columns"]
    cols = [N.hub_key_column(link)] + [N.hub_key_column(h) for h in hubs] + degen
    lines = [
        "{{ config(materialized='view') }}",
        "",
        "-- FEED for %s: %d feeder(s) over %d hub leg(s)%s."
        % (link, len(entry["feeders"]), len(hubs),
           " plus %d degenerate role leg(s)" % len(degen) if degen else ""),
        "--",
        "-- Every leg below was rendered by the SAME render_key() as the hub key it references, so",
        "-- a leg and its hub are byte-identical by construction. A disagreeing leg produces an",
        "-- empty join, which reads as sparse source data rather than as an error.",
    ]
    if degen:
        lines += [
            "--",
            "-- %s is a role CODE, not a hub key: data_7.js gives %s the hub list %s. It is"
            % (", ".join(degen), link, hubs),
            "-- carried here so the link grain is party x role; dropping it would collapse every",
            "-- role a party plays onto one link row (BD5).",
        ]
    lines.append("")
    parts = []
    for f in entry["feeders"]:
        legs = {l.get("hub"): l for l in f["legs"] if l["role"] == "hub"}
        sel = ["%s as %s" % (f["hkey"], N.hub_key_column(link))]
        ok = True
        for h in hubs:
            leg = legs.get(h)
            if leg is None:
                ok = False
                break
            sel.append("%s as %s" % (leg["column"], N.hub_key_column(h)))
        if not ok:
            continue
        for d in degen:
            hit = next((l for l in f["legs"] if l["role"] == "degenerate" and l["column"] == d),
                       None)
            sel.append("%s as %s" % (d if hit else "cast(null as varchar)", d))
        parts.append("    select %s,\n           LOAD_DATETIME, RECORD_SOURCE\n"
                     "    from {{ ref('%s') }}\n    where %s is not null"
                     % (", ".join(sel), stage_of_view[f["view"]], f["bk"]))
    return "\n".join(lines) + "\n" + "\nunion all\n".join(parts), cols


def link_body(link, entry, feed):
    hubs = entry["hubs"]
    fk = [N.hub_key_column(h) for h in hubs] + entry["degenerate_columns"]
    return "\n".join([
        "{{ config(materialized='incremental') }}",
        "",
        "-- MAXIMUS TRAVEL link() for %s." % link,
    ] + SHARED_VAULT_NOTE + [
        "",
        "{%- set yaml_metadata -%}",
        "source_model:",
        "  - '%s'" % feed,
        "src_pk: '%s'" % N.hub_key_column(link),
        "src_fk:",
    ] + ["  - '%s'" % c for c in fk] + [
        "src_ldts: 'LOAD_DATETIME'",
        "src_source: 'RECORD_SOURCE'",
        "{%- endset -%}",
        "",
        "{% set metadata_dict = fromyaml(yaml_metadata) %}",
        "",
        "{{ automate_dv.link(src_pk=metadata_dict['src_pk'],",
        "                     src_fk=metadata_dict['src_fk'],",
        "                     src_ldts=metadata_dict['src_ldts'],",
        "                     src_source=metadata_dict['src_source'],",
        "                     source_model=metadata_dict['source_model']) }}",
    ])


# --------------------------------------------------------------------------- satellites
def satfeed_body(sat, feeders, spec, layer):
    """One view per satellite. Unions the feeders, null-pads to the SATELLITE and renames the
    stage's per-satellite hashdiff to the sibling's bare HASHDIFF (BD7)."""
    pk = sat["src_pk"]
    lines = [
        "{{ config(materialized='view') }}",
        "",
        "-- FEED for %s (%s track): unions %d feeder(s)."
        % (sat["emit_name"], sat["track"], len(feeders)),
        "--",
        "-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one",
        "-- feeder group (BUILD_RULES 6). %d payload column(s), %d child-key column(s)."
        % (len(sat["payload"]), len(sat["cdk"])),
        "--",
        "-- The hashdiff is renamed here from the wide stage's %s to the bare %s the sibling"
        % (sat["hashdiff_stage"], sat["hashdiff_sat"]),
        "-- writes on all 45 of its satellites. The wide stage cannot use the bare name because",
        "-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).",
        "",
    ]
    parts = []
    for f in feeders:
        b = f["branches"][0]
        cols = b.get("stage_columns", {})
        slot = b["slot"]
        sel = ["%s as %s" % (slot["hkey"], pk)]
        for c in sat["cdk"]:
            sel.append("%s as %s" % (cols.get(c, c), c))
        for c in sat["payload"]:
            sel.append("%s as %s" % (cols.get(c, c), c))
        sel.append("%s as %s" % (sat["hashdiff_stage"], sat["hashdiff_sat"]))
        model = stage_model_for(f, spec, sat)
        body = ("    select\n        " + ",\n        ".join(sel)
                + ",\n        LOAD_DATETIME, RECORD_SOURCE\n"
                  "    from {{ ref('%s') }}\n    where %s is not null" % (model, slot["hkey"]))
        parts.append(body)
    return "\n".join(lines) + "\n" + "\nunion all\n".join(parts)


def satellite_body(sat, feed):
    macro = "ma_sat" if sat["multi_active"] else "sat"
    head = [
        "{{ config(materialized='incremental') }}",
        "",
        "-- MAXIMUS TRAVEL %s() for %s." % (macro, sat["emit_name"]),
    ] + SHARED_VAULT_NOTE
    if sat["sibling_built"]:
        head += [
            "--",
            "-- src_pk, grain and src_cdk are the SIBLING's exactly (BUILD_RULES 7.2 / 7.7). The",
            "-- sibling builds this satellite on its %s track; where this map asks for a grain"
            % sat["sibling_track"],
            "-- the sibling does not carry, the SIBLING WINS and the difference is a modeller item",
            "-- in the build report -- it is not resolved here.",
        ]
    else:
        head += [
            "--",
            "-- The sibling does not build this satellite, so this build ESTABLISHES its contract",
            "-- (BUILD_RULES 7.3): bare HASHDIFF, %s, %s."
            % (sat["src_pk"], "multi-active on " + ", ".join(sat["cdk"])
               if sat["multi_active"] else "single-active"),
        ]
    if sat["grain_divergence"]:
        head += [
            "--",
            "-- GRAIN DIVERGENCE, reported not resolved: this map declares multi_active=%s with"
            % sat["grain_divergence"]["maximus_declared"]["multi_active"],
            "-- child key %s; the sibling builds it %s."
            % (sat["grain_divergence"]["maximus_declared"]["src_cdk"] or "(none)",
               "multi-active on " + ", ".join(sat["grain_divergence"]["sibling"]["src_cdk"])
               if sat["grain_divergence"]["sibling"]["multi_active"] else "single-active"),
        ]
    for _leg in sat.get("unstable_cdk") or []:
        head += [
            "--",
            "-- ** UNSTABLE CHILD KEY (BUILD_RULES 5.2): %s." % _leg,
            "-- ** That source column is a RENUMBERING ORDINAL, re-derived by shape from the",
            "-- ** source index, and an ordinal is never a discriminator. A row inserted or",
            "-- ** removed renumbers the rest and re-attaches their history, exactly as a",
            "-- ** renumbered hub key would. A child-key leg needs hub-grade stability.",
            "-- ** BUILT AS MAPPED (BUILD_RULES 5.7). Routed BLOCKING to the MODELLER; see",
            "-- ** build_artifacts/mt_spec.json census.ordinal_child_key_summary.",
        ] + _stability_caveat(sat)
    yaml = ["{%- set yaml_metadata -%}", "source_model:", "  - '%s'" % feed,
            "src_pk: '%s'" % sat["src_pk"]]
    if sat["multi_active"]:
        yaml.append("src_cdk:")
        for c in sat["cdk"]:
            yaml.append("  - '%s'" % c)
    yaml.append("src_payload:")
    for c in sat["payload"]:
        yaml.append("  - '%s'" % c)
    yaml += ["src_hashdiff: '%s'" % sat["hashdiff_sat"],
             "src_ldts: 'LOAD_DATETIME'", "src_source: 'RECORD_SOURCE'", "{%- endset -%}"]
    call = ["", "{% set metadata_dict = fromyaml(yaml_metadata) %}", "",
            "{{ automate_dv.%s(src_pk=metadata_dict['src_pk']," % macro]
    if sat["multi_active"]:
        call.append("                      src_cdk=metadata_dict['src_cdk'],")
    call += ["                      src_payload=metadata_dict['src_payload'],",
             "                      src_hashdiff=metadata_dict['src_hashdiff'],",
             "                      src_ldts=metadata_dict['src_ldts'],",
             "                      src_source=metadata_dict['src_source'],",
             "                      source_model=metadata_dict['source_model']) }}"]
    return "\n".join(head + [""] + yaml + call)


# --------------------------------------------------------------------------- audit
def audit_body(spec, stage_of_view):
    """Diagnostics that falsify the build's stated assumptions BEFORE any load.

    Every one of these counts something that is currently UNPROVEN. They exist because a guard
    that never fires and a guard that cannot fire read identically (BUILD_RULES 1)."""
    parts = []
    for slot in spec["key_slots"]:
        parts.append(
            "    select '%s' as hub, '%s' as feeder, '%s' as instance,\n"
            "           count(*) as rows_in,\n"
            "           count(%s) as rows_keyed,\n"
            "           count(*) - count(%s) as rows_rejected\n"
            "    from {{ ref('%s') }}"
            % (slot["hub"], N.short_view(slot["view"]), slot["instance"] or "-",
               slot["bk"], slot["bk"], stage_of_view[slot["view"]]))
    head = [
        "{{ config(materialized='view') }}",
        "",
        "-- KEY REJECTIONS, per hub PER FEEDER.",
        "--",
        "-- Directive D-REJECT asks for a per-hub rejected-row count. This is that count, and it",
        "-- is the ONLY thing that makes a zero meaningful: every key expression in this map",
        "-- evaluates to NULL on an all-blank row under Snowflake semantics, so a predicate of the",
        "-- form key = 'RISK:' could never fire while looking exactly like a working guard.",
        "-- Rejection is by SHAPE -- the CASE guard in render_key() -- and this model measures it.",
        "--",
        "-- Expect zeroes here on clean data. A zero is a MEASURED zero, not evidence the",
        "-- mechanism works; a non-zero names the feeder and the instance that produced it.",
        "",
    ]
    return "\n".join(head) + "\n" + "\nunion all\n".join(parts)


def audit_fk_roundtrip(spec):
    seen, parts = set(), []
    for view, info in spec["views"].items():
        for w in info["walks"]:
            if w["join_column"] != "FOREIGN_KEY" or not w["chain"]:
                continue
            dest = w["chain"][-1]
            if (dest, w["column"]) in seen:
                continue
            seen.add((dest, w["column"]))
            parts.append(
                "    select '%s' as destination_view, '%s' as business_column,\n"
                "           count(distinct foreign_key) as distinct_handles,\n"
                "           count(distinct %s) as distinct_business_numbers,\n"
                "           max(per_handle) as max_business_numbers_per_handle\n"
                "    from (select foreign_key, %s,\n"
                "                 count(distinct %s) over (partition by foreign_key) as per_handle\n"
                "          from {{ ref('%s') }})"
                % (N.short_view(dest), w["column"], N.cast_alias(w["column"]),
                   N.cast_alias(w["column"]), N.cast_alias(w["column"]),
                   N.model_name("cast", dest)))
    head = [
        "{{ config(materialized='view') }}",
        "",
        "-- FOREIGN_KEY ROUND-TRIP DIAGNOSTIC (open item P6-FK-ROUNDTRIP, decision BD1).",
        "--",
        "-- 863 spine occurrences in this map join on FOREIGN_KEY as a DOCUMENT HANDLE. Whether",
        "-- that handle round-trips 1:1 to the root business number is UNPROVEN:",
        "-- 00_tables_index.json carries sample_data_available=false and an empty",
        "-- sample_data_files map, so no probe could be run at build time.",
        "--",
        "-- max_business_numbers_per_handle > 1 FALSIFIES the assumption. Those keys would be",
        "-- WRONG rather than empty, which nothing downstream can see.",
        "",
    ]
    return "\n".join(head) + "\n" + "\nunion all\n".join(parts)


def audit_namespaces(spec, stage_of_view):
    parts = []
    for slot in spec["key_slots"]:
        if slot["hub"] not in ("HUB_RISK_OBJECT",):
            continue
        parts.append(
            "    select '%s' as feeder, '%s' as instance,\n"
            "           split_part(%s, ':', 1) as namespace, count(*) as rows_in,\n"
            "           count(distinct %s) as distinct_keys\n"
            "    from {{ ref('%s') }} where %s is not null group by 1,2,3"
            % (N.short_view(slot["view"]), slot["instance"] or "-", slot["bk"], slot["bk"],
               stage_of_view[slot["view"]], slot["bk"]))
    head = [
        "{{ config(materialized='view') }}",
        "",
        "-- HUB_RISK_OBJECT carries TWO namespaces: 'RISK:' on 215 key rows and 'TRIP:' on 12,",
        "-- and BOTH write SAT_RISK_PERSON_TRAVEL (open items RISKOBJ-TWO-NAMESPACES and",
        "-- TRIPNO-FALLBACK). This counts the split so two populations are visible rather than",
        "-- silent.",
        "--",
        "-- The TRIP: keys fall back to TRIP_NO when PNR is blank. If TRIP_NO is a per-policy",
        "-- ordinal rather than a global trip identifier, every policy's first trip collapses onto",
        "-- 'TRIP:1'. distinct_keys far below rows_in on the TRIP: namespace is that symptom.",
        "",
    ]
    return "\n".join(head) + "\n" + "\nunion all\n".join(parts) if parts else None


def _stability_caveat(sat):
    """The ONE modeller question, in the model (BUILD_RULES 9.8).

    Every fact here is read from the spec's cdk_stability block, which the spec derived from the
    map's own augmentation.child_key_stability. The candidate key is named only where it was
    verified to be a real source column on the view. The mapper's sentence is NOT reproduced -- a
    model comment states the question in the builder's own words, because copying a prose field
    into a model is how prose reaches a model (BUILD_RULES 3.3).
    """
    lines = []
    for rec in (sat.get("cdk_stability") or []):
        sole = len(sat.get("cdk") or []) == 1
        lines += [
            "-- **",
            "-- ** SOLE LEG: %s. This child key has %d leg(s), so the ordinal is %s."
            % ("YES" if sole else "no", len(sat.get("cdk") or []),
               "the ONLY discriminator" if sole else "one leg of a compound"),
            "-- ** The map already routes this as a source gap (%s) over %d map row(s) on %d "
            "view(s)." % (rec["disposition_token"] or "declared", rec["map_rows"],
                          len(rec["views"])),
        ]
        if rec["candidate_stable_key_column"]:
            lines += [
                "-- ** ONE QUESTION SETTLES IT: is %s populated and unique per row of this"
                % rec["candidate_stable_key_column"],
                "-- ** satellite's grain? If yes, the child key moves to it in one pass. If no,",
                "-- ** this grain has no stable identifier and the satellite cannot carry",
                "-- ** history at all.",
            ]
        else:
            lines += [
                "-- ** The map names no candidate stable key that resolves to a real column on",
                "-- ** this view, so none is named here rather than guessed.",
            ]
    return lines


def audit_link_leg_divergence(spec, stage_of_view):
    """Counts link legs that reach no hub row (BD12).

    7 legs in this map carry an expression that differs in VALUE from the key the same view
    resolves for the same hub -- on CLAIM_RESERVE the hub key walks FOREIGN_KEY and the leg walks
    PARENT_KEY_HASH, and 'EMP:' || BAGIC_RM_ECODE is an orphan no hub key anywhere produces. They
    are built AS MAPPED because substituting one key expression for another is correcting the
    mapping (BUILD_RULES 5.7). This is the model that stops that decision from being invisible:
    a leg with orphan_legs > 0 is a link joining to nothing.
    """
    parts = []
    for entry in spec["links"]:
        link = entry["link"]
        for f in entry["feeders"]:
            for leg in f["legs"]:
                if leg["role"] != "hub":
                    continue
                parts.append(
                    "    select '%s' as link, '%s' as hub, '%s' as feeder,\n"
                    "           count(*) as legs_emitted,\n"
                    "           count(h.%s) as legs_matching_a_hub_row,\n"
                    "           count(*) - count(h.%s) as orphan_legs\n"
                    "    from {{ ref('%s') }} s\n"
                    "    left join {{ ref('hub_%s') }} h on h.%s = s.%s\n"
                    "    where s.%s is not null"
                    % (link, leg["hub"], N.short_view(f["view"]),
                       N.hub_key_column(leg["hub"]), N.hub_key_column(leg["hub"]),
                       stage_of_view[f["view"]], N.hub_slug(leg["hub"]),
                       N.hub_key_column(leg["hub"]), leg["column"], leg["column"]))
    if not parts:
        return None
    head = [
        "{{ config(materialized='view') }}",
        "",
        "-- LINK LEG vs HUB KEY divergence (decision BD12, open item LEG-KEY-VALUE-DIVERGENCE).",
        "--",
        "-- A link leg must be byte-identical to the key of the hub it references. Where the map",
        "-- gives the leg a different expression, the leg is built AS MAPPED -- substituting the",
        "-- hub's expression would be the build correcting the mapping (BUILD_RULES 5.7).",
        "--",
        "-- The cost of that is SILENT: the leg joins to nothing and reads downstream as sparse",
        "-- source data. orphan_legs > 0 on any row below is that failure, named by link, hub and",
        "-- feeder. Expect zeroes where the leg and the key agree; a zero here is a MEASURED zero.",
        "--",
        "-- 7 value-changing divergences are in the map today, the two that matter being",
        "-- HUB_CLAIM on CLAIM_RESERVE (hub key walks FOREIGN_KEY, leg walks PARENT_KEY_HASH, so",
        "-- the leg rides the UNPROVEN FK round-trip and the hub does not) and the orphan leg",
        "-- 'EMP:' || BAGIC_RM_ECODE, which no HUB_PARTY key anywhere produces.",
        "",
    ]
    return "\n".join(head) + "\n" + "\nunion all\n".join(parts)


def main():
    with open(S.SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    wipe()
    sats = {(s["satellite"], s["track"]): s for s in spec["satellites"]}
    stage_of_view = {v: N.model_name("stage", v) for v in spec["map_views"]}

    # ---- hub feeds
    hub_sources = collections.defaultdict(list)
    for slot in spec["key_slots"]:
        hub_sources[slot["hub"]].append(
            (stage_of_view[slot["view"]], slot["hkey"], slot["bk"], slot["instance"]))
    for f in spec["feeders"]:
        sat = sats.get((f["satellite"], f["track"]))
        if sat is None or f["mode"] != "unpivot" or sat["track"] != "target":
            continue
        b = f["branches"][0]
        model = N.model_name("unpivot_stage", f["view"], N.sat_slug(sat["satellite"]))
        entry = (model, b["slot"]["hkey"], b["slot"]["bk"], None)
        if entry not in hub_sources[b["slot"]["hub"]]:
            hub_sources[b["slot"]["hub"]].append(entry)

    counts = collections.Counter()
    for hub, sources in sorted(hub_sources.items()):
        if hub.startswith("LNK_"):
            continue
        uniq = sorted(set(sources))
        feed = "hubfeed_%s_%s" % (N.PREFIX, N.hub_slug(hub))
        N.write_model(os.path.join(N.LAYER_DIRS["hubfeed"], feed + ".sql"),
                      hubfeed_body(hub, uniq))
        N.write_model(os.path.join(N.LAYER_DIRS["hub"], "hub_%s.sql" % N.hub_slug(hub)),
                      hub_body(hub, feed))
        counts["hubs"] += 1
        counts["hub_feeders"] += len(uniq)

    # ---- links
    for entry in spec["links"]:
        link = entry["link"]
        feed = "lnkfeed_%s_%s" % (N.PREFIX, N.hub_slug(link))
        body, _cols = linkfeed_body(link, entry, stage_of_view)
        N.write_model(os.path.join(N.LAYER_DIRS["link"], feed + ".sql"), body)
        N.write_model(os.path.join(N.LAYER_DIRS["link"], "link_%s.sql" % N.hub_slug(link)),
                      link_body(link, entry, feed))
        counts["links"] += 1

    # ---- satellites (standard track only; the augmented track is gen_mt_augmented's)
    by_sat = collections.defaultdict(list)
    for f in spec["feeders"]:
        sat = sats.get((f["satellite"], f["track"]))
        if sat is None or sat["track"] != "target":
            continue
        by_sat[(f["satellite"], f["track"])].append(f)

    unbuilt_here = []
    for key, sat in sorted(sats.items()):
        if sat["track"] != "target":
            continue
        feeders = by_sat.get(key, [])
        if not feeders:
            unbuilt_here.append((sat["satellite"], "no feeder reached the vault layer"))
            continue
        if not sat["payload"]:
            unbuilt_here.append((sat["satellite"],
                                 "every payload attribute collided with a child-key leg name and "
                                 "was dropped (BUILD_RULES 5.4); nothing is left to describe"))
            continue
        feed = "satfeed_%s_%s" % (N.PREFIX, N.sat_slug(sat["emit_name"]))
        N.write_model(os.path.join(N.LAYER_DIRS["satfeed"], feed + ".sql"),
                      satfeed_body(sat, feeders, spec, "standard"))
        N.write_model(os.path.join(N.LAYER_DIRS["satellite"],
                                   "%s.sql" % N.sat_slug(sat["emit_name"])),
                      satellite_body(sat, feed))
        counts["satellites"] += 1
        counts["multi_active"] += bool(sat["multi_active"])
        counts["sat_feeders"] += len(feeders)

    # ---- audit
    N.write_model(os.path.join(N.LAYER_DIRS["audit"], "audit_%s_key_rejections.sql" % N.PREFIX),
                  audit_body(spec, stage_of_view))
    N.write_model(os.path.join(N.LAYER_DIRS["audit"], "audit_%s_fk_roundtrip.sql" % N.PREFIX),
                  audit_fk_roundtrip(spec))
    lld = audit_link_leg_divergence(spec, stage_of_view)
    if lld:
        N.write_model(os.path.join(N.LAYER_DIRS["audit"],
                                   "audit_%s_link_leg_divergence.sql" % N.PREFIX), lld)
        counts["audit"] += 1
    ns = audit_namespaces(spec, stage_of_view)
    if ns:
        N.write_model(os.path.join(N.LAYER_DIRS["audit"],
                                   "audit_%s_riskobject_namespaces.sql" % N.PREFIX), ns)
        counts["audit"] += 1
    counts["audit"] += 2

    print("gen_mt_vault")
    print("  hubs                : %d   (%d feeder slot(s))" % (counts["hubs"], counts["hub_feeders"]))
    print("  links               : %d" % counts["links"])
    print("  satellites (standard): %d   of which multi-active %d, over %d feeder(s)"
          % (counts["satellites"], counts["multi_active"], counts["sat_feeders"]))
    print("  satfeed views       : %d   (the bare-HASHDIFF rename, BD7)" % counts["satellites"])
    print("  audit models        : %d" % counts["audit"])
    print("  satellites NOT built at this layer: %d -- each with its reason:" % len(unbuilt_here))
    for name, why in unbuilt_here:
        print("      %-40s %s" % (name, why))
    print("  Every other unbuilt item, with its routing, is in build_artifacts/mt_spec.json")
    print("  under 'unbuilt' (%d entries) -- a satellite left unbuilt says why, or it is"
          % len(spec["unbuilt"]))
    print("  indistinguishable from a source gap.")
    return unbuilt_here


if __name__ == "__main__":
    main()
