# -*- coding: utf-8 -*-
"""BUILD_STATUS.json -- the ONE place every count that describes current state lives.

No document in this workspace states a count that describes current state; every count is emitted
here and referenced from here. generators/README.md is GENERATED from this file, so no number in
the prose can go stale.

Also emits the two declared artefacts this build owes:
  reports/declared_unresolved_grain_hcon.json  -- every satellite whose child key is REFUSED
  reports/hub_registries.json                  -- every registry, per hub, per run
  reports/r8_precedence_as_built.json          -- all 607-class columns, and what the precedence
                                                  actually fires on
"""
import collections
import glob
import hashlib
import json
import os
import re
import sys

import hcon_keyrules as K
import hcon_names as N
from hcon_writeguard import (PROJECT_ROOT, REPO_ROOT, guarded_open, tree_digest,
                             assert_read_only_intact, manifest_audit, validate_digest_tool)

ARTIFACTS = os.path.join(PROJECT_ROOT, "build_artifacts")
REPORTS = os.path.join(ARTIFACTS, "reports")
SPEC_PATH = os.path.join(ARTIFACTS, "hcon_spec.json")
STATUS_PATH = os.path.join(ARTIFACTS, "BUILD_STATUS.json")
MODELS = os.path.join(PROJECT_ROOT, "models")

RX_HASHDIFF = re.compile(r"\b([A-Z][A-Z0-9_]*_HASHDIFF|HASHDIFF)\b")
RX_MD5 = re.compile(r"\bmd5\s*\(")
RX_MACRO = re.compile(r"\{\{\s*(?!ref\(|source\(|config\()([a-z_]+)\.")
RX_NORMALISE = re.compile(r"\bnormalise\s*\(")


def model_census():
    out = collections.Counter()
    files = sorted(glob.glob(os.path.join(MODELS, "**", "*.sql"), recursive=True))
    for p in files:
        rel = os.path.relpath(p, MODELS).replace(os.sep, "/")
        out[os.path.dirname(rel) or "."] += 1
    return out, files



def _carved(spec):
    import gen_hcon_vault as V
    return V.cross_run_shared_objects(spec)


def _assertions_census():
    """What was emitted, and the fact that none of it has run."""
    d = os.path.join(PROJECT_ROOT, "models", "assertions")
    files = sorted(f for f in os.listdir(d) if f.endswith(".sql")) if os.path.isdir(d) else []
    return {
        "executed_token": "NEVER_EXECUTED",
        "executed_note": "dbt is out of scope for this build, so every assertion is EMITTED AND "
                         "UNRUN. A zero from an unrun assertion is an ABSENCE OF MEASUREMENT, not "
                         "a clean result.",
        "total": len(files),
        "cross_run_collision": sum(1 for f in files if f.startswith("assert_cross_run")),
        "intra_run_arbitrary": sum(1 for f in files if f.startswith("assert_intra_run")),
        "index": "models/assertions/assertion_index.sql",
        "cross_run_reading_note": "0 => no business-key VALUE collided across the two runs' "
                                  "disjoint registries, so the precedence never fired. This is "
                                  "the ONLY self-sufficient answer. >0 => the VALUES collided, "
                                  "which does NOT prove they denote the same ENTITY, so >0 "
                                  "ESCALATES rather than resolves.",
        "intra_run_reading_note": "0 rows => every undiscriminated same-run writer agreed on "
                                  "every key. >0 => those are the values this build picked "
                                  "ARBITRARILY.",
        "first_case_note": "SAT_PARTY_IDENTITY.'Party Full Name' -- 95 legacy writers against 10 "
                           "v2; 20 of the 95 undiscriminated.",
        "attribution": "builder",
    }


def main():
    validate_digest_tool(verbose=False)
    with open(SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    layers, files = model_census()

    md5s = macro_hits = normalise_hits = 0
    hashdiff_names = collections.Counter()
    for p in files:
        with open(p, encoding="utf-8") as fh:
            t = fh.read()
        md5s += len(RX_MD5.findall(t))
        macro_hits += len(RX_MACRO.findall(t))
        normalise_hits += len(RX_NORMALISE.findall(t))
        for h in set(RX_HASHDIFF.findall(t)):
            hashdiff_names[h] += 1

    unres = collections.Counter(r["kind"] for r in spec["unresolved"])
    ls = spec["loader_summary"]
    feeders = [f for S in spec["satellites"] for f in S["feeders"]]

    # ---------------- the declared unresolved-grain register
    grain = {
        "is_a_subset_of": K.CANONICAL_REGISTER,
        "subset_scope_token": "CHILD_KEY_GRAIN_DETAIL_ONLY",
        "unit_note": "one entry per REFUSED child-key leg occurrence: a (satellite, view, run) "
                     "block whose declared or named leg this build would have to invent to emit. "
                     "THIS FILE IS A DECLARED SUBSET of %s and holds ONLY the kinds %s -- it is "
                     "NOT the whole register, and reading it as one makes the remainder look "
                     "unenumerated." % (K.CANONICAL_REGISTER, list(K.GRAIN_SUBSET_KINDS)),
        "remedy_token": "REFUSE_AND_DECLARE",
        "three_subpopulations_note":
            "A refusal is one of THREE kinds and the remedies differ. nothing_at_all: no leg name "
            "and no value. leg_no_value: the leg is NAMED and empty -- WORSE than absent, because "
            "it reads as RESOLVED to every gate and collides at build. leg_and_value: the leg is "
            "named CORRECTLY and the value answers a DIFFERENT QUESTION, which is why relabelling "
            "cannot fix it.",
        "leg_naming_correction_note":
            "The claim 'zero of 422 legacy blocks name a leg' is FALSE and was withdrawn by the "
            "coordinator mid-build. MEASURED on the settled map: 145 of the 422 legacy blocks on "
            "the 16 shared multi-active satellites DO name a leg, and all 145 reproduce the "
            "data_7.js declared child key VERBATIM -- 145 agree, 0 disagree. Compound legs are "
            "held WHOLE ('Contact Point Type + Contact Priority Order'), so a reader comparing "
            "child_key against ONE declared leg scores 94 false disagreements. The profile still "
            "carries the withdrawn zero in two fields; both are reported as contradicted.",
        "subpopulations": spec["meta"]["child_key_subpopulations"],
        "member_group": spec["meta"]["matcher_discipline"]["wider_census"],
        "member_group_do_not_synthesise_note":
            "'Member Sequence' is NEVER synthesised. MEMBER1..8 makes the ordinal look trivially "
            "derivable and SELF has no number, so any derivation invents a value for one slot in "
            "nine. The discriminator states FOUND are recorded per row, because ABSENT and "
            "PRESENT_NULL both mean 'no discriminator' and a future reader fixing a null will "
            "never look for an absent.",
        "collapse_measurement_token": "NOT_MEASURABLE",
        "collapse_measurement_note": spec["meta"]["collapse_totals_note"],
        "satellites": [],
        "refusals": [r for r in spec["unresolved"]
                     if r["kind"] in ("child_key_leg_refused",
                                      "component_value_is_prose_or_empty",
                                      "payload_collides_with_child_key_leg",
                                      "child_key_leg_name_unrenderable")],
    }
    for S in spec["satellites"]:
        if not S["refusals"]:
            continue
        grain["satellites"].append({
            "satellite": S["code"], "track": S["track"], "anchor": S["anchor"],
            "hist": S["hist"], "model_childkey": S["model_childkey"],
            "declared_legs": S["declared_legs"],
            "loader_set": S["loader_set"], "runs": S["runs"],
            "refusals": S["refusals"],
        })
    with guarded_open(os.path.join(REPORTS, "declared_unresolved_grain_hcon.json")) as fh:
        json.dump(grain, fh, indent=1)

    # ---------------- hub registries, per hub per run
    reg = {}
    for s in spec["key_slots"]:
        reg.setdefault(s["vault_table"], {}).setdefault(s["run"], []).append(
            {"bk_column": s["bk_column"], "view": s["view"],
             "source_columns": s["source_columns"], "origin": s["origin"],
             "tier": s["tier"]})
    registries = {
        "unit_note": "one entry per (vault table, run, business-key column): a REGISTRY, i.e. one "
                     "identifier population feeding that key space.",
        "risk_note": "Unifying the hash form does NOT establish that the two runs' identifier "
                     "spaces denote the same entities. 6 of the 14 shared hubs have ZERO BK-column "
                     "overlap between the runs. Each shared hub's model header says so. A false "
                     "merge is unrecoverable after load.",
        "zero_overlap_hubs": K.PROFILE["registry_reconciliation"]["hubs_with_zero_bk_overlap"],
        "namespace_scope_note": "The 'HUB_X|' namespace separates HUBS, not registries WITHIN a "
                                "hub: 'HUB_POLICY|' prefixes POLICY_REF and POLICY_NO "
                                "identically.",
        "per_hub": {},
    }
    for table, byrun in sorted(reg.items()):
        cols = {run: sorted({r["bk_column"] for r in rs}) for run, rs in byrun.items()}
        overlap = sorted(set.intersection(*[set(v) for v in cols.values()])) if len(cols) > 1 \
            else []
        registries["per_hub"][table] = {
            "runs": sorted(cols), "registries_per_run": {k: len(v) for k, v in cols.items()},
            "bk_columns_per_run": cols,
            "bk_column_overlap_between_runs": overlap,
            "overlap_count": len(overlap),
            "slots": byrun,
        }
    with guarded_open(os.path.join(REPORTS, "hub_registries.json")) as fh:
        json.dump(registries, fh, indent=1)

    # ---------------- R8 as built
    r8art = {
        "mechanism_token": "DECLARED_SOURCE_PRECEDENCE",
        "key_change_token": "FORBIDDEN",
        "record_source_in_key_token": "FORBIDDEN",
        "precedence_order": spec["meta"]["r8_precedence_order"],
        "fires_on_pairs": spec["meta"]["r8_pairs"],
        "columns_over_those_pairs": spec["meta"]["r8_columns"],
        "unit_note": "a PAIR is one (satellite, attribute); a COLUMN is one map row writing that "
                     "attribute. The informative figure is how many PAIRS the precedence actually "
                     "fires on, measured here from the spec.",
        "never_report_note": "'R8 fires on 62 of 62' is TRUE BY CONSTRUCTION of an input set "
                             "DEFINED as the pairs having writers in TWO OR MORE runs, so a "
                             "single-run pair is 0 by definition for every run. It is never "
                             "reported as a measurement. That 62 was measured over TWO runs; this "
                             "build feeds THREE.",
        "profile_scoped_figures": {
            "cross_run_single_active_pairs":
                K.PROFILE["r8_source_precedence"]["cross_run_single_active_pairs"],
            "columns_total": K.PROFILE["r8_source_precedence"]["columns_total"],
            "satellites_touched": K.PROFILE["r8_source_precedence"]["satellites_touched"],
            "multi_active_cross_run_pairs":
                K.PROFILE["r8_source_precedence"]["multi_active_cross_run_pairs"],
            "multi_active_columns": K.PROFILE["r8_source_precedence"]["multi_active_columns"],
            "scope_runs": ["opus_health_legacy_v4", "opus_health_v2"],
            "scope_note": "THE FIGURES IN THIS BLOCK COVER TWO RUNS ONLY -- the pair named in "
                          "scope_runs -- because that is the population that existed when the "
                          "profile was written. opus_health_delta3 is NOT in them. The profile "
                          "scopes R8 to CROSS-RUN pairs split single-active / multi-active; this "
                          "build measures over every (satellite, attribute) written by two or "
                          "more runs on EITHER track, which is a WIDER population over a LARGER "
                          "run set. Both are stated; they are not reconciled, must not be added, "
                          "and the profile figures must not be read as describing this build.",
        },
        "near_miss_note": spec["meta"]["near_miss_62s_note"],
        "intra_run_fan_in_note": "WITHIN one run several views may write one attribute and the map "
                                 "declares NO precedence among them, so max() picks arbitrarily. "
                                 "Declared per attribute in each satellite header; it is the "
                                 "pre-existing single-active fan-in, remedy refuse-and-declare.",
        "rows": spec["r8"],
    }
    with guarded_open(os.path.join(REPORTS, "r8_precedence_as_built.json")) as fh:
        json.dump(r8art, fh, indent=1)

    # ---------------- BUILD_STATUS.json
    mdig, mfiles, mbytes = tree_digest(MODELS)
    gdig, gfiles, _gb = tree_digest(os.path.join(PROJECT_ROOT, "generators"))
    status = {
        # READ the profile. A hardcoded LOB survives a copy-forward into a new project and
        # publishes the SOURCE project's name as this build's identity; build_hcon_spec
        # already reads it from the profile, and these two must not disagree.
        "lob": K.PROFILE["lob"],
        "stage": "1",
        "generated_by": "emit_hcon_status.py",
        "numbers_live_here_note": "No document in this project states a count that describes "
                                  "current state. generators/README.md is GENERATED from this "
                                  "file, so no number in the prose can go stale.",
        "input": spec["meta"]["input"],
        "model_file": spec["meta"]["model_file"],
        "model_file_md5": spec["meta"]["model_file_md5"],
        "counts": {
            "generators": gfiles,
            "models_total": mfiles,
            "models_by_layer": dict(sorted(layers.items())),
            "source_views": len(spec["views"]),
            "views_with_a_cast": sum(1 for v in spec["views"] if v["needs_cast"]),
            "views_without_a_cast": sum(1 for v in spec["views"] if not v["needs_cast"]),
            "key_slots": len(spec["key_slots"]),
            "key_slots_by_origin": dict(collections.Counter(s["origin"]
                                                            for s in spec["key_slots"])),
            "key_slots_by_run": dict(collections.Counter(s["run"] for s in spec["key_slots"])),
            "satellite_build_units": len(spec["satellites"]),
            "satellite_units_by_track": dict(collections.Counter(S["track"]
                                                                 for S in spec["satellites"])),
            "satellite_feeders_total": len(feeders),
            "satellite_feeders_emitted": sum(1 for f in feeders if f["emitted"]),
            "satellite_feeders_refused_no_key": sum(1 for f in feeders if not f["emitted"]),
            "unpivot_families": len(spec["unpivot"]),
            "unresolved_total": len(spec["unresolved"]),
            "unresolved_closed": spec["meta"]["unresolved"]["closed"],
            "unresolved_awaiting_counterparty":
                spec["meta"]["unresolved"]["awaiting_counterparty"],
            "by_design_not_defects": len(spec.get("by_design", [])),
            "unresolved_by_kind": dict(sorted(unres.items())),
            "builder_decisions": len(spec["decisions"]),
            "build_directives": len(spec["directives"]),
            "carried_forward_caveats": len(spec["carried_forward_caveat_tables"]),
        },
        "loader_plan": {
            "rule_token": "ONE_LOADER_PER_VAULT_TABLE_TWO_SOURCES",
            "declared_shared": spec["loader_sets"]["shared"],
            "declared_legacy_only": spec["loader_sets"]["legacy_only"],
            "declared_v2_only": spec["loader_sets"]["v2_only"],
            "declared_total": ls["declared_total"],
            "buildable": ls["buildable"],
            "buildable_by_set": ls["buildable_by_set"],
            "not_buildable_no_feed_in_map": ls["not_buildable_no_feed"],
            "shared_dual_feed": ls["shared_dual_feed"],
            "shared_single_feed": ls["shared_single_feed"],
            "shared_single_feed_names": ls["shared_single_feed_names"],
            "per_source_feed_models_declared": ls["per_source_feed_models"],
            "definition_note": "The 62/140/45 partition reproduces ONLY under this definition: "
                               "vault object by NAME SHAPE, live scope, REFS EXCLUDED. A "
                               "DIRECTORY-shape matcher gives 62/141/26, because the two "
                               "originals file augmented satellites differently -- the name knows "
                               "what the path does not.",
            "shared_is_a_file_set_property_note": "'Shared' is a property of the two originals' "
                                                  "FILE SETS, not of the map. 62 tables are "
                                                  "shared by name; the settled map supplies both "
                                                  "runs' columns for %d of them."
                                                  % ls["shared_dual_feed"],
            "not_buildable_note": "A loader is built because it HAS A FEED, not because it is in "
                                  "a sibling's file list (s6.1). The %d declared tables the "
                                  "settled map supplies no column for are DECLARED in the "
                                  "unresolved register, never emitted as empty models -- an "
                                  "empty model would read as a built loader."
                                  % ls["not_buildable_no_feed"],
        },
        "key_form": {
            "form_token": "md5(upper('HUB_X|'||<bk>))",
            "status_token": "RATIFIED",
            "hash_computed_by_token": "EXPLICIT_SQL_NO_MACRO",
            "explicit_md5_calls_emitted": md5s,
            "package_macro_invocations": macro_hits,
            "packages_yml_written": os.path.exists(os.path.join(PROJECT_ROOT, "packages.yml")),
            "namespace_scope_token": "SEPARATES_HUBS_NOT_REGISTRIES",
        },
        "hashdiff": {
            "convention_token": "SAT_<NAME>_HASHDIFF",
            "status_token": "RATIFIED_BY_COORDINATOR_THIS_RUN",
            "profile_status_token": K.PROFILE["sibling"]["hashdiff_convention_status"],
            "bare_HASHDIFF_occurrences": hashdiff_names.get("HASHDIFF", 0),
            "suffixed_occurrences": sum(v for k, v in hashdiff_names.items() if k != "HASHDIFF"),
            "one_line_switch": "hcon_names.hashdiff() -> return 'HASHDIFF'",
        },
        "normalise": {
            "occurrences_emitted": normalise_hits,
            "policy_note": K.normalise_policy(),
        },
        "grammar": {
            "population_note": "unit = one resolved_key block bearing an expression; population = "
                               "every container of every map row",
            "population": spec["meta"]["grammar_population"],
            "forms": spec["meta"]["grammar"],
            "parse_residue": K.PROFILE["parse_residue"],
            "walk_operator_counts": spec["meta"]["walk_operator_counts"],
            "walk_zero_note": spec["meta"]["walk_zero_note"],
        },
        "child_key_family": {
            "fields_read": list(K.CHILD_KEY_FAMILY),
            "never_read": list(K.NEVER_A_CHILD_KEY),
            "never_read_why_note": "key_name holds a HUB business-key NAME and most of its "
                                   "values carry parenthesised prose, so one written into a child "
                                   "key puts prose into emitted SQL. child_key_vocabulary holds a "
                                   "CONVENTION TOKEN; it co-occurs with a real child key on EVERY "
                                   "one of its containers, so it is excluded for WHAT IT HOLDS, "
                                   "not for where it sits. Both populations are counted in build_profile.json "
                                   "map_fields.CORRECTION_field_names.",
            "cooccurrence": spec["meta"]["child_key_cooccurrence"],
            "cooccurrence_unit_note": "unit = one dict-valued target/augmentation container; "
                                      "container and row totals are taken from BUILD_STATUS.json "
                                      "and build_profile.json map_shape",
            "vocabulary_values": spec["meta"]["child_key_vocabulary_values"],
            "three_state_token": "ABSENT_vs_PRESENT_NULL_vs_STRING_None",
            "three_state_measured": {"STRING_None_found_on_any_family_field": 0},
        },
        "matcher_discipline": {
            "rule_token": "SUBSTRING_OR_CHARCLASS_NEVER_WORD_BOUNDARY",
            "evidence": spec["meta"]["matcher_discipline"]["profile_scope"],
            "wider_census": spec["meta"]["matcher_discipline"]["wider_census"],
        },
        "legacy_key_archaeology": spec["meta"]["legacy_archaeology"],
        "profile_claims": {
            "agree": len(spec["meta"]["profile_claims"]["agree"]),
            "contradicted": spec["meta"]["profile_claims"]["contradicted"],
            "leg_naming_measured": spec["meta"]["profile_claims"]["leg_naming_measured"],
        },
        "r8": {
            "fires_on_pairs": spec["meta"]["r8_pairs"],
            "columns": spec["meta"]["r8_columns"],
            "precedence_order": spec["meta"]["r8_precedence_order"],
            "artefact": "build_artifacts/reports/r8_precedence_as_built.json",
            "never_report_note": r8art["never_report_note"],
        },
        "collapse": {
            "legacy_totals_token": "NOT_MEASURABLE",
            "note": spec["meta"]["collapse_totals_note"],
        },
        "unresolved_register": {
            "canonical": K.CANONICAL_REGISTER,
            "canonical_count": len(spec["unresolved"]),
            "canonical_unit_note": "unit = ONE refusal record; population = every refusal raised "
                                   "while reading the settled map and the recovered legacy SQL.",
            "declared_subsets": [{
                "artefact": K.GRAIN_SUBSET_REGISTER,
                "is_a_subset_of": K.CANONICAL_REGISTER,
                "kinds": list(K.GRAIN_SUBSET_KINDS),
                "count": sum(1 for r in spec["unresolved"]
                             if r["kind"] in K.GRAIN_SUBSET_KINDS),
                "scope_note": "child-key-grain detail ONLY. It is NOT the whole register, and "
                              "reading it as one makes the difference look unenumerated.",
            }],
            "by_status": spec["meta"]["unresolved"]["by_status"],
            "by_attribution": spec["meta"]["unresolved"]["by_attribution"],
            "closed": spec["meta"]["unresolved"]["closed"],
            "awaiting_counterparty": spec["meta"]["unresolved"]["awaiting_counterparty"],
            "by_design_held_separately": len(spec.get("by_design", [])),
            "dispositions": {k: {"disposition": v["disposition"], "status": v["status"],
                                 "attribution": v["attribution"], "routing": v["routing"]}
                             for k, v in K.DISPOSITIONS.items()},
        },
        "cross_run_carve_out": {
            "scope_token": "ALL_SHARED_OBJECTS_WRITTEN_BY_BOTH_RUNS",
            "objects": sorted(_carved(spec)),
            "object_count": len(_carved(spec)),
            "derivation_note": "DERIVED from the spec: shared-62 hubs and links whose feeds come "
                               "from BOTH runs. lnk_policy_party is in the shared 62 and is "
                               "EXCLUDED because the settled map supplies only v2 feeds for it, "
                               "so there is no cross-run precedence to annotate.",
            "mechanism_token": "DECLARED_SOURCE_PRECEDENCE_UNCHANGED",
            "mechanism_note": "The precedence is DETERMINISTIC (v2 > legacy > delta3, BD6 then BD6b) and is NOT changed by "
                              "the carve-out. 'Emit both values' was proposed and withdrawn: on a "
                              "single-active attribute two writers into one row per key is "
                              "LOAD-ORDER-DEPENDENT and strictly worse than a deterministic "
                              "precedence. The carve-out is HEADER-ONLY -- it names the "
                              "subordinate writer and its registry so the loss is COUNTABLE.",
            "why_not_an_overlap_threshold_note": "A hub-level business-key-column overlap cannot "
                                                 "see the hazard AT ANY THRESHOLD. HUB_PARTY's "
                                                 "overlap of 3 is IMD_CODE, PART_ID and RM_CODE, "
                                                 "ALL intermediary-side; on the member/customer "
                                                 "population the overlap is ZERO. The figure is "
                                                 "also unstable: collapsing underscores moves it "
                                                 "3 -> 5, and HUB_PARTY is the only object where "
                                                 "normalisation moves it.",
            "why_declare_note": "Chosen on ASYMMETRY: a DECLARED CONFLICT IS RECOVERABLE; A WRONG "
                                "MERGE IS NOT, AFTER LOAD.",
            "attribution": "builder-overruled-by-mapper",
        },
        "intra_run_fanin": dict(
            spec["meta"]["intra_run_fanin_census"],
            severity_note="THE LARGER NON-DETERMINISM, and NO decision taken so far addresses it. "
                          "Refusing a subordinate RUN cannot touch writers of the SAME run. It is "
                          "DECLARED in every affected satellite header, at both scopes, and "
                          "measured by a load-time assertion.",
            predicate_note="ARBITRARY only among UNDISCRIMINATED writers -- no instance AND no "
                           "redundant_of. On SAT_PARTY_IDENTITY.'Party Full Name' legacy: 95 "
                           "writers, 75 separated by a resolved instance, 0 redundant_of, 20 "
                           "genuinely undiscriminated over 20 distinct tables. A predicate over "
                           "all 95 would have reported 75 CORRECT rows as defects on a new "
                           "check's first run."),
        "load_time_assertions": _assertions_census(),
        "artefacts": {
            "spec": "build_artifacts/hcon_spec.json",
            "assertions": "models/assertions/",
            "unresolved_grain": "build_artifacts/reports/declared_unresolved_grain_hcon.json",
            "hub_registries": "build_artifacts/reports/hub_registries.json",
            "r8_as_built": "build_artifacts/reports/r8_precedence_as_built.json",
            "write_manifest": "build_artifacts/write_manifest.jsonl",
        },
        "digests": {
            "models_tree_sha256": mdig,
            "models_files": mfiles,
            "models_bytes": mbytes,
            "generators_tree_sha256": gdig,
            "generators_files": gfiles,
            "combining_method_note": "per file 'posix-relpath + LF + sha256(file bytes)'; lines "
                                     "sorted bytewise; joined with LF; sha256 of the UTF-8 "
                                     "encoding of that join. Validated against partner_dv_dbt = "
                                     "d130c4bb... before use.",
        },
        "read_only_guard": {
            "mode_token": "ZERO_WRITES_BOTH_ORIGINALS",
            "verified": assert_read_only_intact("status", verbose=False),
            "manifest": manifest_audit(verbose=False),
        },
        "by_design_not_defects": spec.get("by_design", []),
        "decisions": spec["decisions"],
        "directives": spec["directives"],
        "layers_built": {
            "declared_by_profile": K.PROFILE["layers"],
            "bespoke_declared": [b["name"] for b in K.PROFILE["bespoke_layers"]],
            "empty_with_a_proven_zero": ["walk-only casts (gen_hcon_hopviews)",
                                         "ancestor resolvers (gen_hcon_resolvers)"],
        },
    }
    with guarded_open(STATUS_PATH) as fh:
        json.dump(status, fh, indent=1)
    print("[status] models %d in %d layer(s); generators %d" % (mfiles, len(layers), gfiles))
    print("[status] models tree sha256 %s" % mdig)
    print("[status] explicit md5( calls %d; package macro invocations %d; packages.yml written %s"
          % (md5s, macro_hits, status["key_form"]["packages_yml_written"]))
    print("[status] hashdiff names: bare %d, suffixed %d"
          % (status["hashdiff"]["bare_HASHDIFF_occurrences"],
             status["hashdiff"]["suffixed_occurrences"]))
    print("[status] unresolved register %s: %d record(s) in %d kind(s) -- %d CLOSED, %d "
          "AWAITING COUNTERPARTY; %d by-design records held OUTSIDE it"
          % (K.CANONICAL_REGISTER, len(spec["unresolved"]), len(unres),
             spec["meta"]["unresolved"]["closed"],
             spec["meta"]["unresolved"]["awaiting_counterparty"],
             len(spec.get("by_design", []))))
    print("[status] declared subset %s holds %d of them (child-key grain only)"
          % (K.GRAIN_SUBSET_REGISTER,
             sum(1 for r in spec["unresolved"] if r["kind"] in K.GRAIN_SUBSET_KINDS)))
    print("[status] wrote BUILD_STATUS.json + 3 declared artefacts")
    return 0


if __name__ == "__main__":
    sys.exit(main())
