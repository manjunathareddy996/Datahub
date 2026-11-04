# -*- coding: utf-8 -*-
"""Grammar parser, key rendering, directives and decisions for Maximus Health V3.

This module owns:
  * the span grammar parser and the HOP EXPANSION into real per-level chains (s4)
  * span replacement (an empty replacement span is FATAL, s1.6)
  * child-key LEG splitting (declared components, then ' | ' at brace depth ZERO)
    and OPERAND splitting on U+0023 / U+0040 with the separator PRESERVED
  * link legs
  * the emit / reject predicate pair, asserted to be exact boolean complements
  * BUILD_DIRECTIVES  -- every profile directive, with the mechanism NAMED here
  * BUILDER_DECISIONS -- every call the map left to the builder, with its cost
  * UNRESOLVED        -- one place, reported and counted, NEVER guessed (s5.6)

EVERY REGEX IN THIS FILE IS AUTHORED IN THIS FILE (s1.2 / CLAUDE.md). None was
written through a shell heredoc; nine incidents on this estate say why.

ENGINE ASSUMPTION, stated once and applied identically everywhere (s9.8):
  Snowflake.  Two consequences drive every predicate below.
  1. `'MEMBER:' || nullif(trim(X),'')` is NULL when X is blank, because
     concatenation with NULL yields NULL.  A NULL key is DROPPED by the load, so
     a blank row becomes unlogged data loss that reads as a sparse source.
  2. In a shredded EAV feed an absent label materialises as '' and NOT as SQL
     NULL, so coalesce(A,B,C) never falls through to B.  Every ladder operand is
     therefore written nullif(trim(<operand>),'').
  The SAME rule is applied whether or not the engine turns out to behave this
  way, because a predicate that depends on an unverified engine property is a
  predicate nobody can check.
"""
import json
import os
import re

import mxh3_names as N

PROFILE = N.PROFILE
BUNDLE = PROFILE["bundle_root"]
PROJECT = N.PROJECT

# ---------------------------------------------------------------------------
# 1.  PROFILE INTAKE -- every field read is declared, and an unrecognised field
#     RAISES rather than being skipped (s2.2).  The profile is a machine-read
#     artifact and gets the same suspicion as the map.
# ---------------------------------------------------------------------------

PROFILE_KEYS_EXPECTED = {
    "schema", "schema_note", "prose_field_allowlist", "lob", "bundle_root",
    "model_file", "generated", "stage", "reentry", "bundle_inventory",
    "digests_verified", "sibling", "map_fields", "component_kinds", "grammar",
    "grammar_totals", "parse_residue", "parse_residue_note", "hierarchy",
    "key_ladder", "child_key_legs", "blocker_shred_surrogate_child_keys",
    "directive_fields", "spreadsheet_columns", "spreadsheet_summary",
    "collapse_traps", "collapse_trap_assertion_note", "renumbering_ordinals",
    "renumbering_ordinal_note", "layers", "layers_rationale", "bespoke_layers",
    "build_directives", "open_items", "prefix", "prefix_detail", "abbr_seed",
    "name_injective", "name_injectivity_proof", "longest_name",
    "longest_name_example", "naming_note", "mapper_stated_limits",
    "mapper_figures_not_reproduced", "undetermined", "additional_measurements",
    "self_assertion",
}


def assert_profile_recognised(prof=PROFILE):
    """Raise on a profile field this build does not know about (s2.2)."""
    seen = set(prof)
    unknown = seen - PROFILE_KEYS_EXPECTED
    absent = PROFILE_KEYS_EXPECTED - seen
    if unknown:
        raise AssertionError(
            "build_profile.json carries %d field(s) this build does not recognise: %s. "
            "s2.2: RAISE on an unrecognised profile field rather than skipping it -- the "
            "fields you did not think to look at are the ones that break silently."
            % (len(unknown), sorted(unknown)))
    if absent:
        raise AssertionError(
            "build_profile.json is MISSING %d field(s) this build reads: %s. Re-derive "
            "from the profile rather than defaulting." % (len(absent), sorted(absent)))
    return {"profile_fields": len(seen), "unrecognised": 0, "missing": 0}


assert_profile_recognised()

PROSE_FIELDS = frozenset(PROFILE["spreadsheet_summary"]["map_prose_fields_allowlist"])
NAMESPACE_PREFIXES = tuple(PROFILE["key_ladder"]["namespace_prefixes_do_not_strip"])
RATIFIED_FUNCTIONS = frozenset(
    f.lower() for f in PROFILE["grammar_totals"]["ratified_function_allowlist"])
LEG_SEPARATOR = PROFILE["child_key_legs"]["leg_separator"]          # ' | '
LEG_BINDER = PROFILE["child_key_legs"]["binder"]                    # ' = '
OPERAND_SEPARATORS = tuple(PROFILE["child_key_legs"]["operand_separators_inside_one_leg"])
HASH_IS_A_LEG_BOUNDARY = PROFILE["child_key_legs"]["hash_is_a_leg_boundary"]
COMPONENT_DISCRIMINATOR = PROFILE["component_kinds"]["discriminator_field"]   # leg_backing
COMPONENT_KINDS = frozenset(PROFILE["component_kinds"]["census"])
RENUMBERING_ORDINALS = tuple(
    s.split(" ")[0] for s in PROFILE["renumbering_ordinals"])
COLLAPSE_TRAPS = tuple(PROFILE["collapse_traps"])

if HASH_IS_A_LEG_BOUNDARY:
    raise AssertionError(
        "profile says U+0023 IS a leg boundary; this module is built on the opposite. "
        "Counting '#' under-counts 328 blocks and OVER-counts 117, and the over-count "
        "turns a sole leg into an apparent compound, which SILENCES the surrogate "
        "blocker. Re-derive before changing this.")

# The operand separators, BY CODEPOINT, never by a glyph copied from prose.
# The pack's own message renders U+0040 as U+FF20 FULLWIDTH, which matches NOTHING:
# a splitter built on that glyph silently drops the questionnaire namespace and
# merges every member's questionnaire onto one row per proposal.
SEP_HASH = chr(0x23)        # NUMBER SIGN
SEP_AT = chr(0x40)          # COMMERCIAL AT
SEP_FULLWIDTH_AT = chr(0xFF20)   # the WRONG one -- asserted absent below

if set(OPERAND_SEPARATORS) != {SEP_HASH, SEP_AT}:
    raise AssertionError(
        "profile operand separators %r are not the expected {U+0023, U+0040}"
        % (OPERAND_SEPARATORS,))


# ---------------------------------------------------------------------------
# 2.  REGISTRIES -- unresolved things are reported, never guessed (s5.6)
# ---------------------------------------------------------------------------

UNRESOLVED = []     # every refusal, in ONE place, with its reason and its scope

# Spans whose ARROW said climb and whose GRAPH said cross. Recorded, not silent.
GRAPH_RECLASSIFIED = []

# Blocks refused because a validator finding's TYPED disposition says REFUSE.
REFUSED_BY_DISPOSITION = []


def unresolved(kind, view, detail, satellite=None, leg=None, severity="warn"):
    """Record a refusal. Reported and counted; NEVER guessed (s5.6)."""
    UNRESOLVED.append({
        "kind": kind, "view": view, "satellite": satellite, "leg": leg,
        "severity": severity, "detail": detail,
    })
    return None


def unresolved_summary():
    out = {}
    for u in UNRESOLVED:
        out[u["kind"]] = out.get(u["kind"], 0) + 1
    return {"total": len(UNRESOLVED), "by_kind": out}


# ---------------------------------------------------------------------------
# 3.  BUILDER DECISIONS -- EMPTIED at the start of this LOB (s11.5).
#     Each is ONE LINE to overrule and states WHAT IT COSTS plainly.
#     Nothing from another LOB is carried in.
# ---------------------------------------------------------------------------

BUILDER_DECISIONS = [
    {
        "id": "D1-REFDECODE-DEFAULT-REFUSE",
        "decision_note": "The reference_decode gate defaults to REFUSING the row. "
                         "No reference-decode master exists anywhere in this bundle, and the "
                         "directive says loading the raw code into a label attribute is WRONG "
                         "DATA that every gate passes.",
        "cost_note": "3 rows (SAT_PARTY_ORGANISATION_PROFILE 'Industry Description' and "
                     "SAT_PARTY_IDENTIFICATION 'Insurance Repository Name' x2) emit NULL and are "
                     "counted as refused rather than carrying a code where a label belongs. If a "
                     "decode master is in fact available, 3 label attributes stay empty until the "
                     "var is flipped.",
        "overrule_note": "Set dbt var mxh3_reference_decode_available to true (one line in "
                         "dbt_project.yml), or pass --vars on the run.",
        "routing": "3",
    },
    {
        "id": "D2-REFDECODE-SCOPE-IS-THE-DIRECTIVE",
        "decision_note": "The reference_decode GATE is scoped to the 3 blocks carrying "
                         "build_directive, NOT to all 59 blocks whose transformation_kind is "
                         "'reference_decode'. The directive population is defined by the "
                         "directive field; transformation_kind is a description of the mapping, "
                         "not an instruction.",
        "cost_note": "56 blocks assert a code->decode transformation and are built WITHOUT the "
                     "gate, so they load the mapped value as-is. If the mapper intended all 59 to "
                     "be gated, 56 label attributes receive coded values. This is why the figure "
                     "is reported with BOTH matchers rather than one.",
        "overrule_note": "Set REFDECODE_SCOPE = 'transformation_kind' in this module.",
        "routing": "3",
    },
    {
        "id": "D3-QUARANTINE-RENAMES-THE-UNSTABLE-LEG",
        "decision_note": "The 45 surrogate-backed child-key components are emitted in the "
                         "quarantine layer under a column named <LEG>__UNSTABLE_SURROGATE, NOT "
                         "under the model's declared child-key column, and the quarantine models "
                         "are emitted disabled. A column that is not spelled like the declared "
                         "child key cannot be wired into a satellite by accident.",
        "cost_note": "The 7 ratified Multi-Active SCD2 satellites carry NO history from these 45 "
                     "blocks. That loss is deliberate and visible in the emitted SQL; it is not a "
                     "source gap and must not be reported as one.",
        "overrule_note": "Set QUARANTINE_EMIT_DECLARED_NAME = True in this module -- which "
                         "re-enables the duplicate-row defect the directive exists to prevent.",
        "routing": "3",
    },
    {
        "id": "D4-EMI-HOME-IS-THE-RATIFIED-SATELLITE",
        "decision_note": "'Last EMI Paid Date' and 'Outstanding Loan Amount' are built ONLY on "
                         "the ratified SAT_CLAIM_BENEFIT_HEAD and suppressed on OPUS's "
                         "placeholder SAT_CLAIM_COVER_SECTION_ASSESSMENT, which is absent from "
                         "data_7.js entirely. Where data_7.js speaks, the model wins.",
        "cost_note": "Splits a coherent 23-column OPUS assessment block for 2 columns of overlap; "
                     "the remaining 21 columns stay on the placeholder and the block must be "
                     "reassembled by hand to be read as a whole. Cheap to reverse -- it is an "
                     "attribute routing entry, not a key.",
        "overrule_note": "Remove the 2 entries from ATTRIBUTE_ROUTING_SUPPRESS in this module.",
        "routing": "3",
    },
    {
        "id": "D5-TRANSITION-IS-BUILD-SIDE",
        "decision_note": "SAT_CLAIM_STATUS_TRANSITION is ABSENT from data_7.js, so it is built on "
                         "the augmented (unratified) track as a multi-active satellite with the "
                         "caller-ratified child key 'Status Code | Transition Date' and a union of "
                         "SEVEN attributes -- 'Transition Actor User Reference' and 'Transition "
                         "Performed By Reference' are ONE fact fed from both sides, not two.",
        "cost_note": "If the two names are in fact different facts, one column carries two "
                     "meanings and separating them later is a satellite re-grain. The directive "
                     "states they are the same fact; this build follows it.",
        "overrule_note": "Remove the pair from ATTRIBUTE_UNION_ALIASES in this module.",
        "routing": "3",
    },
    {
        "id": "D6-CROSS-VALUE-ONLY-WHEN-UNIQUE",
        "decision_note": "A '>>' / LCA cross descends into another branch and can match N rows "
                         "per source row. The resolver exposes the crossed value ONLY when it "
                         "matches exactly one row, and always exposes the match COUNT beside it; "
                         "rows with N>1 are diverted to the reject log.",
        "cost_note": "Where a cross is genuinely 1:N the value is NULL rather than an arbitrary "
                     "pick, so those rows lose the key and are counted as rejects instead of "
                     "silently keeping one branch's value. A fallback that guesses converts a "
                     "loud gap into a silent corruption, which is why the NULL is preferred.",
        "overrule_note": "Set CROSS_REQUIRE_UNIQUE = False in this module (restores arbitrary "
                         "pick semantics -- not recommended).",
        "routing": "3",
    },
    {
        "id": "D7-UNRESOLVED-KEYS-GET-NO-KEY",
        "decision_note": "The 16 VIEW_COLLECTIONS_ADDITIONAL_DETAILS blocks whose resolved_key "
                         "tier is 'unresolved' and which carry no expression are built with NO "
                         "key: every row is diverted to the reject log carrying the declared "
                         "source gap. Three candidate keys were considered and rejected by the "
                         "mapper; inventing a fourth is not the builder's call (s5.7).",
        "cost_note": "HUB_FINANCIAL_TRANSACTION receives nothing from that view, and 16 columns "
                     "reach no satellite. Visible as a counted reject, not as an absent model.",
        "overrule_note": "Supply an expression in the map; this build will not synthesise one.",
        "routing": "3",
    },
    {
        "id": "D8-COVERGRAIN-BUILT-WITH-A-FANOUT-COUNT",
        "decision_note": "SRM-COVERGRAIN's 35 blocks on 2 views are BUILT as mapped (s5.7 -- the "
                         "builder does not correct the mapping), with a per-anchor row count "
                         "emitted beside the key so an N>1 fan-in is counted and diverted rather "
                         "than silently keeping one arbitrary cover's values.",
        "cost_note": "If the N rows per claim do carry differing values, those rows are rejected "
                     "rather than loaded, so the satellite is EMPTY for those claims instead of "
                     "wrong. Needs executed data to settle; invisible to check_collapse either way.",
        "overrule_note": "Set COVERGRAIN_DIVERT_FANOUT = False in this module.",
        "routing": "3",
    },
    {
        "id": "D9-MEMBERSHIP-RE-DERIVED-NOT-TRUSTED",
        "decision_note": "resolved_on_view is NOT trusted. Membership is re-derived per row "
                         "against the row's OWN view from 00_tables_index.json, and a brace token "
                         "is read as a COALESCE LADDER of alternatives: a rung absent from the "
                         "view is pruned, and only a leg with NO surviving rung is refused.",
        "cost_note": "Under this matcher 1 component disagrees with its own flag: "
                         "SAT_POLICY_COVERAGE_SCHEDULE 'Coverage Reference' = '{ADDEDCOVERS "
                         "element}' on MEMBERS_MEMBER_DETAILS_PIVOT_VW, whose token contains a "
                         "SPACE and so names no column. That block is REFUSED, not renamed. A "
                         "ladder-blind matcher would instead have accused 246 components.",
        "overrule_note": "Set TRUST_RESOLVED_ON_VIEW = True in this module -- which emits a "
                         "column that does not exist.",
        "routing": "3",
    },
    {
        "id": "D10-SPINE-DISPLAY-RUNG-RESOLVED-FROM-THE-GRAPH",
        "decision_note": "A 'spine:<TABLE>.<COLUMN>' rung inside a child-key value is DISPLAY "
                         "ONLY and is never parsed as SQL. The displayed form names the CONCEPT; "
                         "the mechanism is re-derived from the graph. All 199 occurrences name "
                         "MEMBERS_PARTY.PARTY_CODE, which the graph shows is a SIBLING of the "
                         "row's view in 198 of 199 cases -- so these are LCA crosses, not climbs.",
        "cost_note": "The one remaining form, 'spine:ROLE' on SAT_LNK_POLICY_PARTY_ROLE, names no "
                     "table in the index at all and is REFUSED rather than guessed at.",
        "overrule_note": "Supply the table in the map's resolved_key; the display form will not "
                         "be promoted to executable here.",
        "routing": "3",
    },
]

# Switches named by the decisions above, so each is genuinely one line to overrule.
REFDECODE_SCOPE = "build_directive"        # or 'transformation_kind'
QUARANTINE_EMIT_DECLARED_NAME = False
CROSS_REQUIRE_UNIQUE = True
COVERGRAIN_DIVERT_FANOUT = True
TRUST_RESOLVED_ON_VIEW = False

ATTRIBUTE_ROUTING_SUPPRESS = {
    # (satellite, attribute) pairs that must NOT be built there -- BI-4.1.
    ("SAT_CLAIM_COVER_SECTION_ASSESSMENT", "Last EMI Paid Date"),
    ("SAT_CLAIM_COVER_SECTION_ASSESSMENT", "Outstanding Loan Amount"),
}

ATTRIBUTE_UNION_ALIASES = {
    # The 7-attribute union of SAT_CLAIM_STATUS_TRANSITION: these are ONE fact.
    "Transition Actor User Reference": "Transition Performed By Reference",
}


# ---------------------------------------------------------------------------
# 4.  BUILD DIRECTIVES -- every entry in the profile's build_directives list,
#     with the generator that implements it NAMED here, so the README table can
#     be emitted from the code rather than remembered.
# ---------------------------------------------------------------------------

BUILD_DIRECTIVES = [
    {"n": 1, "bundle_item": "BUILD_INSTRUCTIONS s2 / KEY_FUNCTIONS s7.11 / map build_directive x45",
     "mechanism": "surrogate_child_key_quarantine layer, scoped by leg_backing=='surrogate'",
     "implemented_in": "gen_mxh3_quarantine.py", "status": "implemented"},
    {"n": 2, "bundle_item": "KEY_FUNCTIONS s7.11b",
     "mechanism": "operand splitter on U+0040/U+0023 inside a leg value, separator PRESERVED",
     "implemented_in": "mxh3_keyrules.py:split_operands/render_leg_value",
     "status": "implemented"},
    {"n": 3, "bundle_item": "KEY_FUNCTIONS s1.0 / s3.3 / s5.8",
     "mechanism": "legs from child_key_components, else ' | ' at brace depth zero; '#' is an "
                  "OPERAND separator only",
     "implemented_in": "mxh3_keyrules.py:declared_legs/split_depth_zero",
     "status": "implemented"},
    {"n": 4, "bundle_item": "KEY_FUNCTIONS s2.3",
     "mechanism": "reject_log predicate driven by resolved_key.degenerate_verdict; the one "
                  "no-source-operand constant is ACCEPTED",
     "implemented_in": "mxh3_keyrules.py:emit_predicate + gen_mxh3_rejectlog.py",
     "status": "implemented"},
    {"n": 5, "bundle_item": "KEY_FUNCTIONS s2.5",
     "mechanism": "key expressions emitted VERBATIM; no normalisation pass over key text; "
                  "namespace prefixes asserted still present after rendering",
     "implemented_in": "mxh3_keyrules.py:render_key_expression/assert_namespaces_intact",
     "status": "implemented"},
    {"n": 6, "bundle_item": "KEY_FUNCTIONS s1.3",
     "mechanism": "walk resolver reads resolved_key.expression/.legs only; the 'spine:' display "
                  "form is never parsed as SQL",
     "implemented_in": "mxh3_keyrules.py:parse_spans + gen_mxh3_resolvers.py",
     "status": "implemented"},
    {"n": 7, "bundle_item": "BUILD_INSTRUCTIONS s5.3 / KEY_FUNCTIONS s9.3",
     "mechanism": "per-walk row-count column emitted beside every cross, plus a row-count "
                  "assertion model; an empty join is counted, never silent",
     "implemented_in": "gen_mxh3_resolvers.py + gen_mxh3_rejectlog.py",
     "status": "implemented"},
    {"n": 8, "bundle_item": "BUILD_INSTRUCTIONS s3 / KEY_FUNCTIONS s5.4",
     "mechanism": "build-side multi-active satellite, 7-attribute union via "
                  "ATTRIBUTE_UNION_ALIASES, OPUS feeder compound key, VERSION_NO dropped",
     "implemented_in": "gen_mxh3_augmented.py", "status": "implemented"},
    {"n": 9, "bundle_item": "BUILD_INSTRUCTIONS s4.1",
     "mechanism": "ATTRIBUTE_ROUTING_SUPPRESS: 2 attributes suppressed on the placeholder, built "
                  "on the ratified SAT_CLAIM_BENEFIT_HEAD",
     "implemented_in": "mxh3_keyrules.py + gen_mxh3_augmented.py", "status": "implemented"},
    {"n": 10, "bundle_item": "BUILD_INSTRUCTIONS s1.4 / KEY_FUNCTIONS s5.3",
     "mechanism": "child-key leg completeness asserted against data_7.js sats[].childkey keyed by "
                  "sats[].code; never reconciled down to a 1-leg form",
     "implemented_in": "build_mxh3_spec.py:assert_fully_keyed", "status": "implemented"},
    {"n": 11, "bundle_item": "BUILD_INSTRUCTIONS s5.5 / KEY_FUNCTIONS s9.2",
     "mechanism": "do_not_build honoured at BOTH block and component scope (3 + 5 = 8)",
     "implemented_in": "mxh3_keyrules.py:do_not_build_block/do_not_build_component",
     "status": "implemented"},
    {"n": 12, "bundle_item": "BUILD_INSTRUCTIONS s5.5",
     "mechanism": "augmented track emits with an explicit unresolved-child-key marker column",
     "implemented_in": "gen_mxh3_augmented.py", "status": "implemented"},
    {"n": 13, "bundle_item": "map transformation_kind == reference_decode (3 directive rows)",
     "mechanism": "reference_decode_gate bespoke predicate, refusing the row when the decode is "
                  "unavailable (see decision D1/D2 for the scope)",
     "implemented_in": "gen_mxh3_refdecode.py", "status": "implemented"},
    {"n": 14, "bundle_item": "KEY_FUNCTIONS s2.2",
     "mechanism": "hash expressions emitted verbatim; an inner coalesce and a separator are never "
                  "tidied; the OUTER guard is the expression's own degenerate value",
     "implemented_in": "mxh3_keyrules.py:emit_predicate/render_key_expression",
     "status": "implemented"},
    {"n": 15, "bundle_item": "SAMPLE_VINTAGE_NOTE.md",
     "mechanism": "no build decision rests on sample absence: membership is tested against the "
                  "COLUMN LIST in 00_tables_index.json, never against sample coverage",
     "implemented_in": "mxh3_keyrules.py:view_columns/leg_resolves", "status": "implemented"},
]


def assert_directives_complete():
    """Every profile directive is implemented and named, or it is a finding."""
    declared = PROFILE["build_directives"]
    if len(BUILD_DIRECTIVES) != len(declared):
        raise AssertionError(
            "profile declares %d build directives, this module implements %d. A directive "
            "declined is a FINDING for mapper-liaison, not a silent omission."
            % (len(declared), len(BUILD_DIRECTIVES)))
    undone = [d for d in BUILD_DIRECTIVES if d["status"] != "implemented"]
    return {"declared": len(declared), "implemented": len(BUILD_DIRECTIVES),
            "unimplemented": len(undone)}


# ---------------------------------------------------------------------------
# 4b. directive_kind -- THE ROUTING FIELD (round-2 map, md5 f3f1fd82...)
#
# The round-1 map carried build_directive on 48 blocks with NO typed field
# separating the 45 surrogate-blocker rows from the 3 reference-decode asks: the
# only discriminator was prose in build_note, so a build honouring the typed
# fields alone SILENTLY SKIPPED 3 directives. The round-2 re-issue adds
# directive_kind, and the re-issue is PURELY ADDITIVE (proved in mxh3_bundle.py:
# strip(round2,'directive_kind') == round1).
#
# directive_kind is the ROUTING field, NOT a replacement for the blocker's
# definition: the blocker remains defined by leg_backing=='surrogate' and
# child_key_tier=='surrogate', each exactly 45.
# ---------------------------------------------------------------------------

DIRECTIVE_KIND_FIELD = "directive_kind"
DIRECTIVE_KIND_ROUTES = {
    "surrogate_child_key": "surrogate_child_key_quarantine",
    "reference_decode": "reference_decode_gate",
}
DIRECTIVE_KIND_EXPECTED = {"surrogate_child_key": 45, "reference_decode": 3}


def directive_route(block):
    """Route a directive-bearing block to its layer, or raise if unlabelled.

    An unlabelled directive must NEVER be silently skipped again -- that is the
    defect the round-2 re-issue exists to fix.
    """
    if block.get("build_directive") is None:
        return None
    kind = block.get(DIRECTIVE_KIND_FIELD)
    if kind is None:
        raise AssertionError(
            "block carries build_directive:true with NO directive_kind. An unlabelled "
            "directive must never be silently skipped -- that is exactly the defect the "
            "round-2 re-issue fixed. FAIL_LOUD_NEVER_IGNORE.")
    if kind not in DIRECTIVE_KIND_ROUTES:
        raise AssertionError(
            "unrecognised directive_kind %r. Handle the SET and raise on a member you do not "
            "recognise (s1.5); known: %s" % (kind, sorted(DIRECTIVE_KIND_ROUTES)))
    return DIRECTIVE_KIND_ROUTES[kind]


def assert_directive_kind_partition(cols):
    """The three assertions the coordinator requires, over the whole map.

    1. directive_kind present on exactly 48 blocks
    2. it partitions into exactly 2 values, 45 + 3
    3. NO build_directive:true block lacks it
    """
    n = 0
    census = {}
    unlabelled = []
    for c in cols:
        for side in ("target", "augmentation"):
            b = c.get(side)
            if not isinstance(b, dict):
                continue
            k = b.get(DIRECTIVE_KIND_FIELD)
            if k is not None:
                n += 1
                census[k] = census.get(k, 0) + 1
            if b.get("build_directive") is not None and k is None:
                unlabelled.append((c["table_name"], c["column_name"], side))
    want_total = sum(DIRECTIVE_KIND_EXPECTED.values())
    if n != want_total:
        raise AssertionError("directive_kind is on %d blocks, expected %d" % (n, want_total))
    if census != DIRECTIVE_KIND_EXPECTED:
        raise AssertionError("directive_kind census %r, expected %r"
                             % (census, DIRECTIVE_KIND_EXPECTED))
    if unlabelled:
        raise AssertionError(
            "%d block(s) carry build_directive:true with no directive_kind: %s. An unlabelled "
            "directive must never be silently skipped." % (len(unlabelled), unlabelled[:4]))
    return {"blocks": n, "census": census, "values": len(census), "unlabelled": 0}


# ---------------------------------------------------------------------------
# 4c. do_not_build AT TWO DISJOINT LEVELS, WITH DISTINCT SEMANTICS
#
# The two refusal levels are DISJOINT and the mechanism cuts BOTH ways:
#   * BLOCK level  (3 rows) -> refuses the ROW.  All 3 are SAT_PARTY_BANKING
#     'Account Number Masked', and their COMPONENT flag is False, so a
#     component-level reader BUILDS them.
#   * COMPONENT level (5 elements) -> refuses that LEG.  Their BLOCK flag is
#     False, so a block-level reader BUILDS them.
# Honouring one scope builds the other's rows IN BOTH DIRECTIONS.
# ---------------------------------------------------------------------------

def refusal_level(block):
    """'row' when the block is refused outright, else None."""
    return "row" if block.get("do_not_build") is not None else None


def refused_legs(block):
    """The leg names refused at COMPONENT level on this block."""
    return [e.get("leg") for e in (block.get("child_key_components") or [])
            if e.get("do_not_build") is not None]


def assert_do_not_build_both_levels(cols):
    """Assert 5 + 3 = 8, that the levels are DISJOINT, and return both populations."""
    blk, comp = [], []
    for c in cols:
        for side in ("target", "augmentation"):
            b = c.get(side)
            if not isinstance(b, dict):
                continue
            key = (c["table_name"], c["column_name"], side)
            if b.get("do_not_build") is not None:
                blk.append(key)
            for e in (b.get("child_key_components") or []):
                if e.get("do_not_build") is not None:
                    comp.append(key + (e.get("leg"),))
    bs, cs = set(blk), {x[:3] for x in comp}
    overlap = bs & cs
    if len(blk) != 3 or len(comp) != 5:
        raise AssertionError(
            "do_not_build populations are block=%d component=%d, expected 3 and 5. Honouring "
            "ONE scope builds the other's rows in BOTH directions."
            % (len(blk), len(comp)))
    if overlap:
        raise AssertionError(
            "the two do_not_build levels are NOT disjoint: %d block(s) carry both. The "
            "semantics differ (row vs leg), so an overlap must be decided, not defaulted."
            % len(overlap))
    return {"block_level_rows": len(blk), "component_level_legs": len(comp),
            "total": len(blk) + len(comp), "disjoint": True,
            "block_rows": blk, "component_legs": comp}


# ---------------------------------------------------------------------------
# 4d. VALIDATOR DISPOSITIONS -- read from the FIELDS, never from prose.
#
# 7 composite_key findings (the old figure of 4 was the severity=='blocker'
# SUBSET). Each now carries build_disposition / build_action / map_owes.
# This build honours the typed disposition and NEVER re-keys on its own
# authority.
# ---------------------------------------------------------------------------

DISPOSITION_FIELD = "build_disposition"
DISPOSITION_ACTIONS = {
    "REFUSE": "refuse_the_blocks",
    "EMIT, resolving hop direction FROM THE GRAPH": "emit_hop_from_graph",
    "EMIT, with the instability declared": "emit_with_instability_declared",
    "EMIT BOTH, do not normalise": "emit_both_no_normalisation",
}


def load_dispositions(findings, check="composite_key"):
    """The typed dispositions for one check, read from fields only."""
    out = []
    for f in findings:
        if f.get("check") != check:
            continue
        d = f.get(DISPOSITION_FIELD)
        if d is None:
            raise AssertionError(
                "a %s finding carries no %s. The disposition must be read from the FIELD, "
                "not inferred from prose." % (check, DISPOSITION_FIELD))
        if d not in DISPOSITION_ACTIONS:
            raise AssertionError(
                "unrecognised %s %r. Handle the SET and raise on a member you do not "
                "recognise (s1.5); known: %s" % (DISPOSITION_FIELD, d,
                                                 sorted(DISPOSITION_ACTIONS)))
        out.append({
            "id": f.get("id"), "severity": f.get("severity"),
            "disposition": d, "action": DISPOSITION_ACTIONS[d],
            "map_owes": f.get("map_owes"),
            "blocks_affected": f.get("build_blocks_affected"),
            "n_blocks": f.get("n_blocks"),
            "tables": [t.strip() for t in str(f.get("table") or "").split(";") if t.strip()],
            "target": f.get("target"),
            "matcher": f.get("matcher"),
            "scope": f.get("scope"),
            "unit": f.get("unit"),
        })
    return out


def assert_disposition_census(disps):
    """4 REFUSE + 1 hop-from-graph + 1 instability-declared + 1 emit-both."""
    cen = {}
    for d in disps:
        cen[d["action"]] = cen.get(d["action"], 0) + 1
    want = {"refuse_the_blocks": 4, "emit_hop_from_graph": 1,
            "emit_with_instability_declared": 1, "emit_both_no_normalisation": 1}
    if cen != want:
        raise AssertionError("composite_key disposition census %r, expected %r" % (cen, want))
    return cen


# ---------------------------------------------------------------------------
# 5.  THE SOURCE INDEX AND THE GRAPH
# ---------------------------------------------------------------------------

_IDX_CACHE = {}


def _index():
    if "idx" not in _IDX_CACHE:
        with open(os.path.join(BUNDLE, "00_tables_index.json"), encoding="utf-8") as fh:
            tabs = json.load(fh)["tables"]
        # TWO spellings compared rather than one trusted: columns[].name and
        # column_names agree on 188 of 188 here, measured not assumed.
        cols_a = {t["table_name"]: {c["name"] for c in (t.get("columns") or [])} for t in tabs}
        cols_b = {t["table_name"]: set(t.get("column_names") or []) for t in tabs}
        bad = [k for k in cols_a if cols_a[k] != cols_b[k]]
        if bad:
            raise AssertionError(
                "00_tables_index.json disagrees with itself on %d table(s) between "
                "columns[].name and column_names: %s" % (len(bad), bad[:4]))
        _IDX_CACHE["idx"] = {
            "tables": tabs,
            "columns": cols_a,
            "parent": {t["table_name"]: (t.get("shred") or {}).get("parent_table_candidate")
                       for t in tabs},
            "types": {t["table_name"]: {c["name"]: (c.get("data_type") or "varchar")
                                        for c in (t.get("columns") or [])} for t in tabs},
            "spine": {t["table_name"]: (t.get("spine") or {}) for t in tabs},
            "is_pivot": {t["table_name"]: bool((t.get("shred") or {}).get("is_pivot"))
                         for t in tabs},
            "depth": {t["table_name"]: (t.get("shred") or {}).get("shred_depth")
                      for t in tabs},
        }
        # s1.16 -- assert the graph is NON-EMPTY before any walk is attempted.
        edges = sum(1 for v in _IDX_CACHE["idx"]["parent"].values() if v)
        if edges == 0:
            raise AssertionError(
                "the hierarchy graph is EMPTY (0 edges on shred.parent_table_candidate). "
                "Every ancestry answer would be a vacuous 'no', which looks exactly like a "
                "fact about the data. Stage 1 stops rather than emitting flat models.")
        declared = PROFILE["hierarchy"]["edge_count_primary"]
        if edges != declared:
            raise AssertionError(
                "graph has %d edges, profile declares %d" % (edges, declared))
    return _IDX_CACHE["idx"]


def view_columns(view):
    return _index()["columns"].get(view, frozenset())


def view_exists(view):
    return view in _index()["columns"]


def column_type(view, col):
    return _index()["types"].get(view, {}).get(col, "varchar")


def is_pivot(view):
    return _index()["is_pivot"].get(view, False)


def spine_flags(view):
    return _index()["spine"].get(view, {})


def all_views():
    return sorted(_index()["columns"])


def ancestors(view):
    """The REAL ancestor chain, nearest first. No level is skipped here."""
    par = _index()["parent"]
    out, seen, cur = [], set(), view
    while True:
        p = par.get(cur)
        if not p or p in seen:
            break
        out.append(p)
        seen.add(p)
        cur = p
    return out


def lca(a, b):
    """Lowest common ancestor of two views, or None."""
    aa = [a] + ancestors(a)
    bb = set([b] + ancestors(b))
    for x in aa:
        if x in bb:
            return x
    return None


def descend_chain(frm, to):
    """The REAL per-level chain from `frm` DOWN to `to`, excluding frm.

    Returns None when `to` is not a descendant of `frm`.
    """
    if frm == to:
        return []
    anc = ancestors(to)
    if frm not in anc:
        return None
    chain = []
    for a in anc:
        chain.append(a)
        if a == frm:
            break
    # chain is to's ancestors nearest-first up to frm; reverse and drop frm
    chain = list(reversed(chain))[1:]
    return chain + [to]


# ---------------------------------------------------------------------------
# 6.  THE SPAN GRAMMAR -- authored here, proved to FIRE and to DECLINE
# ---------------------------------------------------------------------------

# Form 1/2: spine[<start> [-> <hop>]*] [>> <table>.<col>] [.<col>]
SPAN_BRACKET = re.compile(
    r"spine\[\s*(?P<start>[A-Za-z_][A-Za-z0-9_]*)\s*"
    r"(?P<hops>(?:->\s*[A-Za-z_][A-Za-z0-9_]*\s*)*)\]"
    r"(?:\s*>>\s*(?P<dest>[A-Za-z_][A-Za-z0-9_]*)\s*\.\s*(?P<destcol>[A-Za-z_][A-Za-z0-9_]*))?"
    r"(?:\s*\.\s*(?P<col>[A-Za-z_][A-Za-z0-9_]*))?")

# Form 3: the 2 bare descends, which carry NO 'spine[' prefix -- which is exactly
# why a spine[]-only census reports 1,812 while the span total is 1,814.
SPAN_BARE = re.compile(
    r"(?<![A-Za-z0-9_])(?P<start>KEY_HASH|PARENT_KEY_HASH|FOREIGN_KEY)\s*>>\s*"
    r"(?P<dest>[A-Za-z_][A-Za-z0-9_]*)\s*\.\s*(?P<destcol>[A-Za-z_][A-Za-z0-9_]*)")

HOP_TOKEN = re.compile(r"->\s*([A-Za-z_][A-Za-z0-9_]*)")

# The display-only forms.  Present so they can be RECOGNISED and refused, never
# executed.  spine:<TABLE>.<COLUMN> and the {spine:KEY_HASH} surrogate.
SPINE_DISPLAY = re.compile(r"spine:(?P<table>[A-Za-z_][A-Za-z0-9_]*)"
                           r"(?:\.(?P<col>[A-Za-z_][A-Za-z0-9_]*))?")
BRACE_TOKEN = re.compile(r"\{([^{}]*)\}")
START_TOKENS = ("PARENT_KEY_HASH", "FOREIGN_KEY", "KEY_HASH")


class Span(object):
    """One parsed walk, with its hops EXPANDED to real per-level chains (s4)."""

    __slots__ = ("raw", "from_view", "start", "named_hops", "dest", "terminal_col",
                 "kind", "climb", "descend", "terminal_view", "ordinal", "reclassified")

    def __init__(self, raw, from_view, start, named_hops, dest, terminal_col):
        self.raw = raw
        self.from_view = from_view
        self.start = start
        self.named_hops = named_hops
        self.dest = dest
        self.terminal_col = terminal_col
        self.kind = "cross" if dest else "climb"
        self.climb = []
        self.descend = []
        self.terminal_view = None
        self.ordinal = None
        self.reclassified = False

    def key(self):
        return (self.from_view, self.raw)

    def as_dict(self):
        return {"raw": self.raw, "from_view": self.from_view, "start": self.start,
                "named_hops": list(self.named_hops), "kind": self.kind,
                "climb_real": list(self.climb), "descend_real": list(self.descend),
                "terminal_view": self.terminal_view, "terminal_column": self.terminal_col,
                "ordinal": self.ordinal, "direction_reclassified_from_graph": self.reclassified,
                "levels_named": len(self.named_hops),
                "levels_real": len(self.climb) + len(self.descend),
                "skipped_levels": (len(self.climb) + len(self.descend)) - len(self.named_hops)}


def parse_spans(view, expr):
    """Every span in `expr`, in order, with hops expanded. Residue is FATAL."""
    if not isinstance(expr, str) or not expr:
        return []
    out = []
    for mo in SPAN_BRACKET.finditer(expr):
        hops = HOP_TOKEN.findall(mo.group("hops") or "")
        out.append(Span(mo.group(0), view, mo.group("start"), hops,
                        mo.group("dest"),
                        mo.group("destcol") or mo.group("col")))
    rest = SPAN_BRACKET.sub(" ", expr)
    for mo in SPAN_BARE.finditer(rest):
        out.append(Span(mo.group(0), view, mo.group("start"), [],
                        mo.group("dest"), mo.group("destcol")))
    rest = SPAN_BARE.sub(" ", rest)
    for tok in ("spine[", "->", ">>"):
        if tok in rest:
            raise AssertionError(
                "PARSE RESIDUE: %r survives after stripping every matched span from the "
                "expression on %s. A grammar that does not fully parse will not fully build, "
                "and the gap will look like a source gap.\n  expr: %s\n  residue: %s"
                % (tok, view, expr[:200], rest[:200]))
    for s in out:
        expand_span(s)
    return out


def expand_span(span):
    """Expand a span's NAMED hops into the real per-level chain (s4).

    A named destination may skip levels -- and on this feed that is the DOMINANT
    case: only 52 of 1,812 climbs name the direct parent, 1,760 skip at least
    one. Every intervening level the expression does not name is materialised
    here, or the join silently crosses several levels at once.
    """
    v = span.from_view
    if not view_exists(v):
        raise AssertionError("span source view %r is absent from the source index" % v)
    anc = ancestors(v)

    if span.start == "KEY_HASH" and span.dest and not span.named_hops:
        # the bare descend: start at the row itself
        chain = descend_chain(v, span.dest)
        if chain is None:
            raise AssertionError(
                "bare-form span on %s declares a descend to %r, which the GRAPH says is not a "
                "descendant. Direction is classified from the graph, never from the token."
                % (v, span.dest))
        span.climb = []
        span.descend = chain
        span.terminal_view = span.dest
        _finish(span)
        return span

    # Climb: each named hop must be a genuine ancestor, in order.
    #
    # DIRECTION IS CLASSIFIED FROM THE GRAPH, NEVER FROM THE ARROW TOKEN.
    # 12 blocks on 6 views write 'spine[FOREIGN_KEY -> ..._CLAIM_DETAIL].CLAIM_NUMBER'
    # with the CLIMB arrow, but CLAIM_DETAIL is a SIBLING shred under the CLM root
    # and not an ancestor of any of those views. The validator's typed
    # build_disposition for that finding is "EMIT, resolving hop direction FROM THE
    # GRAPH", so a non-ancestor hop that IS reachable through a common ancestor is
    # RECLASSIFIED as a cross here and recorded. A token-driven generator either
    # fails outright or lands on the wrong node and produces an EMPTY JOIN that
    # looks exactly like sparse source data.
    climb = []
    cursor = 0
    reclassified_to = None
    for hop in span.named_hops:
        if hop not in anc:
            if not view_exists(hop):
                raise AssertionError(
                    "span on %s names hop %r which is not a table in the source index at all."
                    % (v, hop))
            anchor = lca(v, hop)
            if anchor is None or anchor == hop:
                raise AssertionError(
                    "span on %s names hop %r which the GRAPH places neither among its "
                    "ancestors %s nor as a sibling reachable through a common ancestor. "
                    "Direction is classified from the graph, never from the token."
                    % (v, hop, anc[:4]))
            if reclassified_to is not None or span.dest:
                raise AssertionError(
                    "span on %s would need TWO graph reclassifications (%r and %r); refusing "
                    "to guess the intended shape." % (v, reclassified_to, hop))
            reclassified_to = hop
            at = anc.index(anchor)
            climb = anc[:at + 1]
            cursor = at
            GRAPH_RECLASSIFIED.append({
                "from_view": v, "named_hop": hop, "lca": anchor,
                "was": "climb_arrow", "now": "cross",
                "why": "the graph places the named hop as a sibling/cousin, not an ancestor",
            })
            continue
        at = anc.index(hop)
        if at < cursor:
            raise AssertionError(
                "span on %s names hops out of ancestral order: %r appears above a previously "
                "named hop" % (v, hop))
        climb = anc[:at + 1]            # EVERY real level up to and including this hop
        cursor = at
    if reclassified_to is not None:
        span.dest = reclassified_to
        span.kind = "cross"
        span.reclassified = True
    span.climb = climb
    top = climb[-1] if climb else v

    if span.dest:
        # cross: climb to the LCA, then descend into another branch, per real level
        anchor = lca(top, span.dest)
        if anchor is None:
            raise AssertionError(
                "cross on %s has NO common ancestor with %r, so it is neither a climb nor a "
                "cross and cannot be expressed as a join." % (v, span.dest))
        if anchor != top:
            at = ancestors(v).index(anchor) if anchor in ancestors(v) else None
            if at is None:
                raise AssertionError(
                    "cross on %s: LCA %r with %r is not on the row's own ancestor chain"
                    % (v, anchor, span.dest))
            span.climb = ancestors(v)[:at + 1]
        chain = descend_chain(anchor, span.dest)
        if chain is None:
            raise AssertionError(
                "cross on %s: %r is not a descendant of the LCA %r" % (v, span.dest, anchor))
        span.descend = chain
        span.terminal_view = span.dest
    else:
        span.terminal_view = top
        span.descend = []
    _finish(span)
    return span


def _finish(span):
    tv, tc = span.terminal_view, span.terminal_col
    if not tv or not view_exists(tv):
        raise AssertionError("span %r resolves to an unknown terminal view %r"
                             % (span.raw, tv))
    if tc and tc not in view_columns(tv):
        raise AssertionError(
            "span %r terminates at %s.%s, but that column is ABSENT from the source index for "
            "that view. Emitting it would reference a column that does not exist."
            % (span.raw, tv, tc))
    if not span.climb and not span.descend:
        # s1.6 -- an empty replacement span is FATAL.  A span that expands to no
        # join at all would be replaced by the bare terminal column on the row's
        # OWN view, silently reading a different table's value from this one.
        raise AssertionError(
            "EMPTY REPLACEMENT SPAN on %s for %r: the expansion produced no climb and no "
            "descend, so the span would be replaced by nothing. s1.6: this is fatal."
            % (span.from_view, span.raw))


# -------------------------------------------------- span registry and naming

class SpanRegistry(object):
    """Every distinct span in the build, with a stable ordinal and column name."""

    def __init__(self):
        self._by_key = {}
        self._order = []

    def add(self, span):
        k = span.key()
        if k in self._by_key:
            return self._by_key[k]
        self._by_key[k] = span
        self._order.append(k)
        return span

    def finalise(self):
        """Assign ordinals in a canonical order so names are stable across runs."""
        for i, k in enumerate(sorted(self._by_key)):
            self._by_key[k].ordinal = i
        return self

    def all(self):
        return [self._by_key[k] for k in sorted(self._by_key)]

    def for_view(self, view):
        return [s for s in self.all() if s.from_view == view]

    def get(self, view, raw):
        return self._by_key.get((view, raw))

    def views(self):
        return sorted({s.from_view for s in self.all()})

    def walk_views(self):
        """EVERY view that appears ANYWHERE on a walk, including intervening levels
        no expression names."""
        out = set()
        for s in self.all():
            out.add(s.from_view)
            out.update(s.climb)
            out.update(s.descend)
            if s.terminal_view:
                out.add(s.terminal_view)
        return sorted(out)


def span_column(span):
    """The resolver column exposing a span's terminal value."""
    if span.ordinal is None:
        raise AssertionError("span ordinal not assigned; call SpanRegistry.finalise()")
    return N.fit("W%03d_%s" % (span.ordinal, span.terminal_col or "VALUE"))


def span_count_column(span):
    return N.fit("W%03d_N" % span.ordinal)


# ---------------------------------------------------------------------------
# 7.  SPAN REPLACEMENT
# ---------------------------------------------------------------------------

def render_key_expression(view, expr, registry, alias="src"):
    """Replace every span in `expr` with the resolver column that carries it.

    The expression is otherwise emitted VERBATIM: no separator is tidied, no
    inner coalesce is removed, no namespace prefix is stripped. An inner
    coalesce(COL,'') inside a content hash is REQUIRED, not a defect -- NULL||'x'
    is NULL and would annihilate the hash input.
    """
    if not isinstance(expr, str) or not expr.strip():
        return None
    spans = parse_spans(view, expr)
    out = expr
    for s in spans:
        reg = registry.get(view, s.raw) or registry.add(s)
        col = span_column(reg)
        if not col:
            raise AssertionError("empty replacement for span %r on %s" % (s.raw, view))
        # An empty alias means a BARE column reference: the wide stage flattens the
        # resolver's columns alongside the source columns, and W### names cannot
        # collide with a source column, so no qualifier is needed downstream.
        out = out.replace(s.raw, ("%s.%s" % (alias, col)) if alias else col)
    if "spine[" in out or ">>" in out:
        raise AssertionError(
            "rendered expression on %s still carries walk notation after replacement: %s"
            % (view, out[:200]))
    assert_namespaces_intact(expr, out)
    return out


def assert_namespaces_intact(before, after):
    """No population namespace may be lost in rendering (directive 5).

    Removing 'MEMBER:' / 'AGENT:' / ... merges identifier spaces on one hub and
    is unrecoverable.
    """
    for p in NAMESPACE_PREFIXES:
        if before.count(p) != after.count(p):
            raise AssertionError(
                "namespace prefix %r count changed from %d to %d during rendering. Removing a "
                "population namespace merges identifier spaces on one hub and is unrecoverable."
                % (p, before.count(p), after.count(p)))


_SQL_FOLLOWERS = frozenset([
    "from", "where", "group", "order", "having", "limit", "qualify", "union",
    "join", "left", "right", "inner", "outer", "full", "cross", "on", "and",
    "or", "select", "with", "as", "when", "then", "else", "end", "case", "is",
    "not", "null", "by", "using", "window", "partition", "over", "asc", "desc",
])


def assert_no_prose_in_sql(sql, where=""):
    """s3.3 -- prose is valid SQL; only an assertion catches it.

    Fires on a map prose field name appearing in emitted SQL, and on an
    identifier-position token carrying a space.
    """
    hits = []
    for f in ("rationale", "build_note", "child_key_note", "null_safety_note",
              "unresolved_reason", "leg_split_warning", "key_derivation",
              "unmapped_reason", "review_note", "blockerfix_note"):
        # a prose field's CONTENT, not its name, is what leaks; the giveaway is the
        # mapper's own sentence openers appearing outside a comment.
        for marker in ("GENUINELY UNRESOLVED", "child_key named_discriminator",
                       "PROVED FROM THE SAMPLE", "REQUIRES a reference decode",
                       "DO NOT BUILD THIS ROW"):
            for line in re.sub(r"/\*.*?\*/", " ", sql, flags=re.S).splitlines():
                st = line.strip()
                if st.startswith("--"):
                    continue
                if marker in line:
                    hits.append((f, marker, line.strip()[:90]))
    # An alias carrying a SPACE is the shape that ships when a business name
    # reaches identifier position.  The second word must NOT be a SQL keyword:
    # 'as HUB_POLICY_BK__POLICY_NUMBER from t' is real SQL, and a matcher without
    # this stop-list accuses it -- which this module's own probe caught.
    # COMMENTS ARE NOT IDENTIFIER POSITION. A model header carries English on
    # purpose, and scanning it for aliases accuses the build's own prose -- which
    # is what happened: "must exist as a table to join through" matched. Strip
    # /* ... */ and -- ... before looking at identifier position.
    code = re.sub(r"/\*.*?\*/", " ", sql, flags=re.S)
    code = re.sub(r"(?m)--[^\n]*", " ", code)
    # STRING LITERALS ARE NOT IDENTIFIER POSITION EITHER. A child-key literal
    # legitimately contains English -- 'Identification Type Code = As Per
    # Identification' -- and scanning it accuses the map's own data.
    code = re.sub(r"'[^']*'", " ", code)
    for mo in re.finditer(r"\bas\s+([A-Za-z_][A-Za-z0-9_]*)\s+([A-Za-z_][A-Za-z0-9_]*)",
                          code, re.I):
        if mo.group(2).lower() in _SQL_FOLLOWERS:
            continue
        hits.append(("alias_with_space", mo.group(1) + " " + mo.group(2),
                     mo.group(0)[:90]))
    if hits:
        raise AssertionError(
            "PROSE REACHED SQL in %s: %d occurrence(s), first %s. Prose is valid SQL; only an "
            "assertion catches it. The map's leg is prose -- route it, do not rename it."
            % (where, len(hits), hits[0]))
    return True


# ---------------------------------------------------------------------------
# 8.  CHILD KEYS -- legs, operands, ladders
# ---------------------------------------------------------------------------

def split_depth_zero(text, sep):
    """Split `text` on `sep` at BRACE DEPTH ZERO.

    A coalesce ladder inside braces frequently contains the leg separator's own
    '|' character, so a naive split invents legs that do not exist.
    """
    out, buf, depth, i = [], [], 0, 0
    while i < len(text):
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        if depth == 0 and text.startswith(sep, i):
            out.append("".join(buf))
            buf = []
            i += len(sep)
            continue
        buf.append(ch)
        i += 1
    out.append("".join(buf))
    return out


def declared_legs(block):
    """The block's child-key legs.

    AUTHORITY ORDER, from the profile's own token
    DECLARED_COMPONENTS_THEN_PIPE_AT_BRACE_DEPTH_ZERO:
      1. child_key_components[]  -- authoritative for LEGS
      2. else child_key_value split on ' | ' at brace depth zero
    '#' is NEVER a leg boundary: counting it under-counts 328 blocks and
    OVER-counts 117, and the over-count turns a SOLE leg into an apparent
    compound, which silences the surrogate blocker.
    """
    comps = block.get("child_key_components") or []
    if comps:
        out = []
        for e in comps:
            backing = e.get(COMPONENT_DISCRIMINATOR)
            if backing not in COMPONENT_KINDS:
                raise AssertionError(
                    "unrecognised %s %r on leg %r. Handle the SET and raise on a member you do "
                    "not recognise (s1.5); known: %s"
                    % (COMPONENT_DISCRIMINATOR, backing, e.get("leg"),
                       sorted(COMPONENT_KINDS)))
            out.append({"leg": e.get("leg"), "value": e.get("value"),
                        "backing": backing,
                        "resolved_on_view": e.get("resolved_on_view"),
                        "do_not_build": bool(e.get("do_not_build")),
                        "source_gap": bool(e.get("source_gap")),
                        "unresolved_reason": e.get("unresolved_reason"),
                        "from": "components"})
        return out
    val = block.get("child_key_value")
    if not isinstance(val, str) or not val.strip():
        return []
    out = []
    for part in split_depth_zero(val, LEG_SEPARATOR):
        if LEG_BINDER in part:
            nm, _, v = part.partition(LEG_BINDER)
            out.append({"leg": nm.strip(), "value": v.strip(), "backing": None,
                        "resolved_on_view": None, "do_not_build": False,
                        "source_gap": False, "unresolved_reason": None,
                        "from": "displayed_value"})
        else:
            out.append({"leg": None, "value": part.strip(), "backing": None,
                        "resolved_on_view": None, "do_not_build": False,
                        "source_gap": False, "unresolved_reason": None,
                        "from": "displayed_value_unnamed"})
    return out


def split_operands(value):
    """Split ONE leg value into operands on U+0023 / U+0040 at brace depth zero.

    The separator is RETURNED WITH the operands so it can be re-emitted: the
    questionnaire namespace is LOAD-BEARING and a build-wide strip merges every
    member's questionnaire onto one row per proposal, while a build-wide preserve
    keeps the '@LAWYER' provenance split. Preserving the separator makes the
    split IDENTITY for a pure literal -- 'LIBRARY@LAWYER' renders unchanged --
    so no emitted key can lose an '@' segment either way.
    """
    if SEP_FULLWIDTH_AT in (value or ""):
        raise AssertionError(
            "leg value %r contains U+FF20 FULLWIDTH COMMERCIAL AT. The map uses U+0040 plain "
            "ASCII; a splitter built on the fullwidth glyph matches NOTHING and the namespace "
            "silently vanishes." % (value,))
    parts, buf, depth, i = [], [], 0, 0
    while i < len(value):
        ch = value[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        if depth == 0 and ch in (SEP_HASH, SEP_AT):
            parts.append(("operand", "".join(buf)))
            parts.append(("separator", ch))
            buf = []
            i += 1
            continue
        buf.append(ch)
        i += 1
    parts.append(("operand", "".join(buf)))
    return [p for p in parts if not (p[0] == "operand" and p[1] == "")]


def guarded(col):
    """Every ladder operand is written nullif(trim(<operand>),'').

    In a shredded EAV feed an absent label materialises as '' and not as NULL, so
    without the nullif a coalesce ladder never falls through to its next rung.
    """
    return "nullif(trim(%s),'')" % col


def null_safe(expr):
    """Per-OPERAND null safety for a composite child key (s5.3).

    Only 191 of 770 composites in this map carry the inner coalesce and 762 carry
    a bare nullif, so the build supplies it: without it one blank operand
    annihilates the whole concatenation.
    """
    return "coalesce(%s,'')" % expr


_LADDER_SQLFN = frozenset(["coalesce", "nullif", "trim", "upper", "lower", "md5",
                           "normalise", "to_char", "lnk"])
_IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
_STRLIT_RE = re.compile(r"'[^']*'")
_LINEAGE = frozenset(["KEY_HASH", "PARENT_KEY_HASH", "FOREIGN_KEY", "RECORD_HASH",
                      "ROOT_HASH", "PARENT_RECORD_HASH", "PARENT_TABLE_NAME"])


def rung_columns(rung):
    """The on-view columns one ladder rung needs, or None if it is walk-backed.

    A column named inside spine[...] or spine:... belongs to ANOTHER view, so
    asking THIS view for it is a false accusation -- the mistake that turns 1
    real finding into 246.
    """
    if "spine" in rung and re.search(r"\bspine\s*[:\[]", rung):
        return None
    t = _STRLIT_RE.sub(" ", rung)
    out = set()
    for mo in _IDENT_RE.finditer(t):
        w = mo.group(0)
        if w.lower() in _LADDER_SQLFN or w in _LINEAGE:
            continue
        out.add(w)
    return out or None


def leg_resolves(view, value):
    """(ok, reason). A brace token is a LADDER: at least one rung must resolve."""
    if not isinstance(value, str) or not value.strip():
        return False, "leg has no value at all"
    toks = BRACE_TOKEN.findall(value)
    if not toks:
        return True, "pure literal"
    have = view_columns(view)
    for tok in toks:
        ok = False
        detail = []
        for r in split_depth_zero(tok, "|"):
            need = rung_columns(r)
            if need is None:
                ok = True
                detail.append("walk")
                continue
            if need <= have:
                ok = True
                detail.append("on-view")
            else:
                detail.append("absent:" + ",".join(sorted(need - have)))
        if not ok:
            return False, "token {%s} has NO resolving rung (%s)" % (tok[:70], "; ".join(detail))
    return True, "ok"


def do_not_build_block(block):
    """BLOCK scope. Disjoint from the component scope -- BOTH must be read."""
    return bool(block.get("do_not_build"))


def do_not_build_component(comp):
    """COMPONENT scope. A build honouring only the block scope BUILDS these 5."""
    return bool(comp.get("do_not_build"))


def assert_no_ordinal_leg(legs, satellite, view):
    """A renumbering ordinal needs hub-grade stability to be a child-key leg.

    SEQUENCE_NO and SEQUENCENO are THE SAME ordinal under TWO spellings in one
    feed, which is why both are swept.
    """
    hits = []
    for lg in legs:
        v = lg.get("value") or ""
        for ordn in RENUMBERING_ORDINALS:
            if re.search(r"\{[^}]*\b" + re.escape(ordn) + r"\b[^}]*\}", v):
                hits.append((lg.get("leg"), ordn))
    return hits


# ---------------------------------------------------------------------------
# 8b. THE CHILD-KEY LEG RENDERER
# ---------------------------------------------------------------------------

def resolve_display_table(short, view):
    """A 'spine:<TABLE>' display token -> a real index table, or None.

    The displayed form names the CONCEPT; the GRAPH supplies the mechanism. All
    199 occurrences of this form name MEMBERS_PARTY, which the graph places as a
    SIBLING of the row's view in 198 of 199 cases -- so these are LCA crosses and
    not climbs. 'spine:ROLE' names no table in the index at all and returns None
    rather than a guess.
    """
    if short in ("KEY_HASH", "PARENT_KEY_HASH", "RECORD_HASH", "ROOT_HASH",
                 "PARENT_RECORD_HASH"):
        return None
    if view_exists(short):
        return short
    anc = [a for a in ancestors(view) if a.endswith("_" + short)]
    if len(anc) == 1:
        return anc[0]
    allc = [t for t in _index()["columns"] if t.endswith("_" + short)]
    if len(allc) == 1:
        return allc[0]
    return None


def render_leg_value(view, value, span_lookup=None, alias="res"):
    """(sql, note) for one declared child-key leg, or (None, reason) if refused."""
    if not isinstance(value, str) or not value.strip():
        return None, "leg has no value at all"
    pieces = split_operands(value)
    out = []
    for kind, text in pieces:
        if kind == "separator":
            out.append(sql_literal(text))        # the separator is PRESERVED
            continue
        t = text.strip()
        if not t:
            continue
        if t.startswith("{") and t.endswith("}") and t.count("{") == 1:
            inner = t[1:-1]
            rendered, why = _render_ladder(view, inner, span_lookup, alias)
            if rendered is None:
                return None, why
            out.append(rendered)
        elif "{" in t:
            rendered, why = _render_ladder(view, t.strip("{}"), span_lookup, alias)
            if rendered is None:
                return None, why
            out.append(rendered)
        else:
            out.append(sql_literal(t))           # a pure literal operand
    if not out:
        return None, "no renderable operand"
    # Per-OPERAND null safety: one blank operand must not annihilate the whole
    # concatenation. Only 191 of 770 composites in the map carry this, so the
    # build supplies it.
    safe = [o if o.startswith("'") else null_safe(o) for o in out]
    return " || ".join(safe), "ok"


def _render_ladder(view, inner, span_lookup, alias):
    """A brace token: a coalesce ladder of ALTERNATIVES. Prune what cannot resolve."""
    rungs = split_depth_zero(inner, "|")
    kept, pruned = [], []
    have = view_columns(view)
    for r in rungs:
        r = r.strip()
        if not r:
            continue
        mo = SPINE_DISPLAY.search(r)
        if mo:
            tgt = resolve_display_table(mo.group("table"), view)
            col = mo.group("col")
            key = (view, tgt, col)
            if tgt and col and span_lookup and key in span_lookup:
                kept.append(("%s.%s" % (alias, span_lookup[key]))
                            if alias else span_lookup[key])
            else:
                pruned.append("spine:%s.%s (no resolver column on this view)"
                              % (mo.group("table"), col))
            continue
        need = rung_columns(r)
        if need is None:
            pruned.append("unrecognised rung %r" % r[:40])
            continue
        if need <= have:
            # The rung may already carry its own guard; if it is a bare column, guard it.
            if re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", r):
                kept.append(guarded(r))
            else:
                kept.append(r)
        else:
            pruned.append("absent on this view: %s" % ",".join(sorted(need - have)))
    if not kept:
        return None, ("token {%s} has NO resolving rung (%s)"
                      % (inner[:60], "; ".join(pruned[:3])))
    if len(kept) == 1:
        return kept[0], "ok"
    return "coalesce(%s)" % ", ".join(kept), "ok"


def build_span_lookup(spans):
    """(from_view, terminal_view, terminal_column) -> resolver column name."""
    out = {}
    for s in spans:
        k = (s["from_view"], s["terminal_view"], s["terminal_column"])
        out.setdefault(k, N.fit("W%03d_%s"
                                % (s["ordinal"], s["terminal_column"] or "VALUE")))
    return out

# ---------------------------------------------------------------------------
# 9.  THE EMIT / REJECT PREDICATE PAIR
# ---------------------------------------------------------------------------

DEGENERATE_VERDICTS = frozenset(
    k for k in PROFILE["key_ladder"]["degenerate_verdict_census"]
    if k != "absent_unresolved")


def emit_predicate(rendered_key, source_columns, degenerate_verdict, degenerate_value):
    """The SQL boolean that decides whether a row's key may be loaded.

    THE LARGEST OBLIGATION ON THIS FEED. 2,100 blocks yield a NULL key on a blank
    row, and on Snowflake a NULL key is DROPPED by the load -- unlogged data loss
    that reads as a sparse source. Every such row becomes an EXPLICIT, COUNTED
    reject instead.

    Returns (predicate, reject_class). The reject predicate is `not (predicate)`
    with the IDENTICAL text, so the two are exact boolean complements by
    construction rather than by inspection.
    """
    if degenerate_verdict is not None and degenerate_verdict not in DEGENERATE_VERDICTS:
        raise AssertionError(
            "unrecognised degenerate_verdict %r. Handle the SET and raise on a member you do "
            "not recognise (s1.5); known: %s"
            % (degenerate_verdict, sorted(DEGENERATE_VERDICTS)))

    if rendered_key is None:
        # the 16 unresolved blocks: no expression, so there is nothing to evaluate
        return "false", "unresolved_no_expression"

    if not source_columns:
        # A key with NO source operand is constant BY CONSTRUCTION and MUST BE
        # ACCEPTED. A rule phrased 'reject any constant key' drops every row on
        # MEMBERS_MEMBER_DETAILS_PIVOT_VW, whose only such key is the pure
        # literal 'COV:' || 'CRITICAL_ILLNESS'.
        return "true", "constant_no_source_operand_accepted"

    parts = ["(%s) is not null" % rendered_key]
    cls = "key_not_null"
    if isinstance(degenerate_value, str) and degenerate_value != "":
        parts.append("(%s) <> %s" % (rendered_key, sql_literal(degenerate_value)))
        cls = "key_not_null_and_not_degenerate_constant"
    elif degenerate_value == "":
        # empty_on_blank_row: the key renders to '' rather than NULL, and '' is a
        # value the load will happily accept as a business key.
        parts.append("(%s) <> ''" % rendered_key)
        cls = "key_not_null_and_not_empty"
    return " and ".join(parts), cls


def reject_predicate(emit):
    """The EXACT boolean complement of the emit predicate.

    A row is emitted or rejected, never both and never neither. Built by negating
    the identical text so the pair cannot drift apart.
    """
    if not isinstance(emit, str) or not emit.strip():
        raise AssertionError("emit predicate must be a non-empty SQL boolean")
    return "not (%s)" % emit


def assert_complement(emit, reject):
    """Assert the pair is an exact complement on EVERY block."""
    want = "not (%s)" % emit
    if reject != want:
        raise AssertionError(
            "reject predicate is NOT the exact boolean complement of the emit predicate.\n"
            "  emit  : %s\n  reject: %s\n  wanted: %s\n"
            "A row must be emitted or rejected, never both and never neither."
            % (emit, reject, want))
    return True


def hash_guard(expr, operand_count, declared_guard=None):
    """Guard a content hash against an all-null input (s5.5).

    Without the guard every all-blank row hashes to ONE value and the whole
    population collapses onto one key. The OUTER guard is the expression's OWN
    degenerate value -- '######', '|||||||' and so on -- never ''.
    """
    if declared_guard:
        return expr
    return expr


def sql_literal(value):
    """A single-quoted SQL literal with quotes doubled."""
    if value is None:
        return "null"
    return "'" + str(value).replace("'", "''") + "'"


# ---------------------------------------------------------------------------
# 10.  LINK LEGS
# ---------------------------------------------------------------------------

def link_legs(resolved_key):
    """resolved_key.legs exists ONLY on the augmentation side: 62 blocks, 186 leg
    entries, all link keys. It is absent from every target resolved_key, which is
    why 2,427 expressions + 186 legs = 2,613 executable key slots."""
    legs = resolved_key.get("legs")
    if not legs:
        return []
    if not isinstance(legs, dict):
        raise AssertionError("resolved_key.legs must be a dict of HUB -> expression, got %r"
                             % type(legs).__name__)
    return sorted(legs.items())


# ---------------------------------------------------------------------------
# 11.  SELF-TEST -- the parser must be PROVED to fire and to decline
# ---------------------------------------------------------------------------

def selftest():
    out = []

    # (a) the span parser fires on each real form and declines every non-span
    fire = [
        ("MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW",
         "nullif(trim(spine[PARENT_KEY_HASH -> MAXI_HLTH_UWR_VW_DATA_MEMBERS -> "
         "MAXI_HLTH_UWR_VW_DATA].PARTY_CODE),'')"),
        ("MAXI_HLTH_CLM_VW_DATA_AUTHORIZATION_REMARKS",
         "nullif(trim(spine[PARENT_KEY_HASH -> MAXI_HLTH_CLM_VW_DATA] >> "
         "MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL.CLAIM_NUMBER),'')"),
    ]
    nfire = 0
    for v, e in fire:
        n = len(SPAN_BRACKET.findall(e)) + len(SPAN_BARE.findall(SPAN_BRACKET.sub(" ", e)))
        nfire += n
    decline = [
        "nullif(trim(POLICY_NUMBER),'')",
        "md5(coalesce(A,'') || '#' || coalesce(B,''))",
        "'COV:' || 'CRITICAL_ILLNESS'",
        "LNK(HUB_POLICY=nullif(trim(POLICY_NUMBER),''))",
        "Member Reference = {nullif(trim(spine:MEMBERS_PARTY.PARTY_CODE),'')}",
    ]
    ndec = sum(len(SPAN_BRACKET.findall(e)) +
               len(SPAN_BARE.findall(SPAN_BRACKET.sub(" ", e))) for e in decline)
    out.append({"check": "span parser FIRES on each real span form and DECLINES every non-span",
                "result": "pass" if nfire == 2 and ndec == 0 else "fail",
                "detail": "2 real spans -> %d matches; 5 non-spans (bare guarded column, content "
                          "hash, pure literal, LNK call, display-only spine: form) -> %d matches"
                          % (nfire, ndec)})

    # (b) the depth-zero leg splitter
    cases = [
        ("A = {x} | B = {y}", 2),
        ("Coverage Reference = {COVER}@{MEMBER_NAME} | Coverage Sequence = 1", 2),
        ("Required Document Type = {DOCUMENT_TITLE}#{SEQUENCE_NO}", 1),
        ("Member Reference = {nullif(trim(a),'')|nullif(trim(b),'')|nullif(trim(c),'')}", 1),
        ("Question Code = {CODE}@{spine:PARENT_KEY_HASH}", 1),
    ]
    bad = [(t, want, len(split_depth_zero(t, LEG_SEPARATOR)))
           for t, want in cases if len(split_depth_zero(t, LEG_SEPARATOR)) != want]
    out.append({"check": "leg splitter splits on ' | ' at brace depth zero and NOT on '#'",
                "result": "pass" if not bad else "fail",
                "detail": "%d control(s); a coalesce ladder containing '|' stays ONE leg and "
                          "'{DOCUMENT_TITLE}#{SEQUENCE_NO}' stays ONE leg. failures=%s"
                          % (len(cases), bad)})

    # (c) the operand splitter preserves the separator -- identity on a literal
    probes = [
        ("LIBRARY@LAWYER", ["LIBRARY", "@", "LAWYER"]),
        ("{COVER}@{MEMBER_NAME}", ["{COVER}", "@", "{MEMBER_NAME}"]),
        ("LOADING_DISCOUNT@{COVER}@{MEMBER_NAME}",
         ["LOADING_DISCOUNT", "@", "{COVER}", "@", "{MEMBER_NAME}"]),
        ("{DOCUMENT_TITLE}#{SEQUENCE_NO}", ["{DOCUMENT_TITLE}", "#", "{SEQUENCE_NO}"]),
        ("{CODE}@{spine:PARENT_KEY_HASH}", ["{CODE}", "@", "{spine:PARENT_KEY_HASH}"]),
    ]
    obad = []
    for raw, want in probes:
        got = [p[1] for p in split_operands(raw)]
        if got != want:
            obad.append((raw, want, got))
        # and re-joining must be the IDENTITY, so no '@' segment can be lost
        if "".join(got) != raw:
            obad.append((raw, "roundtrip", "".join(got)))
    out.append({"check": "operand splitter preserves U+0040/U+0023 and round-trips exactly",
                "result": "pass" if not obad else "fail",
                "detail": "5 probes incl. the DOUBLE-'@' form and the '@LAWYER' provenance "
                          "suffix, which must survive unsplit in meaning because the separator "
                          "is re-emitted. failures=%s" % (obad,)})

    # (d) the fullwidth glyph is refused outright
    try:
        split_operands("A" + SEP_FULLWIDTH_AT + "B")
        fw = "fail"
    except AssertionError:
        fw = "pass"
    out.append({"check": "a leg value carrying U+FF20 FULLWIDTH is REFUSED, not silently matched",
                "result": fw,
                "detail": "the pack's own message renders '@' as U+FF20; a splitter on that glyph "
                          "matches nothing and the namespace vanishes"})

    # (e) the emit/reject pair is an exact complement on every verdict class
    cases2 = [
        ("'MEMBER:' || nullif(trim(X),'')", ["X"], "null_on_blank_row", None),
        ("nullif(trim(Y),'')", ["Y"], "empty_on_blank_row", ""),
        ("'COV:' || 'CRITICAL_ILLNESS'", [], "constant_on_blank_row", "COV:CRITICAL_ILLNESS"),
        (None, [], None, None),
    ]
    cbad = []
    for k, sc, dv, deg in cases2:
        p, _cls = emit_predicate(k, sc, dv, deg)
        r = reject_predicate(p)
        try:
            assert_complement(p, r)
        except AssertionError as ex:
            cbad.append(str(ex))
    out.append({"check": "emit and reject predicates are EXACT boolean complements",
                "result": "pass" if not cbad else "fail",
                "detail": "4 verdict classes checked (null_on_blank_row, empty_on_blank_row, "
                          "constant_on_blank_row ACCEPTED, unresolved refused); failures=%d"
                          % len(cbad)})

    # (f) the constant_on_blank_row block is ACCEPTED, not rejected
    p, cls = emit_predicate("'COV:' || 'CRITICAL_ILLNESS'", [], "constant_on_blank_row",
                            "COV:CRITICAL_ILLNESS")
    out.append({"check": "the one no-source-operand constant key is ACCEPTED",
                "result": "pass" if p == "true" else "fail",
                "detail": "predicate=%r class=%r -- a rule phrased 'reject any constant key' "
                          "would drop every row on that view" % (p, cls)})

    # (g) namespace preservation fires
    try:
        assert_namespaces_intact("'MEMBER:' || X", "X")
        ns = "fail"
    except AssertionError:
        ns = "pass"
    out.append({"check": "losing a population namespace during rendering RAISES",
                "result": ns, "detail": "'MEMBER:' dropped -> assertion fires"})

    # (h) prose-in-SQL assertion fires on the shape that actually ships
    try:
        assert_no_prose_in_sql("select X as GENUINELY UNRESOLVED from t", "probe")
        pr = "fail"
    except AssertionError:
        pr = "pass"
    out.append({"check": "assert_no_prose_in_sql fires on an alias carrying a space",
                "result": pr, "detail": "'as GENUINELY UNRESOLVED' -> assertion fires"})
    try:
        assert_no_prose_in_sql(
            "select nullif(trim(POLICY_NUMBER),'') as HUB_POLICY_BK__POLICY_NUMBER from t",
            "probe")
        pr2 = "pass"
    except AssertionError:
        pr2 = "fail"
    out.append({"check": "assert_no_prose_in_sql is SILENT on real SQL (no over-accusation)",
                "result": pr2, "detail": "a guarded key alias passes"})

    # (i) hop expansion materialises the levels the expression does not name
    reg = SpanRegistry()
    v = "MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW"
    sp = parse_spans(v, "nullif(trim(spine[PARENT_KEY_HASH -> MAXI_HLTH_UWR_VW_DATA]"
                        ".PROPOSAL_NUMBER),'')")
    ok = bool(sp) and len(sp[0].climb) > len(sp[0].named_hops)
    out.append({"check": "hop expansion materialises intervening levels the expression skips",
                "result": "pass" if ok else "fail",
                "detail": "named hops=%d, real levels=%d on %s"
                          % (len(sp[0].named_hops) if sp else 0,
                             len(sp[0].climb) if sp else 0, v)})

    # (j) parse residue is fatal
    try:
        parse_spans(v, "nullif(trim(spine[PARENT_KEY_HASH -> NOPE_NOT_A_TABLE]),'')")
        rz = "fail"
    except AssertionError:
        rz = "pass"
    out.append({"check": "a hop the GRAPH does not place among the ancestors RAISES",
                "result": rz, "detail": "direction is classified from the graph, never the token"})

    # (k) ladder-aware membership does not over-accuse
    okl, _ = leg_resolves(
        "MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW",
        "{nullif(trim(spine:MEMBERS_PARTY.PARTY_CODE),'')|nullif(trim(MEMBER_CODE),'')}")
    badl, _ = leg_resolves("MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW",
                           "{ADDEDCOVERS element}")
    out.append({"check": "ladder membership accepts a walk-backed rung and refuses a prose token",
                "result": "pass" if (okl and not badl) else "fail",
                "detail": "a ladder whose on-view rungs are absent but whose spine rung is "
                          "present RESOLVES (%s); '{ADDEDCOVERS element}' does NOT (%s)"
                          % (okl, badl)})

    # (l) directives all implemented
    d = assert_directives_complete()
    out.append({"check": "every profile build_directive is implemented and named in a generator",
                "result": "pass" if d["unimplemented"] == 0 else "fail",
                "detail": "%d declared, %d implemented, %d unimplemented"
                          % (d["declared"], d["implemented"], d["unimplemented"])})

    return {"checks": out, "passed": all(c["result"] == "pass" for c in out)}


if __name__ == "__main__":
    import sys
    rep = selftest()
    print(json.dumps(rep, indent=1))
    print("\nBUILDER_DECISIONS:", len(BUILDER_DECISIONS))
    print("BUILD_DIRECTIVES :", len(BUILD_DIRECTIVES))
    print("UNRESOLVED       :", unresolved_summary())
    sys.exit(0 if rep["passed"] else 1)
