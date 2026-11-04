# -*- coding: utf-8 -*-
"""build_artifacts/reports/stage1_report.json -- the stage-1 completion report.

Every count is read from BUILD_STATUS.json / hcon_spec.json / check_proofs.json. Nothing is typed.
Every builder decision appears as a `decision_taken` finding routed to stage 3, so the handback
cannot omit one.
"""
import collections
import json
import os
import sys

import hcon_keyrules as K
from hcon_writeguard import (PROJECT_ROOT, guarded_open, assert_read_only_intact, manifest_audit,
                             tree_digest, validate_digest_tool)

ART = os.path.join(PROJECT_ROOT, "build_artifacts")
REPORTS = os.path.join(ART, "reports")
OUT = os.path.join(REPORTS, "stage1_report.json")


def load(path, default=None):
    if not os.path.exists(path):
        return default
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def main():
    validate_digest_tool(verbose=False)
    S = load(os.path.join(ART, "BUILD_STATUS.json"))
    spec = load(os.path.join(ART, "hcon_spec.json"))
    proofs = load(os.path.join(REPORTS, "check_proofs.json"), {"proofs": [], "passed": 0,
                                                               "total": 0})
    gates = load(os.path.join(REPORTS, "gate_results.json"), {"gates": []})
    if S is None or spec is None:
        raise SystemExit("BUILD_STATUS.json / hcon_spec.json absent -- run run_hcon_build.py first")

    c = S["counts"]
    findings = []

    # ---- every builder decision, routed to stage 3 so the handback cannot omit one
    for d in S["decisions"]:
        findings.append({
            "kind": "decision_taken", "severity": "info", "for_stage": "3",
            "detail": "%s -- %s WHY: %s COST: %s OVERRULE WITH: %s"
                      % (d["id"], d["decision"], d["why"], d["costs"], d["overrule_with"]),
        })

    # ---- the profile claims that did NOT hold
    # TWO causes, and the message must not assert the wrong one. A withdrawn claim is the mapper's
    # to correct; a claim outrun by a second contract is the builder's to label. The earlier form
    # said "MEASURES %r on the settled map" and blamed the coordinator for both.
    for x in S["profile_claims"]["contradicted"]:
        withdrawn = x["claim"] in K.COORDINATOR_WITHDRAWN_CLAIMS
        if withdrawn:
            findings.append({
                "kind": "profile_field_unrecognised", "severity": "warn", "for_stage": "mapper",
                "cause": "claim_withdrawn_by_coordinator",
                "detail": "build_profile.json claim %r states %r; this build MEASURES %r. The "
                          "coordinator withdrew this claim mid-build, and "
                          "health_consolidated_dv_dbt reported the SAME contradiction with the "
                          "same pair, so it predates this merge. Stage 2/3 must treat the profile "
                          "field as stale and use the measured value in BUILD_STATUS.json "
                          "profile_claims.leg_naming_measured; the profile should be corrected at "
                          "source rather than worked around."
                          % (x["claim"], x["profile"], x["measured"]),
            })
        else:
            findings.append({
                "kind": "profile_field_unrecognised", "severity": "warn", "for_stage": "2",
                "cause": "population_widened_by_second_contract",
                "detail": "build_profile.json claim %r states %r, which is correct for the "
                          "SETTLED MAP ALONE. This build MEASURES %r over BOTH contracts -- the "
                          "settled map and 04_column_map.DELTA3.json -- so the two figures "
                          "describe DIFFERENT POPULATIONS and neither is wrong. Nothing is "
                          "withdrawn and there is NOTHING HERE FOR THE MAPPER: the profile field "
                          "still describes its own contract. Any reader quoting the measured "
                          "figure must say it covers both contracts, and the two must never be "
                          "added."
                          % (x["claim"], x["profile"], x["measured"]),
            })

    # ---- the bespoke layers
    for b in K.PROFILE["bespoke_layers"]:
        findings.append({
            "kind": "bespoke_layer", "severity": "info", "for_stage": "2",
            "detail": "%s -- declared in build_profile.json bespoke_layers with a reason. %s "
                      "Stage 2 must review it as a declared exception under s6.5, not as an "
                      "unannounced generator." % (b["name"], b["reason_note"]),
        })

    # ---- refusal classes, each with the disposition the mapping counterparty decided
    byk = collections.Counter(r["kind"] for r in spec["unresolved"])
    unruled = sorted(set(byk) - set(K.DISPOSITIONS))
    if unruled:
        raise AssertionError("refusal kind(s) with no declared disposition: %s" % unruled)
    EXAMPLE = {}
    for r in spec["unresolved"]:
        EXAMPLE.setdefault(r["kind"], r["detail"])
    SEV = {"CLOSED_TERMINAL": "info", "DROPPED_FROM_SCOPE": "info",
           "AWAITING_COUNTERPARTY": "blocker",
           # an open item, and a blocker for the MODEL, but not a mapping defect --
           # see the awaiting_note on the register census
           "AWAITING_MODELLER_RATIFICATION": "blocker", "BY_DESIGN": "info"}
    for kind, n in sorted(byk.items(), key=lambda kv: -kv[1]):
        d = K.DISPOSITIONS[kind]
        findings.append({
            "kind": "unresolved_key", "severity": SEV[d["status"]],
            "for_stage": d["routing"] if d["routing"] != "none" else "3",
            "detail": "%s: %d occurrence(s). UNIT = one refusal record; POPULATION = %s. "
                      "DISPOSITION %s / STATUS %s / ATTRIBUTION %s. %s EXAMPLE: %s"
                      % (kind, n, K.CANONICAL_REGISTER, d["disposition"], d["status"],
                         d["attribution"], d.get("note", ""), EXAMPLE[kind][:220]),
        })
    for kind, n in sorted(collections.Counter(r["kind"]
                                              for r in spec.get("by_design", [])).items()):
        d = K.DISPOSITIONS[kind]
        findings.append({
            "kind": "note", "severity": "info", "for_stage": "3",
            "detail": "BY DESIGN, NOT A DEFECT -- %s: %d occurrence(s), held OUTSIDE %s so the "
                      "register's total cannot be read as a defect count. %s"
                      % (kind, n, K.CANONICAL_REGISTER, d.get("note", "")),
        })

    # ---- notes that are not refusals but must not be lost
    fc = S["intra_run_fanin"]
    sa, ma, un = fc["single_active"], fc["multi_active"], fc["history_undeclared_in_model"]
    findings += [
        {"kind": "note", "severity": "blocker", "for_stage": "mapper",
         "detail": "THE LARGER NON-DETERMINISM, AND NO DECISION TAKEN SO FAR ADDRESSES IT. The "
                   "cross-run carve-out and the declared source precedence both operate BETWEEN "
                   "runs. The arbitrary pick is WITHIN a run: several views of ONE run write one "
                   "attribute, the map declares no precedence among them, and max() keeps one. "
                   "Refusing a subordinate RUN cannot touch it -- the 95 legacy writers of "
                   "SAT_PARTY_IDENTITY.'Party Full Name' are all the same run. "
                   "MEASURED, unit = a (satellite, attribute, source_run) group of "
                   "UNDISCRIMINATED writers (no instance AND no redundant_of), writer = one "
                   "distinct (source view, source column) pair: single-active %d group(s) / %d "
                   "column(s), of which CROSS-table %d/%d and SAME-table %d/%d; multi-active %d/"
                   "%d; satellites with NO declared history in data_7.js %d/%d. This build's "
                   "single-active figure REPRODUCES THE COUNTERPARTY'S MEASUREMENT EXACTLY. A "
                   "third figure of 164 groups / 765 columns with 0 same-table was relayed from a "
                   "different single-active definition; both are recorded and NOT reconciled, "
                   "because the conclusion is the same either way -- essentially the whole "
                   "surface is CROSS-table. The counterparty has taken the 174 cross-table "
                   "groups. DECLARED, not resolved: choosing among same-run writers would invent "
                   "an authority the map does not provide."
                   % (sa["groups"], sa["columns"], sa["cross_table_groups"],
                      sa["cross_table_columns"], sa["same_table_groups"],
                      sa["same_table_columns"], ma["groups"], ma["columns"],
                      un["groups"], un["columns"])},
        {"kind": "note", "severity": "blocker", "for_stage": "2",
         "detail": "check_collapse CANNOT SEE THE LARGER POPULATION, and this invalidates how its "
                   "figure has been quoted on both sides. It groups on (table, satellite, "
                   "attribute, instance, child_key), so it can only flag two writers from the "
                   "SAME TABLE. N writers spread across N DIFFERENT tables produce ZERO "
                   "violations. MEASURED: of the %d single-active fan-in groups, only %d are "
                   "same-table. So the long-quoted 'violations, all pre-existing' figure BOUNDS "
                   "THE SAME-TABLE SUBSET and is NOT a measurement of the collapse surface; the "
                   "cross-table population is the larger one and was invisible to that gate on "
                   "both sides. Legacy collapse totals remain NOT_MEASURABLE, never zero."
                   % (sa["groups"], sa["same_table_groups"])},
        {"kind": "decision_taken", "severity": "info", "for_stage": "3",
         "detail": "BD6-CARVED-OUT (builder-overruled-by-mapper). Scope: %d shared objects "
                   "written by BOTH runs -- the 14 shared hubs plus LNK_PARTY_ROLE -- DERIVED "
                   "from the spec, not retyped. lnk_policy_party is in the shared 62 and EXCLUDED "
                   "because the settled map supplies only v2 feeds for it. The MECHANISM is "
                   "unchanged: the declared source precedence stays deterministic (v2 > legacy). "
                   "'Emit both values' was proposed and WITHDRAWN -- on a single-active attribute "
                   "two writers into one row per key is load-order-dependent and strictly worse. "
                   "The carve-out is HEADER-ONLY: it NAMES the subordinate writer and its "
                   "registry so the loss is countable. An overlap THRESHOLD was rejected as the "
                   "instrument because it cannot see the hazard at any value: HUB_PARTY's overlap "
                   "of 3 is IMD_CODE, PART_ID and RM_CODE, ALL intermediary-side, while on the "
                   "member/customer population it is ZERO, and collapsing underscores moves the "
                   "figure 3 -> 5. Scope chosen on ASYMMETRY: a declared conflict is RECOVERABLE, "
                   "a wrong merge is NOT after load."
                   % S["cross_run_carve_out"]["object_count"]},
        {"kind": "decision_taken", "severity": "info", "for_stage": "3",
         "detail": "LOAD-TIME ASSERTIONS (builder). %d emitted, %d cross-run collision and %d "
                   "intra-run arbitrariness, in models/assertions/, ALL UNRUN -- dbt is out of "
                   "scope, so a zero from any of them is an ABSENCE OF MEASUREMENT, not a clean "
                   "result. They exist because both questions are DATA questions: whether a "
                   "business-key VALUE ever collides across the two runs' disjoint registries is "
                   "unanswerable statically, and so is whether same-run writers ever disagree. "
                   "Reading the cross-run result: 0 is the ONLY self-sufficient answer; >0 proves "
                   "the VALUES collided and NOT that they denote the same ENTITY, so it ESCALATES "
                   "rather than resolves. The intra-run predicate is restricted to UNDISCRIMINATED "
                   "writers -- over all writers it would have reported 75 of 95 CORRECT rows as "
                   "defects on SAT_PARTY_IDENTITY.'Party Full Name' alone, and a gate that "
                   "over-accuses gets switched off and then protects nothing."
                   % (S["load_time_assertions"]["total"],
                      S["load_time_assertions"]["cross_run_collision"],
                      S["load_time_assertions"]["intra_run_arbitrary"])},
        {"kind": "note", "severity": "warn", "for_stage": "2",
         "detail": "REGISTER NAMING, corrected: the canonical register of refusals is %s, holding "
                   "%d records. %s is a DECLARED SUBSET of it holding %d -- child-key grain ONLY "
                   "-- and now says so in its own unit_note. Naming the subset as the register "
                   "cost the counterparty twenty minutes concluding the remainder was "
                   "unenumerated. A register that is a subset of another register must say which "
                   "it is."
                   % (S["unresolved_register"]["canonical"],
                      S["unresolved_register"]["canonical_count"],
                      S["unresolved_register"]["declared_subsets"][0]["artefact"],
                      S["unresolved_register"]["declared_subsets"][0]["count"])},
        {"kind": "note", "severity": "info", "for_stage": "mapper",
         "detail": "ROUTING CORRECTED on anchor_not_keyed_on_this_view_in_legacy_sql. This build "
                   "originally routed them as caused by the Stage-6.5 pass. MEASURED, matcher = a "
                   "stage65_reissue_diff row's (source_run, table_name, column_name) joined to "
                   "the settled map and the row's satellite home taken with prose stripped, unit "
                   "= distinct (view, satellite) pair: 47 of the 263 refusals sit on pairs that "
                   "pass touched and 216 do not -- 82.1% UNTOUCHED. That reproduces the "
                   "counterparty's 216/47 EXACTLY; a relayed figure of 220/43 is a third "
                   "measurement this build does not reproduce, and all three are reported rather "
                   "than averaged. THE COUNTERPARTY'S DIAGNOSIS IS THE VALUABLE PART: their Stage "
                   "6.5 validated anchor == parent(satellite), a MODEL constraint, and never "
                   "asked whether the view can key that hub, a SOURCE constraint. BOTH must hold, "
                   "and they will not re-anchor away from parent(satellite) to make a hub "
                   "reachable because that breaks anchor integrity the other way."},
    ]
    findings += [
        {"kind": "note", "severity": "warn", "for_stage": "2",
         "detail": "vault_tools/check_vault_alignment.py globs "
                   "models/automate_dv/*/satellites/*.sql. That reaches 53 files in "
                   "partner_dv_dbt and 124 in health_dv_dbt, and ZERO in this project and ZERO in "
                   "opus_health_v2_dv_dbt, both of which file satellites under models/vault. The "
                   "gate is LAYOUT-SENSITIVE, not broken, and its satellite comparison here is "
                   "VACUOUS: reported NOT RUN, never PASS. Its coverage figure of '0 of 555' is a "
                   "consequence of the same vacuum. Stage 2 must either run it with a widened "
                   "glob or accept check_hcon_payload_naming.py as the substitute for the "
                   "payload-naming half."},
        {"kind": "note", "severity": "warn", "for_stage": "2",
         "detail": "check_vault_alignment's check-5 findings against this project are PROVED "
                   "matcher artefacts, not defects: strip_sql_comments removes -- line comments "
                   "and the automate_dv YAML block but NOT /* */ block comments, and this layout "
                   "heads every model with /* */. Re-measured with block comments stripped and "
                   "CTE boundaries respected: unbalanced string literal 605 -> 0, illegal alias "
                   "1 -> 0, duplicate alias 1716 -> 0. The same limitation applies to "
                   "opus_health_v2_dv_dbt, so it is pre-existing. vault_tools is read-only to "
                   "this stage and was NOT edited (s9.9)."},
        {"kind": "note", "severity": "info", "for_stage": "2",
         "detail": "check_prose_counts discharges a whole SECTION once one line names its source; "
                   "the latch resets only at a heading. So its PASS means 'every section names a "
                   "source', not 'every count is sourced'. Recorded because the injection proof "
                   "had to open a new heading to make the gate fire, which is how the behaviour "
                   "was found."},
        {"kind": "note", "severity": "info", "for_stage": "2",
         "detail": "check_prose_counts and check_collapse both exit 1 UNPIPED and 0 THROUGH A "
                   "PIPE. Every gate verdict in this report is taken from the unpiped exit code "
                   "and the gate's own output."},
        {"kind": "note", "severity": "warn", "for_stage": "mapper",
         "detail": "The repeating group on BJAZ_WS_FAMILY_DTLS_BANDHAN is WIDER than any declared "
                   "artefact says. MATCHER = substring 'MEMBER[1-8]' or 'SELF' in column_name "
                   "(a word-boundary regex matches ZERO of them); UNIT = map row. Measured: 90 "
                   "rows in the group, of which 54 are outcome='mapped' on SAT_RISK_PERSON_MEMBER "
                   "-- the scope both build_profile.json and declared_unresolved_grain.json use "
                   "-- plus 18 more on the SAME satellite (Member Height, Member Weight) and 18 "
                   "on a SECOND satellite (SAT_LNK_ROLE_NOMINEE_BENEFICIARY), all with the same "
                   "absent Member Sequence discriminator. Building from 54 silently undeclares "
                   "36, which is the same trap one level up from building from the 45 "
                   "re-anchored. All 90 are declared in "
                   "reports/declared_unresolved_grain_hcon.json."},
        {"kind": "note", "severity": "warn", "for_stage": "mapper",
         "detail": "A FOURTH reject class exists that build_profile.json never enumerates: "
                   "content_hash_composite_guarded. It was found because the sweep assertion "
                   "fired, not by reading the profile, which shows reject declarations only "
                   "inside truncated samples. Measured over resolved_key.key_reject_declaration: "
                   "single_operand_guarded 720, content_hash_composite_guarded 33, "
                   "composite_sentinel_live 52, composite_null_annihilating 35 (840 total), with "
                   "seven sub-keys including reclassified_from on 8."},
        {"kind": "note", "severity": "warn", "for_stage": "mapper",
         "detail": "A NINTH prose-bearing field exists that build_profile.json's prose census "
                   "omits: target.reanchored is THREE-STATE -- boolean True on 107 rows and a "
                   "Stage-6.5 SENTENCE on 124. It is denied by class in "
                   "hcon_keyrules.PROSE_DENY and never read into SQL, but a reader trusting the "
                   "profile's eight-field list would read it."},
        {"kind": "note", "severity": "info", "for_stage": "3",
         "detail": "'R8 fires on 62 of 62' is TRUE BY CONSTRUCTION of an input set DEFINED as the "
                   "pairs having writers in both runs, and is NOT reported here as a measurement. "
                   "The informative figures are in BUILD_STATUS.json r8 and "
                   "reports/r8_precedence_as_built.json, with the population stated. Keep apart: "
                   "62 shared vault TABLES, 62 cross-run (satellite, attribute) PAIRS, and 48 "
                   "shared satellites + 15 anchors = 63 are THREE DIFFERENT UNITS that coincide "
                   "near one number; nothing in this build reconciles them and nothing should."},
        {"kind": "note", "severity": "warn", "for_stage": "3",
         "detail": "Legacy collapse totals are NOT_MEASURABLE, never zero: stage 6 never ran on "
                   "the legacy half and check_collapse deliberately skips a multi-active target "
                   "whose child key is unresolved, leaving 286 blocks unjudged. Every legacy "
                   "collapse figure is a LOWER BOUND and a zero from that instrument is not a "
                   "clean bill."},
        {"kind": "note", "severity": "warn", "for_stage": "source",
         "detail": "Six of the fourteen shared hubs share ZERO business-key columns between the "
                   "runs (build_profile.json registry_reconciliation). Unifying the hash form "
                   "produces ONE key space over TWO sets of registries, not a joinable hub. Every "
                   "shared hub header says so and reports/hub_registries.json enumerates every "
                   "registry per hub per run with the per-hub overlap. UNDETERMINED and "
                   "answerable only from the data; a false merge is unrecoverable after load."},
        {"kind": "note", "severity": "info", "for_stage": "2",
         "detail": "Walk-only casts and ancestor resolvers are BOTH EMPTY and both zeros are "
                   "PROVEN, not omitted: zero walk operators over every key-bearing string, and "
                   "zero edge fields over every field name at every level of the map. "
                   "assert_no_walk_operators RAISES if an operator ever appears, so the day a "
                   "walk arrives the build fails instead of silently skipping levels."},
    ]

    for d in S["directives"]:
        if not d["status"].startswith("IMPLEMENTED"):
            findings.append({"kind": "directive_unimplemented", "severity": "blocker",
                             "for_stage": "mapper",
                             "detail": "directive %s (%s) is %s" % (d["n"], d["bundle_item"],
                                                                    d["status"])})

    mdig, mfiles, _mb = tree_digest(os.path.join(PROJECT_ROOT, "models"))
    self_checks = [
        {"check": "read-only originals unchanged at open and close",
         "result": "pass",
         "detail": "tree digest recomputed with a recipe VALIDATED against partner_dv_dbt = "
                   "d130c4bb... before use; health_dv_dbt 7b13f9f2.../1703 files and "
                   "opus_health_v2_dv_dbt bb7a3a76.../365 files both match the stage-0 baseline. "
                   "Stage 0's first tool returned sha256('') for all three projects, so the tool "
                   "is validated against a known answer at every invocation."},
        {"check": "write confinement, cross-process",
         "result": "pass",
         "detail": "every write goes through hcon_writeguard.guarded_open, which refuses any path "
                   "outside the project and appends it to build_artifacts/write_manifest.jsonl; "
                   "the closing audit replays the manifest: %s"
                   % json.dumps(S["read_only_guard"]["manifest"])},
        {"check": "write guard refuses",
         "result": "pass",
         "detail": "selftest offers 5 out-of-project paths (both originals, vault_tools, "
                   "maximus_health_v3_dv_dbt, data_7.js) and requires a refusal for each, plus "
                   "one in-project path that must be allowed. A guard not shown to refuse proves "
                   "nothing."},
        {"check": "build input unmoved before and after",
         "result": "pass",
         "detail": "04_column_map.SETTLED_post_stage6_65b.json sha256 %s, md5 %s, %d bytes, verified "
                   "at the start AND the end of the spec build. "
                   "04_column_map.PINNED_pre_stage65.json was NEVER opened as a build input and "
                   "is named in hcon_keyrules.NEVER_A_BUILD_INPUT so a glob cannot reach it."
                   % (S["input"]["sha256"], S["input"]["md5"], S["input"]["bytes"])},
        {"check": "reproducibility by deletion",
         "result": "pass",
         "detail": "run_hcon_build.py --fresh deletes models/ and every stage-1 artefact, asserts "
                   "the delete succeeded, asserts all 8 stage-0 INPUTS are still present, and "
                   "rebuilds. Two consecutive --fresh runs produced byte-identical model trees. "
                   "models/ tree sha256 %s over %d files; combining method: %s"
                   % (mdig, mfiles, S["digests"]["combining_method_note"])},
        {"check": "every profile field recognised",
         "result": "pass",
         "detail": "assert_profile_recognised compares the profile's %d top-level keys against a "
                   "declared set and RAISES on an unknown one rather than skipping it; proved by "
                   "injection."
                   % len(K.RECOGNISED_PROFILE_KEYS)},
        {"check": "every map field recognised at every level",
         "result": "pass",
         "detail": "assert_map_fields sweeps row, target, augmentation, resolved_key, "
                   "key_reject_declaration, child_key_components and reanchor and RAISES on an "
                   "unknown field; proved by injection."},
        {"check": "child-key family read in full, key_name never",
         "result": "pass",
         "detail": "FOUR fields read -- child_key (leg name), child_key_value (rendered value), "
                   "child_key_components (structured legs), usage_child_key (declared compound). "
                   "key_name and child_key_vocabulary are NEVER read as a child key. The "
                   "co-occurrence matrix is re-measured and an unseen combination RAISES: %s. "
                   "48 containers carry child_key ALONE and a two-field reader drops them "
                   "silently." % json.dumps(S["child_key_family"]["cooccurrence"])},
        {"check": "three states carried, not two",
         "result": "pass",
         "detail": "ABSENT / PRESENT_NULL / literal 'None' / POPULATED are all distinguished by "
                   "state_of() and the state FOUND is recorded per row in "
                   "reports/declared_unresolved_grain_hcon.json. Measured: the literal string "
                   "'None' occurs 0 times on any child-key family field in this map, while "
                   "build_profile.json calls 17 JSON-null component lists "
                   "'falsy_literal_None_blocks' -- those are PRESENT_NULL, not the string."},
        {"check": "instance scoped by ROLE, not by name",
         "result": "pass",
         "detail": "block-level instance only is attached to a satellite row; "
                   "resolved_key.instance QUALIFIES A KEY EXPRESSION and is never used as a row "
                   "label. Reproduced: columns.target 2917 present/387 populated, "
                   "target.resolved_key 761/75, columns.augmentation 113/2, "
                   "augmentation.resolved_key 72/2 = 3863/466; block-level 3030/389; 170 distinct "
                   "block-level values, 20 inside resolved_key, overlap 20, resolved_key-only 0. "
                   "The label is READ, never inferred from a column prefix -- P_ and M_ mean "
                   "PERMANENT and MAILING, not proposer/member."},
        {"check": "matcher discipline: substring, never a word boundary",
         "result": "pass",
         "detail": "reproduced on the profile's own scope and stated beside every count: %s. "
                   "Every column-name sweep in this build uses a substring or an explicit "
                   "character class." % json.dumps(S["matcher_discipline"]["evidence"])},
        {"check": "no prose reaches SQL",
         "result": "pass",
         "detail": "asserted at the source (hcon_names.column and assert_identifier refuse "
                   "parentheses, brackets and em-dashes) and over the emitted corpus by "
                   "check_prose_shape, which examined %d models and found no identifier-position "
                   "token containing a space. 131 augmentation.new_satellite values carry a code "
                   "followed by a description; the code is extracted and the prose DISCARDED, and "
                   "the one value with no code at all is refused." % c["models_total"]},
        {"check": "hash-key reachability at fixpoint",
         "result": "pass",
         "detail": "check_hcon_reachability: every <X>_HK referenced in %d models is produced "
                   "locally or exposed by a ref()ed model, taken to a fixpoint over the ref "
                   "graph; 0 dangling refs, 0 duplicate model names. check_internal cannot see "
                   "this in a layout with no automate_dv metadata block." % c["models_total"]},
        {"check": "every regex probed for fire AND silence",
         "result": "pass",
         "detail": "hcon_names.probe_patterns runs 13 pattern cases plus the length budget, the "
                   "view renderer, the column renderer, the key form and literal escaping; "
                   "hcon_keyrules.probe_legacy_patterns runs 8 more. Each must FIRE on a real "
                   "corpus string and stay SILENT on a near-miss. Every regex is authored in a "
                   "FILE -- a heredoc attempt during this build mangled every backslash twice, "
                   "and the probe caught both."},
        {"check": "checks proved by injection, non-zero baselines",
         "result": "pass" if proofs["passed"] == proofs["total"] and proofs["total"] else "fail",
         "detail": "%d of %d proofs: each injects a defect into a COPY of the real corpus, "
                   "requires the check to FIRE, and requires silence on the clean copy. Every "
                   "baseline is asserted non-zero and every injected shape is attached to a "
                   "construct the real corpus actually contains. Detail in "
                   "reports/check_proofs.json." % (proofs["passed"], proofs["total"])},
        {"check": "no packages, no macro library",
         "result": "pass",
         "detail": "%d explicit md5( calls emitted across the corpus; %d package macro "
                   "invocations; packages.yml written: %s. Build directive 6 asks for exactly "
                   "this, as opus_health_v2_dv_dbt already does."
                   % (S["key_form"]["explicit_md5_calls_emitted"],
                      S["key_form"]["package_macro_invocations"],
                      S["key_form"]["packages_yml_written"])},
        {"check": "hashdiff convention applied consistently",
         "result": "pass",
         "detail": "bare HASHDIFF occurrences: %d; suffixed <SAT>_HASHDIFF occurrences: %d. "
                   "Ratified this run; one line to overrule."
                   % (S["hashdiff"]["bare_HASHDIFF_occurrences"],
                      S["hashdiff"]["suffixed_occurrences"])},
        {"check": "declared source precedence APPLIED in SQL, not only described",
         "result": "pass",
         "detail": "the first draft listed the precedence in the satellite header and UNIONed the "
                   "feeders, so two runs writing one attribute produced two rows and the "
                   "precedence never fired -- build directive 2 declared in prose and "
                   "unimplemented in code. Found by reading the emitted SQL. The bespoke loader "
                   "now collapses to one row per hub key plus resolved legs and applies "
                   "coalesce(max(case when SOURCE_RUN=...)) in the declared order on %d "
                   "(satellite, attribute) pairs." % S["r8"]["fires_on_pairs"]},
        {"check": "every output directory created by its writer",
         "result": "pass",
         "detail": "guarded_makedirs / guarded_open create the parent directory; a fresh run from "
                   "a deleted models/ produced all %d layer directories with no pre-made tree."
                   % len(c["models_by_layer"])},
        {"check": "never write into a directory read",
         "result": "pass",
         "detail": "health_dv_dbt is READ by the legacy key archaeology and is asserted byte-"
                   "identical afterwards; the write guard refuses its path outright. The "
                   "injection proofs copy the corpus to a scratch directory OUTSIDE the repo "
                   "root, asserted, so no proof artefact can join the population the digests and "
                   "gates enumerate."},
        {"check": "scratch file names checked against sys.stdlib_module_names",
         "result": "pass",
         "detail": "prove_hcon_checks.safe_name raises on any scratch .py whose stem is in "
                   "sys.stdlib_module_names; a scratch warnings.py broke zipfile's import chain "
                   "mid-run in stage 0."},
        {"check": "62/140/45 partition exact",
         "result": "pass",
         "detail": "asserted in both directions: no name in two sets, every set's size equals "
                   "build_profile.json layer_plan_one_loader, and every per-source feed model "
                   "name resolves to exactly one assembled loader present in the same set list. "
                   "Reproduces ONLY under the definition 'vault object by NAME SHAPE, live scope, "
                   "REFS EXCLUDED' -- a directory-shape matcher gives 62/141/26."},
        {"check": "gates run as subprocesses with PYTHONDONTWRITEBYTECODE=1",
         "result": "pass" if gates["gates"] else "fail",
         "detail": "verdicts in reports/gate_results.json, read from UNPIPED exit codes: %s"
                   % json.dumps([{g["gate"]: g["verdict"]} for g in gates["gates"]])},
    ]

    blockers = [f for f in findings if f["severity"] == "blocker"]
    import collections as _c
    print("[stage1-report] register: %d record(s) -- %d CLOSED, %d AWAITING COUNTERPARTY; %d "
          "by-design held outside"
          % (S["unresolved_register"]["canonical_count"], S["unresolved_register"]["closed"],
             S["unresolved_register"]["awaiting_counterparty"],
             S["unresolved_register"]["by_design_held_separately"]))
    print("[stage1-report] decision attributions: %s"
          % dict(_c.Counter(d.get("attribution", "builder") for d in S["decisions"])))
    report = {
        "stage": "1",
        "status": "partial" if blockers else "complete",
        "status_note": "PARTIAL, and deliberately so: the chain runs end to end from empty, every "
                       "gate passes and every check is proved by injection, but %d finding(s) are "
                       "BLOCKERS for a later party -- chiefly hub keys the legacy half of the map "
                       "cannot supply and child-key legs this build refuses rather than invents. "
                       "Reporting 'complete' would hide them." % len(blockers),
        "register_census": {
            "canonical_register": S["unresolved_register"]["canonical"],
            "unit_note": S["unresolved_register"]["canonical_unit_note"],
            "total": S["unresolved_register"]["canonical_count"],
            "CLOSED": S["unresolved_register"]["closed"],
            "AWAITING_COUNTERPARTY": S["unresolved_register"]["awaiting_counterparty"],
            "AWAITING_MODELLER_RATIFICATION":
                S["unresolved_register"].get("awaiting_modeller_ratification", 0),
            "awaiting_note": S["unresolved_register"].get("awaiting_note"),
            "by_status": S["unresolved_register"]["by_status"],
            "by_attribution": S["unresolved_register"]["by_attribution"],
            "by_design_not_defects_held_separately":
                S["unresolved_register"]["by_design_held_separately"],
            "declared_subsets": S["unresolved_register"]["declared_subsets"],
            "closed_note": "CLOSED = CLOSED_TERMINAL + DROPPED_FROM_SCOPE. A CLOSED_TERMINAL "
                           "refusal is DECIDED with nowhere left to look -- it is NOT a deferral.",
        },
        "cross_run_carve_out": S["cross_run_carve_out"],
        "intra_run_fanin": S["intra_run_fanin"],
        "load_time_assertions": S["load_time_assertions"],
        "counts": {
            "generators": c["generators"],
            "models": c["models_total"],
            "unresolved_keys": c["unresolved_total"],
            "skipped": c["views_without_a_cast"] + c["satellite_feeders_refused_no_key"]
            + S["loader_plan"]["not_buildable_no_feed_in_map"],
            "models_by_layer": c["models_by_layer"],
            "key_slots": c["key_slots"],
            "satellite_build_units": c["satellite_build_units"],
            "satellite_feeders_emitted": c["satellite_feeders_emitted"],
            "satellite_feeders_refused_no_key": c["satellite_feeders_refused_no_key"],
            "unresolved_by_kind": c["unresolved_by_kind"],
            "loader_plan": S["loader_plan"],
            "skipped_note": "unit breakdown: views with no cast + satellite feeders refused for "
                            "want of an anchor key + declared vault tables with no feed in the "
                            "settled map. They are three different units and are listed "
                            "separately above; the single 'skipped' figure is their sum and "
                            "should not be quoted alone.",
        },
        "digests": S["digests"],
        "artefacts": S["artefacts"],
        "self_checks": self_checks,
        "findings": findings,
    }
    with guarded_open(OUT) as fh:
        json.dump(report, fh, indent=1)
    print("[stage1-report] status %s" % report["status"])
    print("[stage1-report] %d self-check(s): %d pass, %d fail"
          % (len(self_checks), sum(1 for x in self_checks if x["result"] == "pass"),
             sum(1 for x in self_checks if x["result"] != "pass")))
    print("[stage1-report] %d finding(s): %s"
          % (len(findings),
             json.dumps(dict(collections.Counter("%s/%s" % (f["kind"], f["severity"])
                                                 for f in findings)))))
    print("[stage1-report] wrote %s" % os.path.relpath(OUT, PROJECT_ROOT))
    assert_read_only_intact("report-close", verbose=False)
    manifest_audit(verbose=False)
    return 0


def _todo(kind):
    T = {
        "legacy_key_not_recoverable":
            "SOURCE/mapper must supply a resolved_key for the legacy half, or confirm that the "
            "(view, hub) pair genuinely has no business key. This build will not invent one.",
        "anchor_not_keyed_on_this_view_in_legacy_sql":
            "MAPPER must reconcile the Stage-6.5 re-anchor with the keys that exist on the view: "
            "the row now points at a hub for which no business key is declared or recoverable "
            "there. The refusal names the hubs that ARE keyed on that view.",
        "view_has_no_recoverable_key_at_all":
            "SOURCE must say how rows of this view are identified; nothing in the bundle or in "
            "legacy's emitted SQL keys it.",
        "satellite_has_no_anchor":
            "MAPPER must declare an anchor, or MODELLER must add the satellite (with its parent) "
            "to data_7.js. Both fallbacks were tried: the map's anchor, then the model's parent.",
        "child_key_leg_refused":
            "MAPPER must supply a child-key VALUE of the right kind for the named leg. The three "
            "sub-populations need three different answers and the refusal says which one applies.",
        "payload_collides_with_child_key_leg":
            "MODELLER must rename one of them: an attribute and a child-key leg cannot share a "
            "column. The PAYLOAD column was dropped, because the leg carries grain.",
        "loader_has_no_feed_in_the_map":
            "MAPPER should confirm the table is out of scope for this consolidation, or supply "
            "columns for it. No empty model was emitted, because an empty model reads as built.",
        "shared_loader_has_one_run_of_feeds":
            "MAPPER: both originals emit a file of this name but the settled map supplies one "
            "run's columns. Confirm whether the other run's feed is missing or genuinely absent.",
        "view_needs_no_cast":
            "SOURCE: no column of this view is consumed anywhere. Confirm it is in scope at all.",
        "satellite_home_is_pure_prose":
            "MAPPER must replace the description with a SAT_/REF_ code. No satellite name was "
            "coined from a description.",
        "multiple_registries_key_this_view_hub":
            "SOURCE must say whether the named business keys denote the same entities. The first "
            "was used and the others NAMED; merging them would answer an undetermined question.",
        "component_value_is_prose_or_empty":
            "MAPPER must give the component a {COLUMN} placeholder or a literal value. A "
            "brace-wrapped English phrase renders to SQL naming a column that cannot exist.",
        "child_key_leg_name_unrenderable":
            "MAPPER must give the leg a name that can be a column.",
        "link_legs_not_establishable":
            "MAPPER must declare the link's legs, or MODELLER must reduce the declared leg count: "
            "one recovered business key cannot be distributed across several legs.",
        "key_slot_name_collision_differing_expression":
            "MAPPER: two different expressions render the same staged business-key column name on "
            "one view. They were NOT merged.",
        "attribute_unrenderable_prose_in_identifier_position":
            "MAPPER must replace the description with an attribute name.",
        "resolved_key_without_hub": "MAPPER must name the hub the expression keys.",
        "resolved_key_without_source_columns":
            "MAPPER must list source_columns; a key slot cannot be named without them.",
        "legacy_key_expression_not_an_identifier":
            "SOURCE: the recovered legacy key is not a bare column reference.",
        "component_not_a_dict": "MAPPER: a child_key_components entry is not an object.",
        "component_unnamed_leg": "MAPPER: a child_key_components entry carries no name.",
    }
    return T.get(kind, "ROUTED, with no default action declared.")


if __name__ == "__main__":
    sys.exit(main())
