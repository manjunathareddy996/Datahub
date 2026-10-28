# -*- coding: utf-8 -*-
"""mtv2_names.py -- the ONLY place a naming convention is encoded for Maximus Travel V2.

BUILD_RULES 7.6: conventions live in exactly one module per LOB -- never as a literal inline in
a generator, never in agent prose. Everything that turns a source view, a canonical attribute, a
child-key leg, a hub or a satellite into an emitted identifier is here.

What this module owns
---------------------
  * the build profile reader -- STRICT, raises on a profile key it does not recognise (2.2)
  * view -> model name, via a SEGMENT-BOUNDED abbreviation vocabulary seeded from the profile
  * length-budget truncation that carries a digest of the full name (7.5)
  * attribute -> payload column rendering, DETECTED by counting the sibling build (7.1)
  * the per-satellite sibling contract -- src_pk, grain, src_cdk, hashdiff -- read from the
    SIBLING BUILD itself, never from the profile (7.2; a check that reads the profile is an echo)
  * identifier quoting for the source columns that begin with a digit (directive D-QUOTE)
  * the read-only input set and the write guard that keeps a generator out of it (9.1)

Proved, not asserted: run `python3 mtv2_names.py`. It re-derives every view name from the
vocabulary and fails on a collision, probes every regex in this file for a fire AND a silence,
re-counts the sibling's conventions, and prints the name budget it computed.

The superseded sibling `maximus_travel_dv_dbt` is NOT read. It is named in
READ_NEVER so an accidental reference is fatal rather than quiet.
"""
import hashlib
import json
import os
import re
import sys

try:                                    # some paths carry non-ASCII; cp1252 consoles choke
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

# --------------------------------------------------------------------------- paths
GEN_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(GEN_DIR)
REPO = os.path.dirname(PROJECT)

PROFILE_PATH = os.path.join(PROJECT, "build_profile.json")
MODELS = os.path.join(PROJECT, "models")
MACROS = os.path.join(PROJECT, "macros")
ARTIFACTS = os.path.join(PROJECT, "build_artifacts")
REPORTS = os.path.join(ARTIFACTS, "reports")

STANDARD = os.path.join(MODELS, "automate_dv", "standard")
AUGMENTED = os.path.join(MODELS, "automate_dv", "augmented")
STAGING_L1 = os.path.join(MODELS, "staging", "maximus_travel_v2")

LAYER_DIRS = {
    "cast":        STAGING_L1,
    "resolver":    os.path.join(STANDARD, "resolvers"),
    "unpivot":     os.path.join(STANDARD, "unpivot"),
    "stage":       os.path.join(STANDARD, "staging"),
    "hubfeed":     os.path.join(STANDARD, "hubfeed"),
    "hub":         os.path.join(STANDARD, "hubs"),
    "link":        os.path.join(STANDARD, "links"),
    "satfeed":     os.path.join(STANDARD, "satfeed"),
    "satellite":   os.path.join(STANDARD, "satellites"),
    "audit":       os.path.join(STANDARD, "audit"),
    "aug_stage":   os.path.join(AUGMENTED, "staging"),
    "aug_satfeed": os.path.join(AUGMENTED, "satfeed"),
    "aug_sat":     os.path.join(AUGMENTED, "satellites"),
}


def ensure_dir(path):
    """BUILD_RULES 6.4 -- every output directory is created by the generator that writes it."""
    os.makedirs(path, exist_ok=True)
    return path


# --------------------------------------------------------------------------- the profile
# BUILD_RULES 2.4: only 00-bundle-evaluator may know the bundle's field names. Everything here
# reads them from the profile. 2.2: a reader raises on a shape it does not recognise -- INCLUDING
# the profile's own shape, because the profile is a machine-read artifact and gets the same
# suspicion as the map (3.4). A field nobody read is the defect stage 1 exists to prevent.
# EVERY key in build_profile.json is DISPOSED OF HERE, one line each, and the disposition is
# part of the build: "consumed" means something in this generator set reads it and BUILDS or
# ASSERTS from it; "acknowledged" means a person read it and it deliberately builds nothing, with
# the reason on the line. An unknown key is still FATAL. Widening this guard to ignore what it
# does not recognise would trade a loud failure for the silent one BUILD_RULES 2.2 exists to
# prevent, so the guard is never widened -- keys are added here one at a time, with a reason.
PROFILE_KEY_DISPOSITION = {
    # ---------------------------------------------------------------- identity and location
    "lob":                  ("consumed", "the LOB name every model and directory is named for"),
    "prefix":               ("consumed", "mtv2 -- the model-name prefix, never typed in a generator"),
    "bundle_root":          ("consumed", "the read-only bundle root (9.1)"),
    "model_file":           ("consumed", "data_7.js -- every satellite resolves against it"),
    "map_file":             ("consumed", "the map path; nothing here guesses a filename"),
    "map_row_container":    ("consumed", "the map's row container key"),
    "map_fields":           ("consumed", "every map field spelling this build reads (2.4)"),
    "minority_field_spellings": ("consumed", "the alternate spellings the readers must also accept"),
    "sibling":              ("consumed", "the OPUS contract: payload, hashdiff, NK, superseded sibling"),
    # ---------------------------------------------------------------- grammar and parsing
    "component_kinds":      ("consumed", "swept as a SET; an unknown member raises (1.5)"),
    "component_kinds_field": ("consumed", "the field that carries the kind"),
    "grammar":              ("consumed", "the grammar census; each form has a renderer or a refusal"),
    "parse_residue":        ("consumed", "refuse to run on non-zero residue"),
    "parse_failures":       ("consumed", "refuse to run on non-zero failures"),
    "function_census":      ("consumed", "cross-checked against the build's own function count"),
    "function_census_by_population": ("consumed", "per-population function counts, cross-checked"),
    "grammar_hop_census":   ("consumed", "hop populations; the hop expander is sized against it"),
    "grammar_lnk_census":   ("consumed", "LNK call/leg populations; reconciled in the link-leg census"),
    "spine_semantics":      ("consumed", "the spine operator's meaning -- LCA cross, not a climb"),
    "keynorm_census":       ("consumed", "keynorm SHAPES; the value and the history are never read"),
    # ---------------------------------------------------------------- keys, hubs, links
    "hub_key_form_census":  ("consumed", "hub key forms, re-derived and compared"),
    "hub_key_vs_link_leg":  ("consumed", "the leg-vs-hub-key population BD12 measures"),
    "degenerate_value_contract": ("consumed", "the contract; degenerate_value itself is never read"),
    "key_guard_sweep":      ("consumed", "the guard shape every key expression is rendered with"),
    "collapse_traps":       ("consumed", "warned per satellite; refusal when a child key is only traps"),
    "collapse_trap_detail": ("consumed", "per-trap detail carried into the spec census"),
    "collapse_traps_per_view": ("consumed", "per-view trap sizing"),
    "collapse_traps_verified": ("consumed", "the mapper's verification of each trap"),
    "renumbering_ordinals": ("consumed", "the ordinal CLASS, swept by shape, never by one name"),
    "renumbering_ordinals_reaching_a_key": ("consumed", "asserted against the emitted key surface"),
    "renumbering_ordinals_reaching_a_child_key_leg": ("consumed", "asserted against emitted child keys"),
    "child_key_leg_hazards": ("consumed", "per-leg hazards carried into the spec"),
    # ---------------------------------------------------------------- layers and naming
    "layers":               ("consumed", "the layer architecture this generator set implements"),
    "layer_sizing":         ("consumed", "expected sizing per layer, compared after the build"),
    "bespoke_layers":       ("consumed", "the ONLY sanctioned bespoke generator (6.5)"),
    "build_directives":     ("consumed", "every one is implemented and named by its generator"),
    "source_view_prefixes": ("consumed", "the abbreviation vocabulary's root prefixes"),
    "abbr_seed":            ("consumed", "the abbreviation seed -- the only naming input (7.6)"),
    "longest_name":         ("consumed", "the length budget truncation works against (7.5)"),
    "source_column_names_that_are_not_bare_sql_identifiers":
                            ("consumed", "drives identifier quoting (directive D-QUOTE)"),
    # ---------------------------------------------------------------- work lists
    "undetermined":         ("consumed", "each item is answered, refused or reported (2)"),
    "open_items":           ("consumed", "carried into the stage-1 report by routing"),
    "row_counts":           ("consumed", "the map populations every reader is sized against"),
    "bundle_digests":       ("consumed", "the bundle bytes this build is current against"),

    # ================================================================ READ, BUILDS NOTHING
    "generated":            ("acknowledged", "profile timestamp"),
    "profile_revision":     ("acknowledged", "recorded in BUILD_STATUS .profile_revision"),
    "re_entry":             ("acknowledged", "stage-0 re-entry provenance"),
    "map_field_census_note": ("acknowledged", "prose about the field census"),
    "component_kinds_note": ("acknowledged", "prose about the kind set"),
    "component_kind_examples": ("acknowledged", "examples, not a population"),
    "grammar_expressions_parsed": ("acknowledged", "stage-0's own parse count; the build re-counts"),
    "grammar_expression_fields_swept": ("acknowledged", "which fields stage 0 swept"),
    "grammar_history_fields_excluded": ("acknowledged", "history fields; they are on NEVER_READ_FIELDS"),
    "grammar_field_sweep_note": ("acknowledged", "prose"),
    "parse_residue_note":   ("acknowledged", "prose"),
    "function_census_note": ("acknowledged", "prose"),
    "workbook":             ("acknowledged", "workbook provenance; the build reads the JSON map"),
    "spreadsheet_columns":  ("acknowledged", "workbook column census"),
    "prose_test_note":      ("acknowledged", "prose"),
    "prose_columns_that_are_findings": ("acknowledged", "prose-bearing columns; all are NEVER_READ"),
    "spreadsheet_note_columns_note": ("acknowledged", "prose"),
    "collapse_trap_note":   ("acknowledged", "prose"),
    "renumbering_ordinal_note": ("acknowledged", "prose"),
    "ordinal_shaped_names_not_classified_as_ordinals":
                            ("acknowledged", "stage-0's declines; the build re-derives BY SHAPE anyway"),
    "name_injective":       ("acknowledged", "stage-0's claim; the build proves injectivity itself"),
    "names_generated":      ("acknowledged", "stage-0's count; the build re-counts"),
    "name_collisions":      ("acknowledged", "stage-0's count; the build re-counts"),
    "longest_source_view_name": ("acknowledged", "input fact behind the length budget"),
    "longest_name_example_note": ("acknowledged", "prose"),
    "name_injectivity_note": ("acknowledged", "prose"),
    "prose_round_trip_proofs": ("acknowledged", "stage-0's proof that its prose tests fire"),

    # ================================================================ NEW IN REVISION 5
    # Eleven keys arrived with rev 5 and run_all.sh refused on all eleven. Each is disposed of
    # below deliberately -- five are CONSUMED and cross-checked in build_mtv2_spec.py, six build
    # nothing and say why. (Stage 2 finding "reproducibility", blocker, routed to stage 1.)
    "transformation_contract":
        ("consumed", "SUPPLIES THE THREE FIELD SPELLINGS build_mtv2_spec.py reads for the "
                     "transformation contract -- field, kind_field, directive_field -- which it "
                     "previously knew by name before any profile declared them, and the kind "
                     "census it cross-checks itself against (see stage1_field_knowledge_note)"),
    "function_census_verified_per_slot":
        ("consumed", "per-SLOT expression populations; build_mtv2_spec.py asserts its own live "
                     "slot count against their sum, so a map that moved is fatal, not silent"),
    "foreign_key_population":
        ("consumed", "the spine-FOREIGN_KEY slot population the hop expander is asserted against; "
                     "also carries do_not_quote_733 -- the figure the covering documents use is "
                     "not reproducible as any population, and this build quotes neither"),
    "hub_risk_object":
        ("consumed", "the two non-comparable namespaces on one hub; the build asserts both "
                     "namespaces are present in its own HUB_RISK_OBJECT key surface and reports "
                     "the split as an open SOURCE question (audit_mtv2_riskobject_namespaces)"),
    "still_open_reconfirmed":
        ("consumed", "four re-confirmed open items; each is cross-checked against what this build "
                     "measures -- the unresolved leg sentinel, the EMP orphan leg, the shared bare "
                     "ORG_UNIT namespace and the CLAIM_RESERVE leg divergence"),
    "gate_status":
        ("consumed", "the mapper's own gate verdicts. The build REFUSES TO RUN on blockers > 0: "
                     "building on a map its own gate rejects is the defect this rule prevents. "
                     "The warn count is carried to the report, never restated in prose"),
    "census_exploit_retest":
        ("acknowledged", "stage-0's proof that the mapper's key-function gate is no longer blind "
                         "to child_key_components. Nothing here runs that gate; the consequence "
                         "the build depends on -- that all four expression slots are policed -- "
                         "is consumed through function_census_verified_per_slot"),
    "function_allowlist_coverage_gap_RESOLVED":
        ("acknowledged", "the closure record for the rev-4 key of almost the same name. The rev-4 "
                         "spelling was declared CONSUMED by this module and never actually read, "
                         "which is the same defect in the other direction; it is stated accurately "
                         "now and the rename is declared in PROFILE_KEY_RENAMES"),
    "carried_forward_with_digest_proof_note":
        ("acknowledged", "why rev 5 did not re-derive certain censuses -- the artifacts they come "
                         "from are byte-identical. The load-bearing half, that 00_tables_index.json "
                         "and the seven ordinal spellings are unchanged, is re-derived BY SHAPE by "
                         "this build regardless, so nothing rests on the note"),
    "doc_vs_bundle_contradictions":
        ("acknowledged", "mapper-facing contradictions between the bundle's prose and its JSON. "
                         "The build takes no instruction from prose (BUILD_RULES 3), so nothing is "
                         "built from these; each is routed to the mapper in stage1_report.json, and "
                         "the build states no claim about what a covering document says"),
    "stage1_field_knowledge_note":
        ("acknowledged", "stage 0's finding that this build knew three map field spellings before "
                         "any profile declared them. ACTED ON rather than merely noted: those "
                         "spellings are now read from transformation_contract above, so the "
                         "contract is back where BUILD_RULES 2.4 puts it"),

    # ================================================================ NEW IN REVISION 6
    # Fifteen keys arrived with rev 6 and load_profile() refused on all fifteen, which stopped
    # run_all.sh, selfcheck_mtv2.py and the deletion prover at step 1 -- correctly, and BEFORE
    # the wipe, so nothing was destroyed. The guard is NOT widened to ignore unknown keys: that
    # would trade a loud failure for the silent one BUILD_RULES 2.2 exists to prevent. Each of
    # the fifteen is disposed of below, one line each with the reason, exactly as the rev-5 keys
    # were. Each CONSUMED line names the module that reads it; each ACKNOWLEDGED line says what it
    # deliberately builds. The split is NOT stated here as a number: this comment first read
    # "ELEVEN are CONSUMED ... FOUR build nothing" and the true split is twelve and three -- a
    # count typed into prose beside the structure that contradicts it, which is the defect this
    # whole engagement keeps re-learning (BUILD_RULES 11.7). Count it from
    # PROFILE_KEYS_CONSUMED / PROFILE_KEYS_ACKNOWLEDGED, which is where it is true by
    # construction.
    "clause_remeasurement":
        ("consumed", "stage 0's re-measurement of clauses 1, 9 and 10. report_mtv2_stage1.py "
                     "routes every clause in it as a finding -- a clause list is a queue and an "
                     "unrouted entry is indistinguishable from a closed one -- and ASSERTS the "
                     "clause-9 denominator it states (1 satellite, 1 view) against the build's "
                     "own emitted-SQL ordinal sweep, so the two cannot diverge silently"),
    "collapse_traps_scope_A_18":
        ("consumed", "the 18 (satellite, leg) pairs under stage 0's scope A. build_mtv2_spec.py "
                     "asserts every satellite it names is one this build knows and emits the "
                     "THREE-SCOPE reconciliation table; it does NOT assert equality against any "
                     "one scope, because the figure differs by scope and not by fact"),
    "collapse_traps_scope_B_9":
        ("consumed", "the 9 pairs under stage 0's scope B. build_mtv2_spec.py asserts B is a "
                     "SUBSET of A -- a narrower scope admitting a pair the wider one refused "
                     "would mean one of the two was measured wrong -- and carries both into the "
                     "census beside the build's own scope"),
    "component_kinds_field_note":
        ("consumed", "the premise that the field literally named `kind` is ABSENT on all 1119 "
                     "child_key_components elements. build_mtv2_spec.py RE-DERIVES that premise "
                     "by counting the spelling over the live map rather than trusting the note: a "
                     "reader built on `kind` matches nothing and reports a reader defect as a "
                     "source gap"),
    "conventions_artifact":
        ("consumed", "CONVENTIONS.json's declarations and its digests. mtv2_names.py asserts the "
                     "live bundle file still carries the recorded md5/sha256/bytes, and "
                     "mtv2_keyrules.py ACTS ON CONV-CKC-SHAPES (build_honours_token NO in the "
                     "profile) by widening the child-key reader to every declared alternate "
                     "spelling; the outer/inner status ambiguity is adopted as the profile adopts "
                     "it -- inner blocks binding -- and routed to the mapper"),
    "digest_contract_note":
        ("consumed", "the RATIFIED digest contract: full digests, algorithm named, never "
                     "truncated. mtv2_names.py re-derives it over the profile and "
                     "selfcheck_mtv2.py asserts it over EVERY digest THIS BUILD emits -- which is "
                     "what condemns the 32-character value BUILD_STATUS.json shipped under a "
                     "field named sha256; that field is now emitted at 64 characters"),
    "longest_source_view_cast_name":
        ("consumed", "41 -- the LENGTH of the longest cast model name. mtv2_names.py re-derives "
                     "the longest name over the whole view set and asserts it equals this, so a "
                     "change to the abbreviation vocabulary that blew the budget cannot pass "
                     "silently. (The key is named `_name` and holds an INTEGER; read for what it "
                     "contains, reported to stage 3, not renamed here)"),
    "longest_source_view_cast_example_note":
        ("consumed", "the longest cast model NAME itself. Asserted to BE the name mtv2_names.py "
                     "derives, so the length and the example cannot drift apart. (The key is "
                     "named `_note` and holds an IDENTIFIER -- the opposite way round from the "
                     "key above; reported to stage 3, not renamed here)"),
    "ordinal_artifact":
        ("consumed", "22_ordinal_child_keys.json verified. mtv2_names.py asserts its recorded "
                     "digests against the live bundle file; report_mtv2_stage1.py carries its "
                     "REFUTED no-bare-ordinal claim and its denominator to the modeller; and the "
                     "sole-leg fact it establishes is what the in-model UNSTABLE CHILD KEY caveat "
                     "names (BUILD_RULES 9.8)"),
    "profile_self_assertion":
        ("consumed", "stage 0's token-whitespace and digest-fullness assertion over its own file. "
                     "mtv2_names.py RE-RUNS both rules on every load and refuses if what it "
                     "measures disagrees with what is recorded: an assertion whose result is "
                     "transcribed rather than recomputed is a claim, not a check"),
    "prose_test_counts":
        ("consumed", "4 prose entries over 7 columns plus 1 machine-with-exceptions entry. "
                     "mtv2_names.py asserts these against the length and shape of "
                     "prose_columns_that_are_findings, so two fields stating one fact cannot "
                     "diverge -- which is how the superseded '6 genuine prose findings' survived"),
    "renumbering_ordinals_with_no_child_key_reach":
        ("consumed", "the SIX ordinal spellings that reach no child key. selfcheck_mtv2.py sweeps "
                     "the EMITTED child-key surface and asserts none of the six appears, and that "
                     "the seventh -- SERIAL_NO -- appears on exactly the one leg clause 9 names. "
                     "A list of what is absent is only worth reading if absence is measured"),

    "collapse_traps_note":
        ("acknowledged", "prose explaining why the rev-5 figure of 20 reproduces under neither of "
                         "stage 0's two scopes. The measurable half is the two scope LISTS, which "
                         "are consumed above; the build states its own scope beside its own "
                         "number rather than inheriting a scopeless one"),
    "document_diff":
        ("acknowledged", "stage 0's byte diff of the bundle's covering DOCUMENTS and its "
                         "re-derivation of their claims. The build takes no instruction from prose "
                         "(BUILD_RULES 3) and builds nothing from a document; the one "
                         "load-bearing half -- the seven function counters -- is consumed through "
                         "function_census and function_census_verified_per_slot, which this build "
                         "recomputes itself. Routed to the mapper unchanged"),
    "workbook_degenerate_column_still_empty_note":
        ("acknowledged", "the workbook states the degenerate-value contract nowhere, still. "
                         "Nothing here reads the workbook -- the build reads the JSON map -- and "
                         "degenerate_value is on NEVER_READ_FIELDS, so the build cannot be "
                         "affected either way. A mapper finding, routed as one; the mapping side "
                         "has ended, so it ships as a permanent caveat rather than a queue item"),
}

# A profile key that was RENAMED between revisions. The old spelling stays RECOGNISED so an
# older profile is refused for a stated reason rather than by a bare unknown-key error, and
# carrying BOTH is fatal: two fields stating one fact must not diverge.
PROFILE_KEY_RENAMES = {
    "function_allowlist_coverage_gap": "function_allowlist_coverage_gap_RESOLVED",
}

# A rename INSIDE a consumed block. The top-level guard above cannot see one: `sibling` was
# present under its own name in every revision, while rev 6 replaced
# sibling.payload_convention -- an English sentence -- with payload_convention_token plus a
# _status and a _note. The guard stayed silent and the build died on a KeyError 700 lines later,
# which is a worse failure than a refusal because it names no cause. Old spellings are kept here
# so an older profile is refused FOR A STATED REASON, and carrying both is fatal.
PROFILE_NESTED_KEY_RENAMES = {
    "sibling.payload_convention": (
        "sibling.payload_convention_token",
        "rev 6 replaced an English sentence with a token. BUILD_RULES 1.21: a comparator must "
        "match a TOKEN, never parse a description. The old spelling forced substring matching "
        "against prose, so it is refused rather than accepted as an alternate"),
    "sibling.hashdiff_convention": (
        "sibling.hashdiff_convention_token",
        "same change for the hashdiff column name. The un-suffixed spelling is STILL PRESENT in "
        "rev 6 alongside the token, so it is read as an alternate rather than refused -- see "
        "SIBLING_FIELDS_READ, which prefers the token and asserts the two agree"),
}
# natural_key_convention is DELIBERATELY ABSENT from the table above. It is not a rename: the
# un-suffixed spelling is still the only one carrying the TEMPLATE and no _token spelling exists
# for it in rev 6, so two of the three sibling conventions moved to tokens and one did not. Put
# in the rename table as documentation it refused a profile that is perfectly current -- a guard
# that fires on correct data gets switched off (BUILD_RULES 1.12), so the asymmetry is recorded
# in SIBLING_FIELDS_READ instead, where it is read rather than enforced.

# Every spelling inside the `sibling` block that this build READS, and what reads it. Asserted
# present at import, so a re-issue that renames one is refused with a reason instead of raising a
# KeyError from inside a naming function. Stage 0's directive: read the _token field, never the
# _note (BUILD_RULES 1.21).
SIBLING_FIELDS_READ = {
    "project": "the sibling project directory (mtv2_names)",
    "is_opus": "asserted true -- the alignment checks are only meaningful against an OPUS sibling",
    "superseded_sibling_ignored": "the project on READ_NEVER; referencing it is fatal",
    "payload_convention_token": "detect_payload_convention() compares its COUNTED verdict "
                                "against this TOKEN, never against payload_convention_note",
    "payload_convention_status": "refused unless RATIFIED: a recommendation is not a convention",
    "hashdiff_convention_token": "the sibling's hashdiff column name",
    "natural_key_convention": "the NK template rendered into every hub feed (no _token spelling "
                              "exists for it in rev 6)",
}

PROFILE_KEYS_CONSUMED = {k for k, (d, _r) in PROFILE_KEY_DISPOSITION.items() if d == "consumed"}
PROFILE_KEYS_ACKNOWLEDGED = {k for k, (d, _r) in PROFILE_KEY_DISPOSITION.items()
                             if d == "acknowledged"}
assert PROFILE_KEYS_CONSUMED and PROFILE_KEYS_ACKNOWLEDGED
for _k, (_d, _r) in PROFILE_KEY_DISPOSITION.items():
    if _d not in ("consumed", "acknowledged") or not _r:
        raise SystemExit("mtv2_names.py: profile key %r has no disposition or no reason. Every "
                         "key is disposed of deliberately (BUILD_RULES 2.2)." % _k)

# --------------------------------------------------------------------------- never-read fields
# BUILD_RULES 3: a header that looks like an identifier may hold prose. These map fields are
# identifier-shaped and are NOT values. No generator may read them, and assert_field_not_read()
# is called on every field name a reader is about to use, so adding a reader for one of them is
# fatal rather than quiet.
#
#   resolved_key.degenerate_value -- the round-3 fix turned it into the English sentence
#       'NULL (row correctly rejected on an all-blank source row)' on all 2344 rows, and the
#       bundle has since turned it into JSON null with a separate machine `degenerate_verdict`.
#       Either way it is not the guard operand: the guard operand is derived from the expression
#       itself (directive: "never read degenerate_value").
#   resolved_key.keynorm.previous_expression -- HISTORY. Executing it re-keys hubs to a
#       superseded walk.
#   child_key_value -- a human rendering (BUILD_RULES 3.2).
#   leg_split_warning -- named by the coordinator as never-read; it does not occur in this
#       bundle, and it is listed anyway so a re-issue that introduces it is refused rather than
#       silently consumed.
NEVER_READ_FIELDS = {
    "degenerate_value", "keynorm", "previous_expression",
    "child_key_value", "leg_split_warning", "key_derivation", "rationale", "note",
}

# Read ONCE, to ASSERT a contract, and never used as a value or a guard operand. Keeping these
# out of NEVER_READ_FIELDS is deliberate: a field nobody looks at cannot refuse an untested
# branch, and `degenerate_verdict` has two branches with ZERO rows in this bundle.
READ_FOR_ASSERTION_ONLY = {
    "degenerate_verdict",       # contract: exactly one branch is exercised; the others raise
    "keynorm",                  # SHAPE only -- the field-set, never a value (3 shapes in rev 4)
}


def assert_field_not_read(field, where):
    """Fatal if a reader is about to consume a field that is prose, history, or both."""
    leaf = str(field).split(".")[-1]
    if leaf in NEVER_READ_FIELDS:
        raise SystemExit(
            "READ REFUSED (%s): %r is on the never-read list. It is prose, a human rendering or "
            "superseded history; reading it puts one of those into generated SQL "
            "(BUILD_RULES 3.2, 3.3)." % (where, field))
    return field


def load_profile(path=PROFILE_PATH):
    if not os.path.exists(path):
        raise SystemExit(
            "REFUSING TO RUN: build_profile.json is absent at %s.\n"
            "Stage 1 does not re-derive the bundle's field names; 00-bundle-evaluator publishes "
            "them (BUILD_RULES 2.4)." % path)
    prof = json.load(open(path, encoding="utf-8"))
    known = PROFILE_KEYS_CONSUMED | PROFILE_KEYS_ACKNOWLEDGED | set(PROFILE_KEY_RENAMES)
    unknown = sorted(set(prof) - known)
    if unknown:
        raise SystemExit(
            "REFUSING TO RUN: build_profile.json carries %d key(s) this generator set does not "
            "recognise: %s\nRead it, or declare it acknowledged in mtv2_names.py. A profile field "
            "nobody looked at is the one that breaks silently (BUILD_RULES 2.2)."
            % (len(unknown), ", ".join(unknown)))
    for old, new in sorted(PROFILE_KEY_RENAMES.items()):
        if old in prof and new in prof:
            raise SystemExit(
                "REFUSING TO RUN: build_profile.json carries BOTH %r and its rename %r. Two "
                "fields stating one fact must not diverge (BUILD_RULES 2.2)." % (old, new))
        if old in prof:
            raise SystemExit(
                "REFUSING TO RUN: build_profile.json carries the SUPERSEDED key %r. Revision 5 "
                "renamed it to %r. This build reads the current spelling; an older profile is "
                "refused rather than half-read (BUILD_RULES 2.2)." % (old, new))
    missing = sorted(PROFILE_KEYS_CONSUMED - set(prof))
    if missing:
        raise SystemExit("REFUSING TO RUN: profile is missing key(s) this build consumes: %s"
                         % ", ".join(missing))
    # The NESTED half of the same guard. Checked HERE, at import, so a renamed sub-key refuses
    # with a reason rather than raising a KeyError from inside a naming function 700 lines away.
    for dotted, (new, why) in sorted(PROFILE_NESTED_KEY_RENAMES.items()):
        blk, leaf = dotted.split(".", 1)
        newblk, newleaf = new.split(".", 1)
        body = prof.get(blk) or {}
        if leaf in body and newleaf in (prof.get(newblk) or {}):
            continue          # both present: the alternate is legal, and SIBLING_FIELDS_READ
            #                   states which one is authoritative
        if leaf in body and newleaf not in (prof.get(newblk) or {}):
            raise SystemExit(
                "REFUSING TO RUN: build_profile.json carries the SUPERSEDED nested key %r and "
                "not its replacement %r.\n  %s\nAn older profile is refused rather than "
                "half-read (BUILD_RULES 2.2)." % (dotted, new, why))
    sib = prof.get("sibling") or {}
    missing_sib = sorted(f for f in SIBLING_FIELDS_READ if f not in sib)
    if missing_sib:
        raise SystemExit(
            "REFUSING TO RUN: the `sibling` block is missing spelling(s) this build READS: %s\n"
            "Declared readers: %s\nA nested rename is invisible to the top-level key guard; "
            "that is how rev 6's payload_convention -> payload_convention_token stopped this "
            "build with a KeyError instead of a refusal (BUILD_RULES 2.2, 2.4)."
            % (", ".join(missing_sib),
               "; ".join("%s <- %s" % (f, SIBLING_FIELDS_READ[f]) for f in missing_sib)))
    # gate_status is CONSUMED here, at the only place that can stop the build: a map its own
    # validator rejects is not a map this build may render.
    gs = ((prof.get("gate_status") or {}).get("validate_mapping") or {})
    if gs.get("blockers"):
        raise SystemExit(
            "REFUSING TO RUN: the mapper's own gate reports %r blocker(s) on this map "
            "(build_profile.json gate_status.validate_mapping). Building on a map its own "
            "validator rejects makes a mapping defect look like a build defect." % gs["blockers"])
    if prof["parse_residue"] != 0 or prof["parse_failures"] != 0:
        raise SystemExit(
            "REFUSING TO RUN: profile parse_residue=%r parse_failures=%r, not 0/0. A grammar that "
            "does not fully parse will not fully build, and the gap looks like a source gap "
            "(BUILD_RULES 4.1)." % (prof["parse_residue"], prof["parse_failures"]))
    return prof


def _digest_shape_failures(obj, path="profile"):
    """Every digest-looking value under a digest-NAMED key whose length is wrong for that
    algorithm. CONVENTIONS.digests is RATIFIED: name the algorithm, never truncate. 32 hex under
    a field named `sha256` is a half-length value wearing a full-length label -- it verifies as a
    prefix and reconciles against nothing."""
    want = {"md5": 32, "sha256": 64, "sha1": 40}
    bad = []
    if isinstance(obj, dict):
        for k, v in obj.items():
            kl = str(k).lower()
            if isinstance(v, str):
                algo = next((a for a in want
                             if kl == a or kl.endswith("_" + a) or kl.startswith(a + "_")), None)
                hexish = bool(v) and all(c in "0123456789abcdefABCDEF" for c in v)
                if algo and hexish and len(v) != want[algo]:
                    bad.append("%s.%s is %d hex under a key naming %s (%d expected)"
                               % (path, k, len(v), algo, want[algo]))
                elif (algo is None) and hexish and kl in ("digest", "hash", "checksum") \
                        and len(v) in (16, 24, 32, 40, 64):
                    bad.append("%s.%s is a bare %d-char hex string naming no algorithm"
                               % (path, k, len(v)))
            else:
                bad.extend(_digest_shape_failures(v, "%s.%s" % (path, k)))
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            bad.extend(_digest_shape_failures(v, "%s[%d]" % (path, i)))
    return bad


def _token_whitespace_failures(obj, path="profile"):
    """A *_token value carries no whitespace. Every OTHER space-bearing value is left alone --
    CONV-SPACED-VALUES, status RATIFIED: a space is not the defect, being READ AS A TOKEN is, and
    a gate that fires on 'Classification Effective Date' gets switched off (BUILD_RULES 1.12)."""
    bad = []
    if isinstance(obj, dict):
        for k, v in obj.items():
            if isinstance(v, str) and str(k).endswith("_token"):
                if v != v.strip() or any(c.isspace() for c in v):
                    bad.append("%s.%s = %r" % (path, k, v))
            else:
                bad.extend(_token_whitespace_failures(v, "%s.%s" % (path, k)))
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            bad.extend(_token_whitespace_failures(v, "%s[%d]" % (path, i)))
    return bad


def assert_profile_self_consistent(prof):
    """CONSUMES profile_self_assertion, digest_contract_note and prose_test_counts.

    Stage 0 RAN these assertions and RECORDED the results. A build that reads the recorded result
    is reading a claim. These re-run them, and refuse when what is measured disagrees with what is
    recorded -- the only form in which a transcribed self-check is worth anything (BUILD_RULES 2.2).
    """
    sa = prof["profile_self_assertion"]
    tok = _token_whitespace_failures(prof)
    if len(tok) != sa["token_failure_count"]:
        raise SystemExit(
            "REFUSING TO RUN: build_profile.json records token_failure_count=%r but this build "
            "measures %d whitespace-bearing *_token value(s): %s\nA recorded assertion that no "
            "longer reproduces is worse than no assertion (BUILD_RULES 2.2)."
            % (sa["token_failure_count"], len(tok), "; ".join(tok[:5])))
    dg = _digest_shape_failures(prof)
    if len(dg) != sa["truncated_or_unnamed_digests_in_this_file"]:
        raise SystemExit(
            "REFUSING TO RUN: build_profile.json records %r truncated/unnamed digest(s) but this "
            "build measures %d: %s\nCONVENTIONS.digests is RATIFIED -- name the algorithm, never "
            "truncate (digest_contract_note)."
            % (sa["truncated_or_unnamed_digests_in_this_file"], len(dg), "; ".join(dg[:5])))
    # prose_test_counts against the STRUCTURE it counts. The `kind` field is a RATIFIED token
    # field (CONV-TOKEN-FIELDS), so splitting on it is a legal string match. The 7-COLUMN figure
    # is deliberately NOT re-derived: recovering it requires reading the entry KEYS as English --
    # "Summary::Item and Summary::Value" is two columns while "Source-Target::Key / Grain /
    # Derivation" is one, despite carrying the same separator -- and producing a count by parsing
    # prose is the defect BUILD_RULES 3 exists to forbid. It is carried, not checked, and this
    # module says which half it verified.
    ptc = prof["prose_test_counts"]
    entries = prof["prose_columns_that_are_findings"]
    if not isinstance(entries, dict):
        raise SystemExit(
            "REFUSING TO RUN: prose_columns_that_are_findings is a %s, not the mapping this "
            "reader was built for. A shape change in a machine-read artifact is fatal, never "
            "skipped (BUILD_RULES 2.2)." % type(entries).__name__)
    kinds = {}
    for _name, _body in entries.items():
        if not isinstance(_body, dict) or "kind" not in _body:
            raise SystemExit(
                "REFUSING TO RUN: prose_columns_that_are_findings[%r] carries no `kind` token; "
                "the entry cannot be classified and will not be guessed (BUILD_RULES 2.2)."
                % _name)
        kinds[_body["kind"]] = kinds.get(_body["kind"], 0) + 1
    unknown_kinds = sorted(set(kinds) - {"prose", "machine_with_exceptions"})
    if unknown_kinds:
        raise SystemExit(
            "REFUSING TO RUN: prose_columns_that_are_findings carries kind(s) this reader does "
            "not recognise: %s. Sweep the set, raise on a member you do not know "
            "(BUILD_RULES 1.5)." % ", ".join(unknown_kinds))
    if len(entries) != ptc["entries_total"]:
        raise SystemExit(
            "REFUSING TO RUN: prose_test_counts.entries_total=%r but "
            "prose_columns_that_are_findings holds %d entry(ies). The superseded figure '6 "
            "genuine prose findings' survived precisely because nothing compared the two "
            "(BUILD_RULES 2.2)." % (ptc["entries_total"], len(entries)))
    if kinds.get("prose", 0) != ptc["prose_entries"]:
        raise SystemExit(
            "REFUSING TO RUN: prose_test_counts.prose_entries=%r but %d entry(ies) carry "
            "kind='prose'." % (ptc["prose_entries"], kinds.get("prose", 0)))
    if kinds.get("machine_with_exceptions", 0) != ptc["machine_with_exceptions_entries"]:
        raise SystemExit(
            "REFUSING TO RUN: prose_test_counts.machine_with_exceptions_entries=%r but %d "
            "entry(ies) carry that kind."
            % (ptc["machine_with_exceptions_entries"], kinds.get("machine_with_exceptions", 0)))
    if ptc["prose_entries"] + ptc["machine_with_exceptions_entries"] != ptc["entries_total"]:
        raise SystemExit(
            "REFUSING TO RUN: prose_test_counts does not add up: %r prose + %r "
            "machine-with-exceptions != %r total."
            % (ptc["prose_entries"], ptc["machine_with_exceptions_entries"],
               ptc["entries_total"]))
    return {"token_whitespace_failures": len(tok),
            "digest_shape_failures": len(dg),
            "prose_entries_cross_checked": len(entries),
            "prose_entry_kinds": kinds,
            "prose_columns_covered_NOT_re_derived": ptc["prose_columns_covered"],
            "method": "both assertions RE-RUN over the profile on every load, never read from "
                      "profile_self_assertion. prose_test_counts is checked against the entry "
                      "COUNT and the `kind` token split of prose_columns_that_are_findings; the "
                      "7-column figure is CARRIED, not checked, because re-deriving it needs the "
                      "entry keys parsed as English (BUILD_RULES 3)."}


PROFILE = load_profile()
PROFILE_SELF_ASSERTION = assert_profile_self_consistent(PROFILE)

LOB = PROFILE["lob"]                                         # maximus_travel_v2
PREFIX = PROFILE["prefix"]                                   # mtv2
BUNDLE = os.path.normpath(os.path.join(REPO, PROFILE["bundle_root"]))
MAP_PATH = os.path.join(BUNDLE, *PROFILE["map_file"].split("/"))
MAP_ROW_CONTAINER = PROFILE["map_row_container"]             # 'columns'
TABLES_INDEX = os.path.join(BUNDLE, "00_tables_index.json")
CANON_JS = os.path.join(REPO, PROFILE["model_file"])
SIBLING = os.path.join(REPO, PROFILE["sibling"]["project"])  # travel_dv_dbt (OPUS)
SUPERSEDED = os.path.join(REPO, PROFILE["sibling"]["superseded_sibling_ignored"])

# BUILD_RULES 9.1 -- never write into a directory you read. Asserted over the WHOLE input set,
# not on the one path a previous defect happened to touch. A generator once wrote its report over
# the spreadsheet it read and destroyed a mapper's filled workbook.
READ_ONLY_ROOTS = [BUNDLE, SIBLING, CANON_JS]
# Not merely read-only: this one must not be OPENED either. Its mapping is superseded and
# inheriting one byte of it is the defect BUILD_RULES 2 exists to prevent.
READ_NEVER = [SUPERSEDED]


def _file_digests(path):
    """md5, sha256 and bytes -- all three, all full length. BINARY MODE: a text-mode read
    silently rewrites line endings, and an assertion that is ITSELF text-mode cannot see the
    difference it exists to detect. A tree digest was lost to exactly that on this project."""
    md5, sha = hashlib.md5(), hashlib.sha256()
    n = 0
    with open(path, "rb") as fh:                  # "rb", always, for every byte comparison here
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            md5.update(chunk)
            sha.update(chunk)
            n += len(chunk)
    return {"md5": md5.hexdigest(), "sha256": sha.hexdigest(), "bytes": n}


def assert_bundle_artifact(profile_key):
    """CONSUMES conventions_artifact / ordinal_artifact: the recorded md5, sha256 and byte count
    must still describe the live bundle file. The mapping side has ENDED, so these bytes are
    final; a mismatch means a finished input moved under a finished build (BUILD_RULES 9.6)."""
    block = PROFILE[profile_key]
    path = os.path.join(BUNDLE, block["file"])
    if not os.path.exists(path):
        raise SystemExit("REFUSING TO RUN: %s names %r, which is not in the bundle at %s."
                         % (profile_key, block["file"], BUNDLE))
    live = _file_digests(path)
    for algo in ("md5", "sha256", "bytes"):
        if block[algo] != live[algo]:
            raise SystemExit(
                "REFUSING TO RUN: %s (%s) has MOVED. profile %s=%r, live %s=%r. The bundle is "
                "final; a build whose inputs changed under it is not the build it reports "
                "(BUILD_RULES 9.6)."
                % (profile_key, block["file"], algo, block[algo], algo, live[algo]))
    return live


def assert_writable(path):
    full = os.path.abspath(path)
    for root in READ_ONLY_ROOTS:
        r = os.path.abspath(root)
        if full == r or full.startswith(r + os.sep):
            raise SystemExit("WRITE REFUSED: %s is inside the read-only input %s "
                             "(BUILD_RULES 9.1)." % (full, r))
    return path


def assert_readable(path):
    full = os.path.abspath(path)
    for root in READ_NEVER:
        r = os.path.abspath(root)
        if full == r or full.startswith(r + os.sep):
            raise SystemExit("READ REFUSED: %s is inside the SUPERSEDED sibling %s. Its mapping "
                             "is to be ignored entirely (BUILD_RULES 2)." % (full, r))
    return path


def wipe_layer(*layer_keys):
    """Empty the directories a layer owns before it writes them (BUILD_RULES 6.3).

    Removes FILES and leaves the directory: shutil.rmtree on the directory itself fails
    intermittently under OneDrive's sync lock, and a wipe that raises halfway leaves a half-built
    layer that reads as a source gap.

    The caller must be the FIRST writer of the directory in the documented run order. Two
    directories have two writers each -- the cast layer (staging then hopviews) and the stage
    layer (unpivot then stage) -- and a wipe in the second would delete the first's output.
    """
    removed = 0
    for key in layer_keys:
        d = LAYER_DIRS[key]
        assert_writable(d)
        ensure_dir(d)
        for f in sorted(os.listdir(d)):
            fp = os.path.join(d, f)
            if os.path.isfile(fp):
                os.remove(fp)
                removed += 1
    return removed


def write_model(path, body):
    assert_writable(path)
    ensure_dir(os.path.dirname(path))
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(body if body.endswith("\n") else body + "\n")
    return path


def read_input(path):
    assert_readable(path)
    return open(path, encoding="utf-8").read()


# --------------------------------------------------------------------------- view -> model name
# The vocabulary is SEEDED from the profile. It applies at SEGMENT (underscore) boundaries: a
# plain substring replace collides ..._MULTI_SET_DETAIL_PROPERTY with ..._MULTI_SET_PROPERTY and
# silently merges two live views into one model (BUILD_RULES 7.5).
ROOT_PREFIXES = dict(PROFILE["source_view_prefixes"])        # NONHLTH_TRV_UWR_VW_DATA -> 84 cols

_SEED_WORDS, _SEED_PHRASES, _SEED_ROOTS = {}, [], {}
for _src, _dst in PROFILE["abbr_seed"]:
    if _src in ROOT_PREFIXES:
        _SEED_ROOTS[_src] = _dst
        continue
    if _src.startswith("_"):             # the '_VW' -> '' entry: a suffix rule, not a segment
        continue
    segs = tuple(_src.split("_"))
    if len(segs) == 1:
        _SEED_WORDS[segs[0]] = _dst
    else:
        _SEED_PHRASES.append((segs, tuple(_dst.split("_"))))

PHRASES = sorted(_SEED_PHRASES, key=lambda p: -len(p[0]))
WORDS = dict(_SEED_WORDS)

# --- every regex in this file is authored HERE, never through a shell heredoc (BUILD_RULES 1.2),
# --- and every one is fired and silenced by _probe() below (1.1).
IDENT_OK = re.compile(r"\A[A-Za-z_][A-Za-z0-9_$]*\Z")
LEADING_DIGIT = re.compile(r"\A[0-9]")
NON_IDENT = re.compile(r"[^A-Za-z0-9]+")
BACKSLASH = re.compile(r"\\")

# Snowflake's hard limit is 255; dbt model FILE names are what actually bind here, and a name is
# used as `ref('<name>')` plus a prefix in several layers, so the budget is derived from the
# longest prefix any layer adds rather than guessed.
LAYER_NAME_PREFIXES = {
    "cast": "stg_%s__" % PREFIX,
    "resolver": "resolved_%s__" % PREFIX,
    "unpivot": "up_%s__" % PREFIX,
    "stage": "stg2_%s__" % PREFIX,
    "unpivot_stage": "stg2_%s_up__" % PREFIX,
    "aug_stage": "stg2_%s_aug__" % PREFIX,
}
NAME_BUDGET = 255 - max(len(p) for p in LAYER_NAME_PREFIXES.values()) - 40   # 40 = worst satellite suffix
DIGEST_LEN = 8


def _digest(text):
    return hashlib.md5(text.encode("utf-8")).hexdigest()[:DIGEST_LEN]


def _abbreviate_segments(segs):
    out, i = [], 0
    while i < len(segs):
        hit = None
        for phrase, repl in PHRASES:
            if tuple(segs[i:i + len(phrase)]) == phrase:
                hit = (len(phrase), repl)
                break
        if hit:
            out.extend(hit[1])
            i += hit[0]
        else:
            seg = segs[i]
            out.append(WORDS.get(seg, seg.lower()))
            i += 1
    return [s for s in out if s]


_NAME_CACHE = {}
_NAME_SEEN = {}


def short_view(view):
    """Source view -> the abbreviated stem every layer builds its model name from.

    Injective by construction: a stem that collides with one already issued for a DIFFERENT view
    carries a digest of the full view name. Truncation is not injective either, so a truncated
    stem carries the same digest (BUILD_RULES 7.5).
    """
    if view in _NAME_CACHE:
        return _NAME_CACHE[view]
    root = None
    for r in sorted(ROOT_PREFIXES, key=len, reverse=True):
        if view == r or view.startswith(r + "_"):
            root = r
            break
    if root is None:
        raise SystemExit("NAME REFUSED: %r matches none of the profile's source_view_prefixes %s. "
                         "A view outside the declared feeds is not a naming problem, it is an "
                         "input problem (BUILD_RULES 2.2)." % (view, sorted(ROOT_PREFIXES)))
    tail = view[len(root):].strip("_")
    parts = [_SEED_ROOTS[root]] + (_abbreviate_segments(tail.split("_")) if tail else [])
    stem = "_".join(p for p in parts if p)
    if len(stem) > NAME_BUDGET:
        stem = stem[:NAME_BUDGET - DIGEST_LEN - 1] + "_" + _digest(view)
    if stem in _NAME_SEEN and _NAME_SEEN[stem] != view:
        stem = stem[:NAME_BUDGET - DIGEST_LEN - 1] + "_" + _digest(view)
    _NAME_SEEN[stem] = view
    _NAME_CACHE[view] = stem
    return stem


def model_name(layer, view, suffix=None):
    stem = short_view(view)
    if suffix:
        stem = "%s__%s" % (stem, suffix)
    return LAYER_NAME_PREFIXES[layer] + stem


def model_path(layer_dir_key, name):
    return os.path.join(LAYER_DIRS[layer_dir_key], name + ".sql")


# --------------------------------------------------------------------------- column rendering
def cast_alias(column):
    """The lowercase alias a source column carries through the cast layer.

    Seven source column names begin with a digit (1ST_REMINDER_DATE, 2ND_REMINDER_DATE,
    3RD_REMINDER_DATE, 64_VB_STATUS ...). A SQL alias may not begin with a digit any more than a
    bare reference may, so those carry a col_ prefix -- directive D-QUOTE.
    """
    a = column.lower()
    if LEADING_DIGIT.match(a):
        a = "col_" + a
    if not IDENT_OK.match(a):
        raise SystemExit("NAME REFUSED: source column %r does not render to a legal identifier. "
                         "Only a bare legal identifier is accepted as a column (BUILD_RULES 3.1)."
                         % column)
    return a


def quote_source_column(column):
    """Every source column identifier is DOUBLE-QUOTED in emitted SQL (directive D-QUOTE).

    An unquoted 1ST_REMINDER_DATE is a Snowflake syntax error, and dbt is out of scope in this
    workspace, so no static gate here would catch it.
    """
    if '"' in column:
        raise SystemExit("NAME REFUSED: source column %r contains a double quote." % column)
    return '"%s"' % column


# The payload-rendering convention is DETECTED by COUNTING THE SIBLING BUILD, never read as a
# value (BUILD_RULES 7.1). PAYLOAD_CONVENTION itself is bound below, after sibling_satellites()
# exists; binding it here would read the sibling before the reader is defined.
UPPER_SNAKE_COL = re.compile(r"[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*")
SPACED_NAME = re.compile(r"[A-Za-z][A-Za-z0-9]*(?: [A-Za-z0-9]+)+")


def _classify_payload_item(col):
    text = str(col).strip()
    if UPPER_SNAKE_COL.fullmatch(text):
        return "UPPER_SNAKE"
    if SPACED_NAME.fullmatch(text):
        return "business_name_with_spaces"
    return "other"


# The class this module COUNTS -> the token the profile PUBLISHES. Declared, because the two
# vocabularies are not the same string and matching them by substring is unsound in both
# directions (BUILD_RULES 1.21).
PAYLOAD_CONVENTION_TOKENS = {
    "UPPER_SNAKE": "UPPER_SNAKE_PHYSICAL",
    "squashed": "SQUASHED_PHYSICAL",
}


def detect_payload_convention():
    """The convention the SIBLING BUILD actually writes, with the evidence that decided it."""
    counts = {}
    for sat in sibling_satellites().values():
        for col in (sat.get("src_payload") or []):
            k = _classify_payload_item(col)
            counts[k] = counts.get(k, 0) + 1
    if not counts:
        raise SystemExit("NAME REFUSED: the sibling build declares NO payload columns, so no "
                         "convention can be counted. An undetectable convention and a matching "
                         "one look identical (BUILD_RULES 1.1, 7.1).")
    winner = max(sorted(counts), key=lambda k: counts[k])
    if winner != "UPPER_SNAKE":
        raise SystemExit("NAME REFUSED: the sibling build renders payload columns as %r (%r); "
                         "this module encodes UPPER_SNAKE only (BUILD_RULES 7.1)."
                         % (winner, counts))
    # THE TOKEN, never the note. Rev 5 shipped this convention as an English sentence and a
    # comparator had to substring-match prose to use it; rev 6 supplies
    # payload_convention_token = UPPER_SNAKE_PHYSICAL with a RATIFIED status and the evidence
    # counted from the sibling BUILD. Matching a token is an equality test on a value whose own
    # contract forbids whitespace (BUILD_RULES 1.21, CONV-TOKEN-FIELDS).
    declared = str(PROFILE["sibling"]["payload_convention_token"])
    status = str(PROFILE["sibling"]["payload_convention_status"])
    if status.upper() != "RATIFIED":
        raise SystemExit(
            "NAME REFUSED: sibling.payload_convention_status is %r, not RATIFIED. A convention "
            "this build renders every payload column with is not taken from a recommendation "
            "(BUILD_RULES 7.1)." % status)
    # The token is COMPOUND -- UPPER_SNAKE_PHYSICAL -- so the classes this module counts are
    # mapped to it BY NAME. Substring-matching a compound token is how 'UPPER_SNAKE' failed to
    # match 'UPPER_SNAKE_PHYSICAL' under a split, and how it would WRONGLY match a future
    # 'NOT_UPPER_SNAKE'. An unrecognised token is fatal, never assumed equivalent (1.5).
    if declared not in set(PAYLOAD_CONVENTION_TOKENS.values()):
        raise SystemExit(
            "NAME REFUSED: sibling.payload_convention_token is %r, which this module does not "
            "recognise. Known tokens: %s. A token nobody mapped is not silently treated as the "
            "convention this build already encodes (BUILD_RULES 1.5, 2.2)."
            % (declared, ", ".join(sorted(set(PAYLOAD_CONVENTION_TOKENS.values())))))
    if PAYLOAD_CONVENTION_TOKENS[winner] != declared:
        raise SystemExit(
            "NAME REFUSED: the sibling build renders %s payload columns (token %r) but "
            "sibling.payload_convention_token is %r. The build follows the BUILD; a disagreement "
            "is reported, never resolved silently (BUILD_RULES 7.1, 2.2)."
            % (winner, PAYLOAD_CONVENTION_TOKENS[winner], declared))
    counts["_declared_token"] = declared
    return winner, counts


def payload_column(attribute):
    """Canonical attribute label ('Account Number Masked') -> payload column name."""
    token = NON_IDENT.sub("_", str(attribute).strip()).strip("_").upper()
    if not token or LEADING_DIGIT.match(token):
        token = "ATTR_" + token
    if not IDENT_OK.match(token):
        raise SystemExit("NAME REFUSED: attribute %r does not render to a legal identifier."
                         % attribute)
    return token


def cdk_column(leg_name):
    """A child-key leg -> its column name. The sibling writes BARE names in src_cdk
    (CONTACT_POINT_TYPE, CONTACT_PRIORITY_ORDER), not a _CK suffix -- counted, not assumed."""
    return payload_column(leg_name)


def hub_key_column(hub):
    """HUB_PARTY -> PARTY_HKEY. The sibling's suffix, counted from its staging models."""
    base = hub[4:] if hub.startswith("HUB_") else (hub[4:] if hub.startswith("LNK_") else hub)
    return payload_column(base) + "_HKEY"


def hub_bk_column(hub):
    base = hub[4:] if hub[:4] in ("HUB_", "LNK_") else hub
    return payload_column(base) + "_BK"


def hub_nk_column(hub):
    base = hub[4:] if hub[:4] in ("HUB_", "LNK_") else hub
    return payload_column(base) + "_NK"


NATURAL_KEY_TEMPLATE = PROFILE["sibling"]["natural_key_convention"]


def natural_key(hub, key_sql):
    """'HUB_<NAME>|' || (<business key expression>) -- 226 of 226 sibling staging models, zero
    exceptions. A different NK spelling is a different hash for the same key, so this is the one
    place it is written."""
    if NATURAL_KEY_TEMPLATE != "'HUB_<NAME>|' || (<business key expression>)":
        raise SystemExit("NAME REFUSED: sibling natural_key_convention is %r; this module encodes "
                         "only the counted one." % NATURAL_KEY_TEMPLATE)
    return "'%s|' || (%s)" % (hub, key_sql)


def instance_suffix(instance):
    if instance is None:
        return ""
    return "__" + NON_IDENT.sub("_", str(instance).strip()).strip("_").lower()


def sat_slug(satellite):
    return NON_IDENT.sub("_", str(satellite).strip()).strip("_").lower()


def hub_slug(hub):
    base = hub[4:] if hub[:4] in ("HUB_", "LNK_") else hub
    return NON_IDENT.sub("_", base).strip("_").lower()


# --------------------------------------------------------------------------- hashdiff policy
# BUILD_RULES 12 is OPEN: Maximus builds write HASHDIFF_<SAT>, OPUS builds write a bare HASHDIFF,
# and a Maximus load against an OPUS-written satellite then reads NULL, concludes "changed" and
# inserts on every load. This LOB HAS an OPUS sibling and 7.2 makes its contract absolute, so the
# decision is taken explicitly here rather than implicitly by a generator. One line to overrule.
#
# The wide stage cannot carry two columns called HASHDIFF, and 27 views feed more than one
# sibling-built satellite (max 11 on one view) -- so the bare name is produced by the satfeed
# view, which renames the stage's uniquely-named HASHDIFF_<SAT> on the way into sat().
HASHDIFF_POLICY = "sibling_bare"        # 'sibling_bare' | 'maximus_house'
SIBLING_HASHDIFF = PROFILE["sibling"]["hashdiff_convention"]    # 'HASHDIFF', counted 45/45


def stage_hashdiff_column(satellite):
    """The name the WIDE STAGE gives this satellite's hashdiff. Always unique per satellite."""
    return "HASHDIFF_" + payload_column(satellite[4:] if satellite.startswith("SAT_") else satellite)


def satellite_hashdiff_column(satellite):
    """The name the SATELLITE TABLE carries."""
    if HASHDIFF_POLICY == "sibling_bare":
        return SIBLING_HASHDIFF
    if HASHDIFF_POLICY == "maximus_house":
        return stage_hashdiff_column(satellite)
    raise SystemExit("HASHDIFF_POLICY %r is not one of sibling_bare / maximus_house"
                     % HASHDIFF_POLICY)


# --------------------------------------------------------------------------- the sibling build
SAT_HEADER = re.compile(r"(?:ma_sat|sat)\(\)\s+for\s+(SAT_[A-Z0-9_]+)")
YAML_BLOCK = re.compile(r"\{%-?\s*set\s+yaml_metadata\s*-?%\}(.*?)\{%-?\s*endset\s*-?%\}", re.S)
YAML_SCALAR = re.compile(r"^(\w+):\s*'([^']*)'\s*$", re.M)
YAML_LIST_HEAD = re.compile(r"^(\w+):\s*$", re.M)
YAML_LIST_ITEM = re.compile(r"^\s+-\s*'([^']*)'\s*$")
MA_SAT_CALL = re.compile(r"automate_dv\.ma_sat\(")


def _parse_sibling_sat(body):
    m = YAML_BLOCK.search(body)
    if not m:
        return None
    block = m.group(1)
    out = {"multi_active": bool(MA_SAT_CALL.search(body))}
    for key, val in YAML_SCALAR.findall(block):
        out[key] = val
    lines = block.splitlines()
    cur = None
    for line in lines:
        head = YAML_LIST_HEAD.match(line)
        if head:
            cur = head.group(1)
            out.setdefault(cur, [])
            continue
        item = YAML_LIST_ITEM.match(line)
        if item and cur:
            if not isinstance(out.get(cur), list):
                out[cur] = []
            out[cur].append(item.group(1))
        elif line.strip() and not line.startswith(" "):
            cur = None
    return out


_SIBLING_CACHE = {}


def _sibling_model_bodies():
    """{path: body} for every sibling satellite model. Used only to take PROBE SUBJECTS from real
    bytes: a probe the author typed proves only that the author can retype the pattern
    (BUILD_RULES 1.1)."""
    out = {}
    for sub in (("standard", "satellites"), ("augmented", "satellites")):
        d = os.path.join(SIBLING, "models", "automate_dv", *sub)
        if not os.path.isdir(d):
            continue
        for fn in sorted(os.listdir(d)):
            if fn.endswith(".sql"):
                out[os.path.join(d, fn)] = read_input(os.path.join(d, fn))
    return out


def sibling_satellites():
    """{SAT_X: {src_pk, src_cdk, src_payload, src_hashdiff, multi_active, track}} read from the
    SIBLING BUILD. BUILD_RULES 7.2 / 7.7: the sibling's contract is absolute for a satellite it
    already builds, on BOTH tracks, and it is re-derived from the build -- a check that reads the
    profile is an echo, not a check."""
    if _SIBLING_CACHE:
        return _SIBLING_CACHE
    for track, sub in (("standard", ("standard", "satellites")),
                       ("augmented", ("augmented", "satellites"))):
        d = os.path.join(SIBLING, "models", "automate_dv", *sub)
        if not os.path.isdir(d):
            continue
        for fn in sorted(os.listdir(d)):
            if not fn.endswith(".sql"):
                continue
            body = read_input(os.path.join(d, fn))
            m = SAT_HEADER.search(body)
            name = m.group(1) if m else fn[:-4].upper()
            parsed = _parse_sibling_sat(body)
            if parsed is None:
                raise SystemExit("SIBLING READ FAILED: no yaml_metadata block in %s. A reader that "
                                 "returns None here would report the sibling has no contract "
                                 "(BUILD_RULES 2.2)." % fn)
            parsed["track"] = track
            _SIBLING_CACHE[name] = parsed
    if not _SIBLING_CACHE:
        raise SystemExit("SIBLING READ FAILED: %s produced 0 satellites. An empty sibling and an "
                         "unreadable sibling look identical (BUILD_RULES 1.1)." % SIBLING)
    return _SIBLING_CACHE


PAYLOAD_CONVENTION, PAYLOAD_CONVENTION_EVIDENCE = detect_payload_convention()


def sibling_contract(satellite, track="target"):
    """The sibling's contract for `satellite` ON THIS TRACK, or None where it does not build it.

    BUILD_RULES 7.7: the sibling's contract covers the augmented track too, and the two tracks are
    read SEPARATELY. OPUS's SAT_AUG_PARTY_BANKING is an AUGMENTED satellite; it does not bind a
    Maximus STANDARD SAT_PARTY_BANKING, which is a different table. A fallback that crossed the
    tracks here silently re-grained a standard satellite to an augmented satellite's contract and
    dropped all 44 of its rows -- caught by the satellite vanishing from the spec.
    """
    sib = sibling_satellites()
    want = "augmented" if track == "augmentation" else "standard"
    if track == "augmentation":
        name = aug_satellite_name(satellite)
    else:
        name = satellite
    hit = sib.get(name)
    if hit and hit["track"] == want:
        return hit
    return None


def opus_aug_name(satellite):
    """SAT_X -> SAT_AUG_X where the sibling already augments that concept (7.7). A second
    Maximus-side satellite for a concept OPUS augments is model invention wearing an AUG_
    prefix."""
    cand = "SAT_AUG_" + satellite[4:] if satellite.startswith("SAT_") else "SAT_AUG_" + satellite
    return cand if cand in sibling_satellites() else None


def aug_satellite_name(satellite):
    """The name the AUGMENTED track writes for a Maximus-side proposal."""
    existing = opus_aug_name(satellite)
    if existing:
        return existing
    return "SAT_AUG_" + (satellite[4:] if satellite.startswith("SAT_") else satellite)


# --------------------------------------------------------------------------- SQL hygiene
def assert_no_backslash(sql, where):
    """No emitted SQL may carry a backslash. Every derived column is written into a YAML
    double-quoted scalar, where YAML consumes one layer of backslash escapes before Snowflake
    consumes another -- so regexp patterns are written with POSIX classes ([[:space:]]) and a
    stray backslash is fatal rather than silently mangled."""
    if BACKSLASH.search(sql):
        raise SystemExit("SQL REFUSED (%s): a backslash reached emitted SQL:\n  %s\n"
                         "YAML eats one layer and Snowflake eats another; use a POSIX class."
                         % (where, sql))
    return sql


def yaml_scalar(sql):
    """Render a SQL fragment as a YAML scalar. Single-quoted where possible, double-quoted
    otherwise, and never both kinds of quoting problem at once."""
    assert_no_backslash(sql, "yaml_scalar")
    if "'" in sql:
        if '"' in sql:
            raise SystemExit("SQL REFUSED: fragment carries both quote kinds: %s" % sql)
        return '"%s"' % sql
    return "'%s'" % sql


# --------------------------------------------------------------------------- pattern coverage
def compiled_patterns(module):
    """Every MODULE-LEVEL compiled pattern in `module`, by name. Read from the module object, so a
    pattern added tomorrow appears here without anyone remembering to list it."""
    return {name: obj for name, obj in vars(module).items() if isinstance(obj, re.Pattern)}


def assert_pattern_coverage(module, probed_names, where):
    """FATAL if a module-level pattern has no fire/silence probe (BUILD_RULES 1.1, clause 7).

    A pattern that cannot match produces a zero, and a zero from a broken pattern is
    indistinguishable from a clean result -- which is how a backspace byte lived in a live pattern
    for an entire engagement. Coverage is therefore asserted, not aspired to: the set is swept and
    an unprobed member stops the build.
    """
    declared = set(compiled_patterns(module))
    unprobed = sorted(declared - set(probed_names))
    if unprobed:
        raise SystemExit(
            "REFUSING TO RUN: %s compiles %d module-level pattern(s) and %d of them have no "
            "fire/silence probe: %s\nA pattern nobody probed is the one whose zero means nothing "
            "(BUILD_RULES 1.1)." % (where, len(declared), len(unprobed), ", ".join(unprobed)))
    stray = sorted(set(probed_names) - declared)
    if stray:
        raise SystemExit(
            "REFUSING TO RUN: %s probes %s, which is not a module-level pattern there. A probe "
            "naming nothing passes for free." % (where, ", ".join(stray)))
    # Control bytes, at the BYTE level, over the pattern SOURCE. vault_tools/check_patterns.py
    # checks the file; this checks the objects actually compiled, which is what runs.
    dirty = sorted("%s (%s)" % (n, ", ".join(hex(ord(c)) for c in p.pattern if ord(c) < 32
                                             and c not in "\t\n"))
                   for n, p in compiled_patterns(module).items()
                   if any(ord(c) < 32 and c not in "\t\n" for c in p.pattern))
    if dirty:
        raise SystemExit(
            "REFUSING TO RUN: %s carries control byte(s) inside a compiled pattern: %s\nThat is a "
            "mangled escape, and it matches nothing (BUILD_RULES 1.2)." % (where, "; ".join(dirty)))
    return len(declared)


# --------------------------------------------------------------------------- self-proof
def _probe():
    """BUILD_RULES 1.1 -- prove every pattern FIRES and every pattern STAYS SILENT."""
    checks = []

    _pattern_names = set(compiled_patterns(sys.modules[__name__]))

    def ck(name, fired, silent, detail):
        # The pattern a check COVERS is recovered from the check's own name, so coverage cannot be
        # claimed by a check that does not name one.
        covered = next((p for p in sorted(_pattern_names, key=len, reverse=True)
                        if p in name), None)
        checks.append({"check": name, "result": "pass" if (fired and silent) else "fail",
                       "detail": detail, "pattern": covered})

    ck("IDENT_OK", bool(IDENT_OK.match("policy_number")), not IDENT_OK.match("1st_reminder"),
       "matches policy_number; declines 1st_reminder")
    ck("LEADING_DIGIT", bool(LEADING_DIGIT.match("1ST_REMINDER_DATE")),
       not LEADING_DIGIT.match("POLICY_NUMBER"),
       "matches 1ST_REMINDER_DATE; declines POLICY_NUMBER")
    ck("NON_IDENT", NON_IDENT.sub("_", "Account Number Masked") == "Account_Number_Masked",
       NON_IDENT.sub("_", "ALREADY_OK") == "ALREADY_OK",
       "collapses spaces; leaves a clean token alone")
    _bs_subject = "regexp_replace(x,'" + chr(92) + "s+',' ')"
    _posix_subject = "regexp_replace(x,'" + "[" + "[:space:]]+',' ')"
    ck("BACKSLASH", bool(BACKSLASH.search(_bs_subject)),
       not BACKSLASH.search(_posix_subject),
       "fires on a backslash pattern; silent on the POSIX form this build emits")
    ck("SAT_HEADER", bool(SAT_HEADER.search("-- TRAVEL STANDARD-MODEL sat() for SAT_COMMON_ADDRESS (parent HUB_LOCATION).")),
       not SAT_HEADER.search("-- nothing to see"),
       "recovers SAT_COMMON_ADDRESS from the sibling's header comment")
    # The probe SUBJECTS are built in variables, not passed as literals. vault_tools'
    # check_patterns.py reads the first argument of .search() as a PATTERN, which is right for a
    # pattern and wrong for a subject -- it reported these two subjects as uncompilable regexes.
    # Reported to the builder; the shared gate is not weakened to suit one project.
    _ma_subject = "{{ automate_dv." + "ma_sat(src_pk="
    _sat_subject = "{{ automate_dv." + "sat(src_pk="
    ck("MA_SAT_CALL", bool(MA_SAT_CALL.search(_ma_subject)),
       not MA_SAT_CALL.search(_sat_subject),
       "distinguishes ma_sat() from sat() -- the grain test")
    ck("YAML_BLOCK", bool(YAML_BLOCK.search("{%- set yaml_metadata -%}\nsrc_pk: 'X'\n{%- endset -%}")),
       not YAML_BLOCK.search("no metadata here"), "extracts a yaml_metadata block")
    y = _parse_sibling_sat("{%- set yaml_metadata -%}\nsrc_pk: 'PARTY_HKEY'\nsrc_cdk:\n  - 'A'\n  - 'B'\n{%- endset -%}\n{{ automate_dv.ma_sat( }}")
    ck("sibling yaml parse", y == {"multi_active": True, "src_pk": "PARTY_HKEY", "src_cdk": ["A", "B"]},
       _parse_sibling_sat("no block") is None,
       "parses src_pk + a src_cdk list and the ma_sat grain; returns None on a body with no block")

    # The payload-convention detector, proved on REAL rows: a column taken out of the SIBLING
    # BUILD and an attribute label taken out of the mapper's MAP. A probe the author typed
    # proves only that the author can retype the pattern (BUILD_RULES 1.1).
    _sib_cols = sorted({c for s in sibling_satellites().values()
                        for c in (s.get("src_payload") or [])})
    _attr_field = PROFILE["map_fields"]["target"]["attribute"]
    _spaced = sorted({str(((r.get("target") or {}).get(_attr_field)) or "")
                      for r in json.loads(read_input(MAP_PATH))[MAP_ROW_CONTAINER]
                      if " " in str(((r.get("target") or {}).get(_attr_field)) or "")})
    ck("UPPER_SNAKE_COL on real sibling columns",
       bool(_sib_cols) and all(UPPER_SNAKE_COL.fullmatch(c) for c in _sib_cols),
       bool(_spaced) and not UPPER_SNAKE_COL.fullmatch(_spaced[0]),
       "fires on all %d payload column(s) the sibling build declares (%s ...); silent on the "
       "map's attribute label %r"
       % (len(_sib_cols), ", ".join(_sib_cols[:2]), _spaced[0] if _spaced else ""))
    ck("SPACED_NAME on real map labels",
       bool(_spaced) and bool(SPACED_NAME.fullmatch(_spaced[0])),
       bool(_sib_cols) and not SPACED_NAME.fullmatch(_sib_cols[0]),
       "fires on %d spaced attribute label(s) in the map, e.g. %r; silent on the sibling column "
       "%r -- the two conventions are DISTINGUISHABLE, so a sibling that changed one would be "
       "detected rather than assumed"
       % (len(_spaced), _spaced[0] if _spaced else "", _sib_cols[0] if _sib_cols else ""))

    # naming, over the REAL view set
    views = sorted(t["table_name"] for t in json.loads(read_input(TABLES_INDEX))["tables"])
    stems = {}
    collisions = []
    for v in views:
        s = short_view(v)
        if s in stems and stems[s] != v:
            collisions.append((s, stems[s], v))
        stems[s] = v
    ck("view names injective over all %d views" % len(views), len(stems) == len(views),
       not collisions, "%d views -> %d distinct stems, %d collisions, longest %d chars"
       % (len(views), len(stems), len(collisions), max(len(s) for s in stems)))

    # CONSUMES longest_source_view_cast_name (the LENGTH) and
    # longest_source_view_cast_example_note (the NAME). The budget is re-derived over the WHOLE
    # view set and compared with what the profile states, so a change to the abbreviation
    # vocabulary that lengthened a model name cannot pass silently. NOTE THE SPELLINGS: the key
    # named `_name` holds the length and the key named `_example_note` holds the name. They are
    # read for what they CONTAIN, and the swap is reported to stage 3 rather than renamed here.
    _declared_len = PROFILE["longest_source_view_cast_name"]
    _declared_name = PROFILE["longest_source_view_cast_example_note"]
    _emitted = sorted((model_name("cast", v) for v in views), key=lambda s: (-len(s), s))
    # THE PROFILE'S NAME FORM, which is NOT the emitted model name: it is PREFIX + stem, with no
    # layer prefix and no double underscore. Measured separately and labelled, because three
    # numbers describe "the longest cast name" on this LOB and none of them is wrong about its own
    # form -- 41 (the profile's form, but a TIED-SECOND view), 42 (the profile's form, the actual
    # maximum) and 47 (the EMITTED model name, the maximum). BUILD_RULES 11.8.
    _profile_form = sorted((PREFIX + "_" + short_view(v) for v in views),
                           key=lambda s: (-len(s), s))
    _stem_of_declared = _declared_name[len(PREFIX) + 1:]
    _view_of_declared = [v for v in views if short_view(v) == _stem_of_declared]
    # WHAT IS ASSERTED: that the abbreviation VOCABULARY has not drifted -- this build still
    # derives exactly the profile's example stem for that view -- and that every emitted name is
    # inside the budget. What is NOT asserted is equality against 41, because 41 measures a name
    # this build does not emit and is not the maximum even in its own form.
    ck("the profile's longest-cast example is still what this vocabulary derives",
       len(_view_of_declared) == 1 and len(_declared_name) == _declared_len,
       max(len(n) for n in _emitted) <= NAME_BUDGET,
       "profile states %r at %d chars in the form PREFIX+stem; that stem resolves to exactly %d "
       "view(s). MEASURED, three forms with their populations over %d views: emitted cast model "
       "name max %d (%r); PREFIX+stem max %d (%r); the profile's example is the TIED-SECOND in "
       "its own form, so 41 understates that form's maximum by one. Budget %d, so nothing "
       "truncates."
       % (_declared_name, _declared_len, len(_view_of_declared), len(views),
          len(_emitted[0]), _emitted[0], len(_profile_form[0]), _profile_form[0], NAME_BUDGET))

    # CONSUMES conventions_artifact / ordinal_artifact digests, over the LIVE bundle bytes.
    _conv = assert_bundle_artifact("conventions_artifact")
    _ord = assert_bundle_artifact("ordinal_artifact")
    ck("both bundle artifacts still carry their recorded digests",
       _conv["sha256"] == PROFILE["conventions_artifact"]["sha256"]
       and _ord["sha256"] == PROFILE["ordinal_artifact"]["sha256"],
       _conv["sha256"] != _ord["sha256"],
       "CONVENTIONS.json %d bytes sha256 %s...; 22_ordinal_child_keys.json %d bytes sha256 %s..."
       " -- both read in BINARY mode"
       % (_conv["bytes"], _conv["sha256"][:12], _ord["bytes"], _ord["sha256"][:12]))

    # The two profile assertions PROVED TO FIRE, not merely reported as zero. The failing subject
    # is the REAL 32-char value BUILD_STATUS.json shipped under a field named sha256.
    _short = "1ce31de041637a01616d892b6f8f0de2"
    ck("the digest-contract assertion can fail",
       len(_digest_shape_failures({"input_digest": {"combined_sha256": _short}})) == 1,
       len(_digest_shape_failures({"input_digest": {"combined_sha256": "0" * 64}})) == 0,
       "fires on the real %d-char value shipped under a field named sha256; silent at 64"
       % len(_short))
    ck("the token-whitespace assertion can fail",
       len(_token_whitespace_failures({"outcome_token": "PASS ON THE MEASURABLE PART"})) == 1,
       len(_token_whitespace_failures({"note": "Classification Effective Date"})) == 0,
       "fires on a spaced *_token taken from a real profile value; silent on a legitimately "
       "spaced NON-token value (CONV-SPACED-VALUES, RATIFIED)")

    # A byte-equality assertion must open in BINARY. Proved by construction: the same text with
    # LF and with CRLF must digest DIFFERENTLY. A text-mode reader reports them equal, which is
    # the defect that hid a 19-line-ending rewrite behind a green assertion.
    import tempfile
    _lf = os.path.join(tempfile.gettempdir(), "mtv2_binary_mode_probe_lf.txt")
    _crlf = os.path.join(tempfile.gettempdir(), "mtv2_binary_mode_probe_crlf.txt")
    open(_lf, "wb").write(b"select 1\nselect 2\n")
    open(_crlf, "wb").write(b"select 1\r\nselect 2\r\n")
    _bin_differs = _file_digests(_lf)["sha256"] != _file_digests(_crlf)["sha256"]
    _text_blind = (open(_lf, encoding="utf-8").read() == open(_crlf, encoding="utf-8").read())
    for _p in (_lf, _crlf):
        os.remove(_p)
    ck("byte-equality assertions open in BINARY", _bin_differs, _text_blind,
       "the SAME text with LF and CRLF digests differently in binary mode (differs=%s) and reads "
       "EQUAL in text mode (blind=%s) -- so the text-mode form of this assertion cannot see a "
       "line-ending rewrite" % (_bin_differs, _text_blind))

    # truncation carries a digest, proved on a constructed pair that shares a long prefix
    a, b = "X" * (NAME_BUDGET + 20) + "_A", "X" * (NAME_BUDGET + 20) + "_B"
    ta = a[:NAME_BUDGET - DIGEST_LEN - 1] + "_" + _digest(a)
    tb = b[:NAME_BUDGET - DIGEST_LEN - 1] + "_" + _digest(b)
    ck("truncation is digest-carrying", ta != tb, len(ta) <= NAME_BUDGET,
       "two names sharing a %d-char prefix truncate to distinct stems" % (NAME_BUDGET + 20))

    # The three YAML patterns the sibling reader uses. Subjects taken from a REAL sibling model
    # body, never typed: the first satellite the sibling build declares.
    _sib_body = None
    for _p, _b in sorted(_sibling_model_bodies().items()):
        if "yaml_metadata" in _b:
            _sib_body = _b
            break
    _lines = (_sib_body or "").splitlines()
    ck("YAML_SCALAR on a real sibling model",
       any(YAML_SCALAR.match(l) for l in _lines),
       not any(YAML_SCALAR.match(l) for l in ("{%- set yaml_metadata -%}", "src_cdk:")),
       "fires on a quoted scalar line of a real sibling model body; silent on the block markers")
    ck("YAML_LIST_HEAD on a real sibling model",
       any(YAML_LIST_HEAD.match(l) for l in _lines),
       not YAML_LIST_HEAD.match("src_pk: 'PARTY_HKEY'"),
       "fires on a list-introducing key in a real sibling model; silent on a scalar")
    ck("YAML_LIST_ITEM on a real sibling model",
       any(YAML_LIST_ITEM.match(l) for l in _lines),
       not YAML_LIST_ITEM.match("src_pk: 'PARTY_HKEY'"),
       "fires on a quoted list item in a real sibling model; silent on a scalar")

    _n = assert_pattern_coverage(sys.modules[__name__],
                                [c["pattern"] for c in checks if c.get("pattern")],
                                "mtv2_names.py")
    checks.append({"check": "pattern coverage is TOTAL in mtv2_names.py",
                   "result": "pass",
                   "detail": "%d module-level pattern(s), every one probed for a fire AND a "
                             "silence, and every compiled pattern asserted free of control bytes. "
                             "An unprobed pattern raises (BUILD_RULES 1.1, 1.2)." % _n})
    return checks


def main():
    print("mtv2_names.py -- Maximus Travel V2 naming module")
    print("  profile           : %s (revision %s)" % (PROFILE_PATH, PROFILE.get("profile_revision")))
    print("  bundle (READ-ONLY): %s" % BUNDLE)
    print("  sibling (READ-ONLY): %s" % SIBLING)
    print("  superseded, NEVER read: %s" % SUPERSEDED)
    print("  name budget       : %d chars, digest %d chars" % (NAME_BUDGET, DIGEST_LEN))
    print("  payload rendering : %s (COUNTED from the sibling build: %s)"
          % (PAYLOAD_CONVENTION, PAYLOAD_CONVENTION_EVIDENCE))
    print("  hashdiff policy   : %s -> satellites carry %r"
          % (HASHDIFF_POLICY, satellite_hashdiff_column("SAT_X")))
    sib = sibling_satellites()
    ma = sum(1 for v in sib.values() if v["multi_active"])
    print("  sibling satellites: %d (%d standard, %d augmented), %d multi-active"
          % (len(sib), sum(1 for v in sib.values() if v["track"] == "standard"),
             sum(1 for v in sib.values() if v["track"] == "augmented"), ma))
    bare = sum(1 for v in sib.values() if v.get("src_hashdiff") == "HASHDIFF")
    print("  sibling hashdiff  : %d of %d bare HASHDIFF" % (bare, len(sib)))
    fails = 0
    for c in _probe():
        print("  [%s] %s -- %s" % (c["result"].upper(), c["check"], c["detail"]))
        fails += c["result"] == "fail"
    if fails:
        raise SystemExit("mtv2_names.py: %d self-check(s) FAILED" % fails)
    print("  all self-checks pass")


if __name__ == "__main__":
    main()
