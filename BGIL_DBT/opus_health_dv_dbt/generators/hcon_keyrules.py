# -*- coding: utf-8 -*-
"""Grammar parser, key rendering, the child-key reader, the build directives, and the register of
what this build REFUSED to resolve. health_consolidated.

WHAT IS HERE
------------
  * PROFILE               -- the profile, read; a field this module does not recognise RAISES.
  * parse_expression()    -- the five declared grammar forms, swept as a SET; an unrecognised form
                             raises rather than falling through to a default.
  * read_child_key()      -- FOUR child-key fields, THREE states each, and the co-occurrence matrix
                             asserted. NEVER key_name. NEVER child_key_vocabulary.
  * legacy_key_forms()    -- the legacy half of the map carries ZERO resolved_key, so the legacy hub
                             key forms are recovered from health_dv_dbt's EMITTED SQL, READ-ONLY.
  * BUILDER_DECISIONS     -- every call the map left to the builder, with its cost and a one-line
                             switch (s11.5). EMPTIED for this LOB; no other LOB's decisions carried.
  * UNRESOLVED            -- one place, counted and printed, never guessed (s5.6).
  * BUILD_DIRECTIVES      -- all eight profile directives, each naming the module that implements it.
"""
import collections
import glob
import json
import os
import re

import hcon_names as N

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(HERE, os.pardir))
REPO_ROOT = os.path.abspath(os.path.join(PROJECT_ROOT, os.pardir))
PROFILE_PATH = os.path.join(PROJECT_ROOT, "build_profile.json")
MAP_PATH = os.path.join(PROJECT_ROOT, "inputs", "04_column_map.SETTLED_post_stage6_65b.json")
# THE SECOND CONTRACT. The two maps stay SEPARATE on disk by instruction: this build
# consolidates three runs from two independently produced maps, and neither is rewritten to
# suit the other.
DELTA3_MAP_PATH = os.path.join(PROJECT_ROOT, "inputs", "04_column_map.DELTA3.json")
DELTA3_RUN = "opus_health_delta3"
MODEL_PATH = os.path.join(REPO_ROOT, "data_7.js")
REPORTS = os.path.join(PROJECT_ROOT, "build_artifacts", "reports")

# The superseded snapshots are for DIFFING ONLY and are never build inputs. Named here so a name
# cannot be reached by accident through a glob. BOTH are listed: on the re-pin onto the Stage 6 +
# 6.5b map, the previously-settled file became a diff-only snapshot, and a guard that still named
# only the older one would have left the superseded map reachable -- a stale guard reads exactly
# like a passing one.
NEVER_A_BUILD_INPUT = ("04_column_map.PINNED_pre_stage65.json",
                       "04_column_map.SETTLED_post_stage65.json")


def load_profile():
    with open(PROFILE_PATH, encoding="utf-8") as fh:
        return json.load(fh)


PROFILE = load_profile()

# ------------------------------------------------------------- profile field recognition (s2.2)
# The profile is a machine-read artifact and gets the same suspicion as the map: a key this build
# has never looked at is an ASSERTION FAILURE, not something to skip. Skipping is how a build ships
# green while a directive nobody implemented sits in the input.
RECOGNISED_PROFILE_KEYS = {
    "schema_version", "schema_note", "prose_field_allow_list", "prose_field_allow_list_note",
    "lob", "generated", "model_file", "model_file_md5", "scope", "read_only_guard",
    "inputs_pinned", "map_shape", "legacy_half_status", "map_fields", "bundle_prose_fields",
    "component_kinds", "component_kinds_note", "grammar", "grammar_population", "grammar_note",
    "parse_residue", "parse_residue_note", "hierarchy_walk_token", "hierarchy_walk_note",
    "canonical_key", "legacy_key_forms", "per_hub_bk_populations", "per_hub_bk_note",
    "registry_reconciliation", "carried_forward_caveats", "sibling", "shared_vault_tables",
    "r8_source_precedence", "r6_r7_childkeys", "collapse_measurement", "collapse_traps",
    "collapse_traps_note", "renumbering_ordinals", "renumbering_ordinals_note", "layers",
    "layers_note", "bespoke_layers", "layer_plan_one_loader", "build_directives", "open_items",
    "prefix", "prefix_note", "abbr_seed", "name_injective", "longest_name",
    "name_injectivity_note", "spreadsheet_columns", "spreadsheet_columns_note", "undetermined",
    "self_assertion", "matcher_discipline", "instance_labels", "remaining_fan_ins",
    "map_gate_status",
}


def assert_profile_recognised():
    unknown = sorted(set(PROFILE) - RECOGNISED_PROFILE_KEYS)
    if unknown:
        raise AssertionError(
            "UNRECOGNISED PROFILE FIELD(S) %s -- the profile changed and this reader has not. "
            "Re-derive from the new profile and regenerate from empty (s2); do NOT skip the field."
            % unknown)
    missing = sorted(RECOGNISED_PROFILE_KEYS - set(PROFILE))
    if missing:
        raise AssertionError("profile is MISSING field(s) this build depends on: %s" % missing)
    return len(RECOGNISED_PROFILE_KEYS)


# ------------------------------------------------------------------ map field recognition (s2.2)
RECOGNISED_MAP_FIELDS = {
    "row": {"table_name", "column_name", "outcome", "target", "augmentation", "reanchor",
            "confidence", "rationale", "source_run", "legacy_no_resolved_key", "domains", "owner"},
    "target": {"kind", "anchor", "satellite", "attribute", "key_name", "instance", "redundant_of",
               "transformation", "reanchored", "child_key", "child_key_value", "review_corrected",
               "instance_split_resolution", "usage_link_satellite", "usage_child_key",
               "attribute_confidence", "best_home_satellite", "new_satellite",
               "proposed_attribute", "proposed_child_key", "note", "key_derivation", "key_tier",
               "resolved_key", "child_key_vocabulary", "aggregation", "aggregation_of",
               "child_key_components",
               # Stage 6: a GRAIN PROPOSAL, on exactly 1 row --
               # BA_HCP_PROD_8428_GPG_LOADER.MD_SPCL_CONDTN_MEMBER_LEVEL, satellite None,
               # attribute None, rationale 'Per-member special terms have no member-grain home on
               # the policy anchor.' Making a satellite multi-active CHANGES ITS GRAIN, which is a
               # modeller's call and never a builder's (s5.7, and s1.42 as corrected: grain sets
               # the remedy). Read for REPORTING and routed to the modeller; it does NOT make any
               # satellite multi-active in this build.
               "proposed_multi_active",
               # --- delta 3 adds these five on target. The gate RAISES on an unknown field
               # by design (s2.2), so each is listed with its disposition, not skipped.
               "child_key_outcome",      # why a child key resolved or did not; reporting
               "child_key_note",         # prose; never parsed into SQL
               "child_key_legs_absent",  # declared absence of a leg; reporting
               "multi_active",           # delta 3 states grain; data_7.js still governs it
               "rationale"},             # prose
    "augmentation": {"best_home_satellite", "new_satellite", "proposed_attribute",
                     "proposed_child_key", "note", "reason", "proposed", "anchor", "multi_active",
                     "child_key", "tier", "applied", "child_key_value", "child_key_vocabulary",
                     "child_key_components", "instance", "redundant_of", "key_derivation",
                     "key_tier", "resolved_key",
                     # delta 3 adds the same three here
                     "child_key_outcome", "child_key_note", "child_key_legs_absent"},
    # delta 3 adds `note` here -- prose, never read into SQL
    "resolved_key": {"hub", "instance", "tier", "expression", "source_columns", "note",
                     "key_reject_declaration", "degenerate_value", "legs"},
    # Stage 6 + 6.5b added thirteen reanchor fields and one target field. The gate refused the
    # build until each was given a disposition; NONE is skipped (s2.2). Dispositions, measured:
    #   DECISION, already applied in target/augmentation -- new_anchor (22), new_satellite (22).
    #       Verified: the settled map shows exactly 22 satellite changes and 22 anchor changes
    #       against the pre-Stage-6 snapshot, the SAME 22 rows, so these restate what the target
    #       block already carries. Read for REPORTING only; the build keys off target/augmentation
    #       as before, so a disagreement between the two cannot silently re-home anything.
    #   ASK REGISTER -- key_recovery_needed (646 rows, {hub, view}), hubs_keyed_on_view (668).
    #       These are the counterparty's key-recovery asks and the per-view keyed-hub census. Read
    #       for REPORTING and routing. hubs_keyed_on_view is NOT a key: it names WHICH hubs are
    #       keyed, never HOW, so it cannot supply an expression (s3 -- never synthesise a key).
    #   PROVENANCE, prose-capable, denied into SQL -- reason, resolved, stage,
    #       candidate_hosts_considered, original_anchor, original_satellite, original_child_key,
    #       original_child_key_value, original_key_derivation. The original_* family records the
    #       pre-Stage-6 state; reading any of it as current would resurrect a withdrawn value.
    "reanchor": {"suggested_anchor", "resolved_by", "resolution", "note",
                 "stage4_note_retained_for_audit",
                 # decisions, restated (already applied in target/augmentation)
                 "new_anchor", "new_satellite",
                 # the ask register
                 "key_recovery_needed", "hubs_keyed_on_view",
                 # provenance of the Stage 6 / 6.5b pass
                 "reason", "resolved", "stage", "candidate_hosts_considered",
                 "original_anchor", "original_satellite", "original_child_key",
                 "original_child_key_value", "original_key_derivation",
                 "resolution_note"},      # delta 3; prose
    # `leg` is delta 3's spelling of `name`. The 115 map writes
    # {name, value, resolved_on_view}; delta 3 writes {leg, value, resolved_on_view} -- same
    # concept, one field renamed. Both are accepted and NEITHER map is edited: a map is a
    # counterparty artifact, and rewriting one to suit this build would put it out of step
    # with its own publisher. norm_component() below gives readers one shape.
    "component": {"name", "leg", "value", "resolved_on_view", "note"},
    "reject_declaration": {"slot", "class", "operands", "disposition", "reject_rule",
                           "degenerate_value", "reclassified_from"},
}

# PROSE, denied BY CLASS not by suffix. Never read into SQL, at any depth.
# profile.bundle_prose_fields lists eight. This build MEASURED a NINTH the profile's census omits:
# target.reanchored carries prose on 124 of its 231 populated rows (True on the other 107), so it
# is three-state and is denied here as well. Reported as a finding, not silently absorbed.
PROSE_DENY = {
    "rationale", "key_derivation", "transformation", "note", "reason", "proposed",
    "stage4_note_retained_for_audit", "resolution", "resolved_by", "suggested_anchor",
    "key_name",                      # a HUB business-key NAME; 184 of 306 carry parenthesised prose
    "child_key_vocabulary",          # a CONVENTION TOKEN ('canonical_source_column_prefix_token')
    "reanchored",                    # three-state: True, or a Stage-6.5 sentence
    "instance_split_resolution", "review_corrected", "attribute_confidence",
}

# NEVER read as a child key. Both have been proposed as one; both would push prose into SQL.
NEVER_A_CHILD_KEY = ("key_name", "child_key_vocabulary")

# THE child-key family. FOUR fields, complementary, not alternatives.
CHILD_KEY_FAMILY = ("child_key", "child_key_value", "child_key_components", "usage_child_key")

# MEASURED on the settled map this run. A combination outside this table is a FAILURE: the reader
# has met a shape it was not designed for, and guessing is how a two-field reader drops the 48
# containers that carry child_key ALONE.
# RE-PINNED onto the Stage 6 + 6.5b map (04_column_map.SETTLED_post_stage6_65b.json,
# md5 cd8e0261eb9761abf8ef72db49532fad). The previous table described the pre-Stage-6 map and the
# assertion correctly FAILED THE BUILD rather than letting 645 new child keys arrive unannounced.
#
# The novel-SHAPE check passed on the new map -- no combination this reader has never met -- so
# only counts moved, and they balance exactly:
#     ()                                 3426 -> 2739   -687
#     ('child_key','child_key_value')     248 ->  893   +645   fully resolved
#     ('child_key',)                       48 ->   90   + 42   leg NAMED, no value
#     139 / 116 / 34 / 21                       unchanged
#     containers                         4032 == 4032
# -687 == +645 + 42, and the +645 reproduces an independent per-row measurement of
# child_key_value gains taken from the two map snapshots. The +42 are the class the register calls
# leg_no_value -- WORSE than absent, because a named empty leg reads as RESOLVED to every gate --
# so the growth in ('child_key',) is tracked here deliberately and is not a rounding detail.
CHILD_KEY_COOCCURRENCE = {
    # RE-PINNED for the MERGED population: the 115 contract plus delta 3, read as two
    # separate maps. Per shape: 115 + delta3 = merged, and the arithmetic closes on every
    # row, which is what makes the figure checkable rather than asserted.
    ():                                                     3178,   # 2739 +  439
    ('child_key', 'child_key_value'):                        895,   #  893 +    2
    ('child_key', 'child_key_value', 'child_key_components'):   188,   #  139 +   49
    ('child_key_value', 'child_key_components'):             173,   #   21 +  152
    ('child_key',):                                          130,   #   90 +   40
    ('child_key_value',):                                    119,   #  116 +    3
    ('usage_child_key',):                                     34,   #   34 +    0
}

THREE_STATES = ("ABSENT", "PRESENT_NULL", "STRING_None", "POPULATED")

# ------------------------------------------------------------------------------ the grammar
# FIVE forms, swept as a SET (s1.5). Order matters only because LNK( and md5(normalise( are more
# specific than coalesce(; the classifier asserts exactly one form matches, so a reordering cannot
# silently change a classification.
GRAMMAR_FORMS = ("LNK_composite", "md5_normalise_upper", "nullif_concat_namespaced",
                 "nullif_trim_bare", "coalesce_lead")
RX_FORM = {
    "LNK_composite": re.compile(r"^LNK\("),
    "md5_normalise_upper": re.compile(r"^md5\(normalise\(upper\("),
    "nullif_concat_namespaced": re.compile(r"^nullif\('"),
    "nullif_trim_bare": re.compile(r"^nullif\(trim\("),
    "coalesce_lead": re.compile(r"^coalesce\("),
}
FORM_SEMANTICS = {
    "LNK_composite": "link",
    "md5_normalise_upper": "content_hash",
    "nullif_concat_namespaced": "business_key_expression",
    "nullif_trim_bare": "business_key_expression",
    "coalesce_lead": "business_key_expression",
}
# WALK OPERATORS. Swept and PROVEN ZERO rather than omitted (s6, coordinator decision 3).
WALK_OPERATORS = ("spine[", ">>", "->", "ancestor(", "parent(")
RX_LNK_LEG = re.compile(r"(HUB_[A-Z0-9_]+|LNK_[A-Z0-9_]+)\s*=\s*")

# key_derivation discriminator markers. PROSE field, read ONLY as an exact bracketed token and
# NEVER rendered. Swept as a set; an unrecognised marker raises.
RX_CK_MARKER = re.compile(r"childkey\[([a-z_]+)\]")
# Stage 6 + 6.5b added a FIFTH marker. Measured over the settled map:
#     column_as_instance   614      named_discriminator  227
#     source_gap            58      single_active         25      reroute  12
#
# reroute: 12 rows on 11 views where Stage 6.5b re-homed a row to a DIFFERENT satellite and
# carried the discriminator Stage 6 had resolved onto the NEW satellite's declared child key
# (SAT_POLICY_CERTIFICATE 10, SAT_POLICY_INSTALMENT_SCHEDULE 1, SAT_RISK_HEALTH_MEMBER_MEDICAL 1).
# The counterparty's own derivation text calls it an "UNRATIFIED identity claim" -- that the
# discriminating column means the same thing on the satellite it moved TO as on the one it came
# FROM. That is a claim about identity, not about rendering, and the map cannot settle it.
#
# It is recognised here so the sweep is complete (s1.5), and classified as NOT RESOLVED:
# CK_MARKERS_UNRESOLVED below drives refuse-and-declare. A wrong child key is unrecoverable after
# load, and an ordinal or a certificate discriminator re-homed across a grain boundary is exactly
# the renumbering-ordinal class already OPEN and blocking on this estate.
CK_MARKERS = ("column_as_instance", "named_discriminator", "single_active", "source_gap",
              "reroute")
# Markers that do NOT constitute a resolved child key. single_active and source_gap are the
# counterparty's own declared absences; reroute is an unratified identity claim.
CK_MARKERS_UNRESOLVED = ("single_active", "source_gap", "reroute")

# Reject classes declared inside resolved_key.key_reject_declaration. SWEPT FROM THE FIELD, never
# named from the profile: the profile shows these only inside truncated samples, from which three
# are visible, and the sweep assertion found a FOURTH (content_hash_composite_guarded, 33
# declarations). An unrecognised member raises; it is not skipped.
REJECT_CLASSES = ("single_operand_guarded", "content_hash_composite_guarded",
                  "composite_sentinel_live", "composite_null_annihilating",
                  # --- DELTA 3 adds six names. Measured over its 458 declarations: ALL
                  # SEVEN of its classes carry disposition "reject", the same as the four
                  # above, so these are new NAMES for behaviour this build already
                  # implements -- additive, and no emitted SQL changes because of them.
                  "namespaced_single_operand",            # 81, degenerate_value null
                  "content_hash_per_operand_guarded",     # 18, degenerate_value present
                  "content_hash_role_scoped_guarded",     # 17, degenerate_value present
                  "content_hash_single_operand_guarded",  #  6, degenerate_value null
                  "link_per_leg_guarded",                 #  1
                  "link_single_leg")                      #  1
# ONE TEXT DEFECT, reported and not acted on. Every namespaced_single_operand declaration
# carries the rule text "Single guarded operand, NO NAMESPACE, so the expression degenerates
# to NULL rather than to a constant" -- while the expression it describes IS namespaced,
# e.g. nullif('PARTNER:' || nullif(trim(PARTNER_ID),''), 'PARTNER:'). The text looks
# copy-pasted from single_operand_guarded. It does NOT change the outcome: on a blank
# operand the row rejects under BOTH concat semantics -- NULL-propagating gives NULL, and
# empty-string concat gives the sentinel which the outer nullif then nulls. Disposition
# "reject" and degenerate_value null are both correct. Raised in the handback.
REJECT_DISPOSITIONS = ("reject",)
REJECT_DECL_KEYS = ("slot", "class", "operands", "disposition", "reject_rule",
                    "degenerate_value", "reclassified_from")
# slot is a FREE-FORM path, not an enum: 'expression', 'legs.HUB_PARTY' and
# 'expression:LNK leg HUB_PARTY' all occur. It is matched by SHAPE, never by equality to a literal.
RX_REJECT_SLOT = re.compile(
    r"^(?:expression|legs\.[A-Z0-9_]+)(?::LNK leg (?:HUB|LNK)_[A-Z0-9_]+)?$")


def assert_reject_declaration(d, where):
    """Sweep one reject declaration. Every kind handled; an unrecognised member raises (s1.5)."""
    if not isinstance(d, dict):
        raise AssertionError("reject declaration at %s is %r, not a dict" % (where, type(d)))
    unknown = sorted(set(d) - set(REJECT_DECL_KEYS))
    if unknown:
        raise AssertionError("UNRECOGNISED reject-declaration key(s) %s at %s" % (unknown, where))
    if d.get("class") not in REJECT_CLASSES:
        raise AssertionError("UNRECOGNISED reject class %r at %s -- sweep the set, do not skip "
                             "the member (s1.5). Known: %s"
                             % (d.get("class"), where, list(REJECT_CLASSES)))
    if d.get("disposition") not in REJECT_DISPOSITIONS:
        raise AssertionError("UNRECOGNISED reject disposition %r at %s" % (d.get("disposition"),
                                                                          where))
    slot = d.get("slot")
    if not isinstance(slot, str) or not RX_REJECT_SLOT.match(slot):
        raise AssertionError("reject-declaration slot %r at %s has a shape this reader has not "
                             "met" % (slot, where))
    ops = d.get("operands")
    if not isinstance(ops, list) or not ops:
        raise AssertionError("reject declaration at %s names no operand" % where)
    return d

# ============================================================== BUILDER DECISIONS
# EMPTIED at the start of this LOB. No decision from health_dv_dbt, opus_health_v2 or any maximus
# sibling is carried in. Each is ONE LINE to overrule (s11.5).
BUILDER_DECISIONS = [
    {
        "id": "BD1-hashdiff-name",
        "attribution": "mapper-ratified",
        "decision": "Hashdiff column is <SAT>_HASHDIFF, not a bare HASHDIFF.",
        "why": "The two originals disagree and s7 cannot decide between two equally-entitled "
               "siblings: legacy writes a bare HASHDIFF and never a suffixed one, v2 "
               "the exact reverse -- counts taken from build_profile.json "
               "sibling.hashdiff_evidence. A bare name collides the moment ONE model "
               "computes hashdiffs for more than one satellite, which is what a multi-feed "
               "consolidated stage does. s12 already records the bare form as the OPUS spelling "
               "implicated in the shared-vault divergence debt.",
        "costs": "The estate gains a third project using the suffixed form, so a future shared "
                 "loader spanning this project and legacy must translate one name. Nothing is "
                 "loaded, so the change costs nothing TODAY; it costs a translation LATER.",
        "overrule_with": "hcon_names.hashdiff() -> return 'HASHDIFF'",
        "profile_status": "profile records RECOMMENDED_NOT_RATIFIED; ratified by the coordinator "
                          "this run and recorded here because a decision taken in a message and "
                          "not written down is a decision nobody can overrule.",
    },
    {
        "id": "BD2-legacy-key-archaeology",
        "attribution": "mapper-ratified",
        "accepted_note": "ACCEPTED by the mapping counterparty and retained, labelled "
                         "UNVALIDATABLE-AGAINST-THE-BUNDLE.",
        "decision": "Legacy hub key expressions are recovered from health_dv_dbt's EMITTED SQL "
                    "(read-only), because the legacy half of the map carries zero resolved_key.",
        "why": "Open item R4-builder, proposed_default: 'the build is the authority, not the map'. "
               "Without this, EVERY row of the legacy half has no hub key and every shared "
               "loader loses its legacy feed -- which would silently convert a consolidation "
               "into a v2-only build. Rows per run are taken from build_profile.json "
               "map_shape.by_source_run and the loader partition from "
               "build_profile.json layer_plan_one_loader.",
        "costs": "The recovered expression is what legacy's generator EMITTED, not what any map "
                 "declares, so it cannot be validated against the bundle. The legacy HASH VALUES "
                 "are NOT reproduced (legacy hashes inside automate_dv macros whose algorithm is "
                 "INFERRED_NOT_DOCUMENTED); only the BUSINESS KEY EXPRESSION is carried over, "
                 "re-hashed in the canonical explicit form. Legacy's loaded keys and this "
                 "project's keys are therefore NOT comparable, which is harmless only because "
                 "this is a greenfield third project.",
        "overrule_with": "hcon_keyrules.LEGACY_ARCHAEOLOGY_ENABLED = False  (legacy feeds then "
                         "go to UNRESOLVED and every shared loader becomes v2-single-feed)",
    },
    {
        "id": "BD3-no-datatype-catalogue",
        "attribution": "builder",
        "decision": "Layer-1 casts every source column to varchar.",
        "why": "The pinned bundle contains NO datatype catalogue -- ten files, none a schema. v2's "
               "staging carries cast(... as date)/(... as number) because v2's bundle had one. "
               "Inventing a type from a column name is a fabricated datum.",
        "costs": "Every staged column is a string, so downstream date and numeric semantics are "
                 "lost at layer 1 and any arithmetic must cast again. Hashing is unaffected "
                 "(every hash operand is cast to varchar anyway).",
        "overrule_with": "gen_hcon_staging.TYPE_FOR_COLUMN -- supply a catalogue and return a type",
    },
    {
        "id": "BD4-model-layout",
        "attribution": "builder",
        "decision": "Models are laid out as v2 does -- models/vault/{hubs,hub_feeds,links,"
                    "satellites,refs}, models/augmented, models/{staging,stage,unpivot,reject_log} "
                    "-- NOT under models/automate_dv/.",
        "why": "This project declares NO packages and invokes no automate_dv macro (build "
               "directive 6). A directory named automate_dv would assert a dependency that does "
               "not exist.",
        "costs": "STATED PLAINLY: vault_tools/check_vault_alignment.py globs "
                 "models/automate_dv/*/satellites/*.sql and therefore reaches ZERO files in this "
                 "layout. That gate's satellite comparison is VACUOUS here and is reported as "
                 "NOT RUN, never as PASS. check_hcon_payload_naming.py was written to cover the "
                 "payload-naming half against BOTH originals. Choosing the automate_dv path "
                 "instead would re-enable the gate at the price of a directory name that lies.",
        "overrule_with": "gen_hcon_vault.VAULT_DIR = 'automate_dv/standard'",
    },
    {
        "id": "BD5-source-per-run",
        "attribution": "builder",
        "decision": "Each run gets its own dbt source name: source('opus_health_legacy_v4', T) and "
                    "source('opus_health_v2', T).",
        "why": "The two runs share NO table name at all -- per-run table counts and their zero "
               "overlap are taken from build_profile.json map_shape -- but they are two different "
               "landing areas. One source name would assert they land together.",
        "costs": "Two source blocks to configure before this project can run. dbt is out of scope "
                 "here, so nothing resolves them in this build.",
        "overrule_with": "gen_hcon_staging.SOURCE_NAME_FOR_RUN -- return one constant",
    },
    {
        "id": "BD6-r8-precedence-order",
        "decision": "Where both runs write one attribute, the declared precedence is V2 FIRST, "
                    "then legacy: coalesce(v2_value, legacy_value).",
        "why": "v2 is the closed, settled half (profile legacy_half_status.v2_half_token = "
               "SETTLED, no Stage-9 blockers) while EVERY pre-stage-6.5 blocker and EVERY "
               "target_validity and handoff_outcome_contract finding came from the legacy half, "
               "as recorded in build_profile.json open_items. Neither run is declared "
               "authoritative ANYWHERE in the bundle, so this "
               "is a builder call and not a reading of the map.",
        "costs": "WHERE LEGACY IS RIGHT AND V2 IS WRONG, THIS PICKS THE WRONG VALUE. The size "
                 "of the exposure is taken from BUILD_STATUS.json r8 and build_profile.json "
                 "r8_source_precedence. It is a VALUE choice, never a key change and never "
                 "RECORD_SOURCE in a key, so it cannot alter grain and is reversible by reload.",
        "overrule_with": "hcon_keyrules.R8_PRECEDENCE = ('opus_health_legacy_v4', 'opus_health_v2')",
        "attribution": "builder-overruled-by-mapper",
        "overruled_note": "The mapping counterparty overruled the SILENCE, not the precedence. "
                          "The mechanism stays deterministic v2 > legacy; what changed is that on "
                          "every shared object written by BOTH runs the subordinate writer and "
                          "its registry are NAMED in the satellite header, and a load-time "
                          "assertion counts whether the precedence ever fires at all. An earlier "
                          "form of the overrule asked for both values to be emitted and was "
                          "withdrawn: two writers into one row per key is load-order-dependent "
                          "and strictly worse than a deterministic choice.",
    },
    {
        "id": "BD7-refuse-not-coin",
        "attribution": "mapper-ratified",
        "decision": "A child-key leg that is NAMED but whose value is absent or of the wrong kind "
                    "is REFUSED, and the satellite is built WITHOUT that leg, with the refusal in "
                    "its header and in the unresolved-grain register.",
        "why": "Build directive 3, and s5.7: the map is not corrected here. The THREE legacy "
               "sub-populations -- nothing-at-all, leg-named-but-no-value, and "
               "leg-named-with-a-value-of-the-wrong-kind -- are counted in BUILD_STATUS.json "
               "and in reports/declared_unresolved_grain_hcon.json. None of the three yields a "
               "discriminator without inventing one.",
        "costs": "Those satellites LOSE GRAIN: rows that differ only in the refused leg collapse "
                 "onto one hash key. The collapse is DECLARED and countable rather than hidden, "
                 "which is the only property available here -- the alternative is a fabricated "
                 "discriminator that no gate can see.",
        "overrule_with": "hcon_keyrules.REFUSE_UNRESOLVED_LEGS = False (and then every collapsed "
                         "row is a silent data loss)",
    },
    {
        "id": "BD8-ordinal-legs-are-not-hub-grade",
        "attribution": "builder",
        "decision": "A renumbering-ordinal leg is built when the map supplies its value, and its "
                    "instability is stated in the satellite header; it is never synthesised.",
        "why": "The unstable legs are named in build_profile.json renumbering_ordinals: "
               "Contact Priority Order, Coverage "
               "Sequence, Role Sequence, Active Sequence Number. Each changes when a sibling row "
               "is added or removed, so none is hub-grade -- a renumbering ordinal breaks a child "
               "key exactly as it breaks a hub key.",
        "costs": "A source renumbering rewrites history on the affected satellites. Declared in "
                 "the header so the instability is visible before load, not after.",
        "overrule_with": "hcon_keyrules.ORDINAL_LEGS_ALLOWED = False (those legs then refuse)",
    },
    {
        "id": "BD6b-delta3-ranked-last",
        "attribution": "builder",
        "decision": "The third run, opus_health_delta3, is ranked LAST in the declared precedence: "
                    "coalesce(v2_value, legacy_value, delta3_value).",
        "why": "MEASURED, not preferred. Delta 3 co-writes 79 of the 594 (satellite, attribute) "
               "pairs in the merged map -- 34 with legacy alone, 33 with both, 12 with v2 alone -- "
               "so the rank FIRES and is a real value choice. BD6 ranked v2 above legacy because "
               "v2 is the SETTLED half, NOT because it is newer; delta 3's settledness is "
               "established NOWHERE in its bundle, so there is no basis on BD6's own stated "
               "principle to rank it above either existing run. Ranking it first would change the "
               "chosen value on all 79 pairs the 115 build already emits, including Party Full "
               "Name, Date Of Birth and Identification Number -- a change this consolidation was "
               "instructed not to introduce.",
        "costs": "WHERE DELTA 3 IS RIGHT AND THE EXISTING WINNER IS WRONG, THIS PICKS THE WRONG "
                 "VALUE, on those 79 pairs. It is a VALUE choice, never a key change and never "
                 "RECORD_SOURCE in a key, so it cannot alter grain and is reversible by reload. "
                 "Delta 3's OWN 40 pairs, which no other run writes, are unaffected by the rank.",
        "overrule_with": "hcon_keyrules.R8_PRECEDENCE -- move 'opus_health_delta3' earlier in the "
                         "tuple (first = delta 3 wins every shared attribute)",
    },
]

# Delta 3 is appended LAST, so on every pair it shares with an existing run the 115 build's
# winner is unchanged. See BD6b -- the rank is a MEASURED choice over 79 co-written pairs,
# not a default.
R8_PRECEDENCE = ("opus_health_v2", "opus_health_legacy_v4", "opus_health_delta3")

# A contradicted profile claim has two different causes, and they route to different people.
# These are the claims the coordinator WITHDREW: the ones health_consolidated_dv_dbt already
# reported contradicted with the IDENTICAL profile->measured pair, so the difference predates
# this merge and is the mapper's to correct at source. Basis: that project's own
# BUILD_STATUS.json profile_claims.contradicted -- 422->428 and 0->428.
# Any OTHER contradicted claim appears only because this build reads a SECOND contract, so
# its profile figure is right for contract 1 and simply does not describe the union. That is
# the builder's to label, NOT the mapper's to fix.
COORDINATOR_WITHDRAWN_CLAIMS = ("r6_r7.legacy_blocks",
                                "r6_r7.legacy_blocks_naming_a_leg")
LEGACY_ARCHAEOLOGY_ENABLED = True
REFUSE_UNRESOLVED_LEGS = True
ORDINAL_LEGS_ALLOWED = True

# ============================================================== BUILD DIRECTIVES
# All eight, each NAMING the module that implements it, so the README table is emitted from the
# code rather than remembered. A directive declined would be a finding for mapper-liaison.
BUILD_DIRECTIVES = [
    {"n": 1, "bundle_item": "coordinator decision 2 and its refinement",
     "implemented_in": "hcon_names.hash_expr / hcon_names.namespaced_bk",
     "status": "IMPLEMENTED"},
    {"n": 2, "bundle_item": "R8 / CROSSRUN_SHARED_ATTRIBUTES.json",
     "implemented_in": "hcon_keyrules.r8_precedence_for + gen_hcon_vault (dual-feed loader)",
     "status": "IMPLEMENTED"},
    {"n": 3, "bundle_item": "withdrawn R6 instruction plus R6_childkey_value_kind.json",
     "implemented_in": "hcon_keyrules.read_child_key + hcon_keyrules.relabel_discount_item_code",
     "status": "IMPLEMENTED"},
    {"n": 4, "bundle_item": "R7 plus data_7.js",
     "implemented_in": "hcon_keyrules.read_child_key (leg arity PER ROW from the component array)",
     "status": "IMPLEMENTED"},
    {"n": 5, "bundle_item": "the five s9.8 blocks in the two originals",
     "implemented_in": "hcon_keyrules.carried_forward_caveat + gen_hcon_vault header emission",
     "status": "IMPLEMENTED"},
    {"n": 6, "bundle_item": "legacy packages.yml plus absent dbt_packages",
     "implemented_in": "gen_hcon_vault / all generators: no packages.yml is written and no macro "
                       "is invoked; check_hcon_internal asserts zero package references",
     "status": "IMPLEMENTED"},
    {"n": 7, "bundle_item": "s5.3, s5.5 and v2's satellite headers",
     "implemented_in": "hcon_keyrules.null_safe_concat + hcon_keyrules.guarded_hashdiff",
     "status": "IMPLEMENTED"},
    {"n": 8, "bundle_item": "normalise() in v2's expressions",
     "implemented_in": "hcon_keyrules.normalise_policy -- RAISED, NOT RESOLVED. v2's 31 "
                       "content-hash expressions are emitted VERBATIM (they already contain "
                       "normalise()); normalise() is introduced into NO new expression, and every "
                       "emitting model says so in its header.",
     "status": "IMPLEMENTED_AS_RAISED"},
]

# ============================================================== dispositions
# THE MAPPING COUNTERPARTY HAS DECIDED EVERY REFUSAL. Each kind carries its disposition, its
# STATUS and its ATTRIBUTION, so a reader can tell a SETTLED POSITION from an OPEN QUESTION without
# asking anyone. Statuses:
#   CLOSED_TERMINAL      decided, and there is nowhere left to look. NOT a deferral.
#   DROPPED_FROM_SCOPE   decided out of this build's scope, declared and counted.
#   AWAITING_COUNTERPARTY the disposition is settled (refuse and declare) and a fix is promised.
#   AWAITING_MODELLER_RATIFICATION
#                        settled as refuse-and-declare, but the open question is a MODEL decision
#                        the mapping counterparty cannot answer at all -- a proposed satellite with
#                        no parent in data_7.js. Held under its own status, NOT inside
#                        AWAITING_COUNTERPARTY, because a queue that cannot be drained by the party
#                        it names reads as a mapping defect and is not one.
#   BY_DESIGN            not a defect at all; held OUTSIDE the unresolved register.
DISPOSITIONS = {
    "legacy_key_not_recoverable": {
        "disposition": "DECLARED_ABSENCE", "status": "CLOSED_TERMINAL",
        "attribution": "mapper-ratified",
        "note": "Not in the map -- zero resolved_key on all 2817 legacy rows -- and not in the "
                "emitted SQL. There is nowhere left to look, so this is the CORRECT TERMINAL "
                "STATE and not a deferral.",
        "routing": "source"},
    "view_has_no_recoverable_key_at_all": {
        "disposition": "DECLARED_ABSENCE", "status": "CLOSED_TERMINAL",
        "attribution": "mapper-ratified",
        "note": "Same terminal class as legacy_key_not_recoverable: neither the map nor the "
                "emitted SQL keys this view for any hub.",
        "routing": "source"},
    "multiple_registries_key_this_view_hub": {
        "disposition": "REFUSE_AND_DECLARE", "status": "CLOSED_TERMINAL",
        "attribution": "mapper-ratified",
        "note": "ENTITY RESOLUTION, NOT KEYING -- and therefore NOT answerable by a key "
                "expression now or later. The first recovered key is used, the others are NAMED, "
                "and every shared-hub header states that unifying the hash form does not "
                "establish that the two runs' registries denote the same entities.",
        "routing": "source"},
    "satellite_has_no_anchor": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_MODELLER_RATIFICATION",
        "attribution": "builder",
        "note": "Both fallbacks were tried: the map's anchor, then data_7.js's declared parent. "
                "RECLASSIFIED, and the reclassification is the point: these 22 records are the 22 "
                "PROPOSED satellites, one record each, spanning 145 blocks (unit = (row, "
                "container) naming the satellite; measured, and every one of the 22 is named by at "
                "least one block). They were routed to the MAPPER and counted among the records "
                "awaiting it. That was wrong in a way that inflated the headline: a proposed "
                "satellite has no parent in data_7.js, and only the MODEL OWNER can give it one. "
                "The mapper cannot answer this however long it holds, so leaving it in the "
                "mapper's queue makes a modeller decision look like a mapping defect. Routed to "
                "the modeller and held under its own status so the awaiting-counterparty count "
                "means what it says. The counterparty's tiering of the same 145 blocks makes the "
                "ask well-formed; this build does not coin a parent for any of them (s5.6).",
        "routing": "modeller"},
    "satellite_home_is_pure_prose": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "mapper-ratified",
        "note": "The counterparty will fix the row in the map. The prose is NOT parsed into a "
                "target (s3): coining a satellite name from a description is how prose reaches "
                "SQL.",
        "routing": "mapper"},
    "loader_has_no_feed_in_the_map": {
        "disposition": "DROPPED_FROM_SCOPE", "status": "DROPPED_FROM_SCOPE",
        "attribution": "mapper-ratified",
        "note": "NOT built from the originals' SQL. Importing loaders with no map provenance "
                "would put unvalidatable models into the project -- the same objection this build "
                "raised against its own legacy-key path, except that nothing forces it here. A "
                "DECLARED, COUNTABLE ABSENCE beats untraceable loaders.",
        "routing": "mapper"},
    "payload_collides_with_child_key_leg": {
        "disposition": "CHILD_KEY_WINS", "status": "CLOSED_TERMINAL",
        "attribution": "mapper-ratified",
        "note": "Confirmed on ALL occurrences, not per-occurrence. The payload write lands second "
                "and undoes the child key's guard, and NO VALUE IS LOST because the same source "
                "column supplies the leg. No emitted satellite may carry both -- asserted.",
        "routing": "modeller"},
    "shared_loader_has_one_run_of_feeds": {
        "disposition": "NOT_A_DEFECT", "status": "BY_DESIGN",
        "attribution": "mapper-ratified",
        "note": "Both originals emit a file of this name, so the table is SHARED BY FILE SET; the "
                "settled map supplies one run's columns. No action.",
        "routing": "none"},
    "view_needs_no_cast": {
        "disposition": "NOT_A_DEFECT", "status": "BY_DESIGN",
        "attribution": "builder",
        "note": "No column of the view is consumed by any key slot or satellite payload, so no "
                "layer-1 cast is needed (s6.1). No action.",
        "routing": "none"},
    "child_key_leg_refused": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "mapper-ratified",
        "note": "Confirmed. The counterparty is taking Stage 6 for the legacy nothing_at_all and "
                "leg_no_value sub-populations. leg_and_value is the SETTLED UNFIXABLE class -- "
                "DECLARE, never transform: the leg is named correctly and the value answers a "
                "different question, which is why relabelling cannot fix it. The v2 value_no_leg "
                "subset should mostly resolve and is NOT a source gap.",
        "routing": "mapper"},
    "anchor_not_keyed_on_this_view_in_legacy_sql": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "mapper-ratified",
        "note": "All of them refused now; a re-homing pass is promised. THE COUNTERPARTY'S OWN "
                "DIAGNOSIS, which is the valuable part: their Stage 6.5 validated "
                "anchor == parent(satellite), a MODEL constraint, and never asked whether the "
                "VIEW CAN KEY THAT HUB, a SOURCE constraint. BOTH must hold. They will not "
                "re-anchor away from parent(satellite) to make a hub reachable, because that "
                "breaks anchor integrity the other way. This build's original routing -- that "
                "these were caused by the Stage-6.5 pass -- is CORRECTED: most are on "
                "(view, satellite) pairs that pass never touched.",
        "routing": "mapper"},
    # builder-side refusals the counterparty did not rule on individually
    "component_value_is_prose_or_empty": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "builder", "routing": "mapper",
        "note": "A brace-wrapped English phrase is not a {COLUMN} placeholder and renders to SQL "
                "naming a column that cannot exist."},
    "child_key_leg_name_unrenderable": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "builder", "routing": "mapper", "note": "The leg name cannot be a column."},
    "link_legs_not_establishable": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "builder", "routing": "mapper",
        "note": "One recovered business key cannot be distributed across several declared legs "
                "without inventing the rest."},
    "key_slot_name_collision_differing_expression": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "builder", "routing": "mapper",
        "note": "Two different expressions render one staged business-key column name on one "
                "view. NOT merged."},
    "attribute_unrenderable_prose_in_identifier_position": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "builder", "routing": "mapper", "note": "Prose where an attribute name "
                                                               "was expected."},
    "resolved_key_without_hub": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "builder", "routing": "mapper", "note": "The expression names no hub."},
    "resolved_key_without_source_columns": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "builder", "routing": "mapper",
        "note": "A key slot cannot be named without its operands."},
    "legacy_key_expression_not_an_identifier": {
        "disposition": "DECLARED_ABSENCE", "status": "CLOSED_TERMINAL",
        "attribution": "builder", "routing": "source",
        "note": "The recovered legacy key is not a bare column reference."},
    "component_not_a_dict": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "builder", "routing": "mapper", "note": "A component entry is not an "
                                                               "object."},
    "component_unnamed_leg": {
        "disposition": "REFUSE_AND_DECLARE", "status": "AWAITING_COUNTERPARTY",
        "attribution": "builder", "routing": "mapper", "note": "A component carries no name."},
}

# Kinds that are NOT defects and are held OUTSIDE the unresolved register, so the register's total
# cannot be read as a defect count.
BY_DESIGN_KINDS = tuple(k for k, v in DISPOSITIONS.items() if v["status"] == "BY_DESIGN")

TERMINAL_STATUSES = ("CLOSED_TERMINAL", "DROPPED_FROM_SCOPE")

# ============================================================== the unresolved register
# CANONICAL REGISTER: build_artifacts/hcon_spec.json -> unresolved. Every refusal lands here.
# build_artifacts/reports/declared_unresolved_grain_hcon.json is a DECLARED SUBSET of it -- the
# child-key-grain detail only -- and says so in its own unit_note. A register that is a subset of
# another register must say which it is; not saying so cost the counterparty twenty minutes
# concluding that the difference was unenumerated.
CANONICAL_REGISTER = "build_artifacts/hcon_spec.json -> unresolved"
GRAIN_SUBSET_REGISTER = "build_artifacts/reports/declared_unresolved_grain_hcon.json"
GRAIN_SUBSET_KINDS = ("child_key_leg_refused", "component_value_is_prose_or_empty",
                      "payload_collides_with_child_key_leg", "child_key_leg_name_unrenderable")

UNRESOLVED = []
BY_DESIGN = []


def refuse(kind, satellite=None, view=None, leg=None, detail="", states=None, extra=None):
    """Record a refusal, WITH its disposition. Reported, never guessed (s5.6).

    An unrecognised kind RAISES: every refusal kind must have a declared disposition, or the
    register grows a member nobody has ruled on and it looks the same as one they have.
    """
    d = DISPOSITIONS.get(kind)
    if d is None:
        raise AssertionError(
            "REFUSAL KIND WITH NO DECLARED DISPOSITION: %r. Every kind must carry a disposition, "
            "a status and an attribution, or an unruled refusal is indistinguishable from a ruled "
            "one." % kind)
    rec = {"kind": kind, "satellite": satellite, "view": view, "leg": leg, "detail": detail,
           "disposition": d["disposition"], "status": d["status"],
           "attribution": d["attribution"], "routing": d["routing"],
           "disposition_note": d.get("note", "")}
    if states:
        rec["discriminator_states"] = states
    if extra:
        rec.update(extra)
    (BY_DESIGN if d["status"] == "BY_DESIGN" else UNRESOLVED).append(rec)
    return rec


def unresolved_summary():
    by = collections.Counter(r["kind"] for r in UNRESOLVED)
    byst = collections.Counter(r["status"] for r in UNRESOLVED)
    byattr = collections.Counter(r["attribution"] for r in UNRESOLVED)
    closed = sum(v for k, v in byst.items() if k in TERMINAL_STATUSES)
    return {
        "canonical_register": CANONICAL_REGISTER,
        "total": len(UNRESOLVED),
        "by_kind": dict(by),
        "by_status": dict(byst),
        "by_attribution": dict(byattr),
        "closed": closed,
        "awaiting_counterparty": byst.get("AWAITING_COUNTERPARTY", 0),
        "awaiting_modeller_ratification": byst.get("AWAITING_MODELLER_RATIFICATION", 0),
        "awaiting_note": "awaiting_counterparty counts ONLY what the mapping counterparty can "
                         "actually answer. The 22 proposed satellites (145 blocks) need a PARENT "
                         "in data_7.js, which only the model owner can supply, so they are "
                         "counted under awaiting_modeller_ratification. Summing the two gives "
                         "every open record; quoting the first as the whole open count "
                         "understates it, and quoting it with the 22 folded in overstates what "
                         "the mapper is holding.",
        "by_design_held_separately": len(BY_DESIGN),
        "by_design_by_kind": dict(collections.Counter(r["kind"] for r in BY_DESIGN)),
        "unit_note": "unit = ONE refusal record. population = every refusal raised while reading "
                     "the settled map and the recovered legacy SQL. BY_DESIGN records are held "
                     "OUTSIDE this total so it cannot be read as a defect count.",
        "subset_register_note": "%s is a DECLARED SUBSET of this register, holding only the "
                                "child-key-grain kinds %s."
                                % (GRAIN_SUBSET_REGISTER, list(GRAIN_SUBSET_KINDS)),
    }


# ============================================================== the canonical model
def load_model():
    with open(MODEL_PATH, encoding="utf-8") as fh:
        text = fh.read()
    obj = json.loads(text[text.index("{"):].rstrip().rstrip(";"))
    return obj


MODEL = load_model()
MODEL_SATS = {s["code"]: s for s in MODEL["sats"]}
MODEL_REFS = {r["code"]: r for r in MODEL["refs"]}
MODEL_HUBS = {h["code"]: h for h in MODEL["hubs"]}
MODEL_LINKS = {l["code"]: l for l in MODEL["links"]}


def model_attrs(code):
    s = MODEL_SATS.get(code) or MODEL_REFS.get(code)
    return [a["n"] for a in s["attrs"]] if s else []


def model_childkey(code):
    s = MODEL_SATS.get(code)
    return (s or {}).get("childkey", "") or ""


def model_hist(code):
    s = MODEL_SATS.get(code)
    return (s or {}).get("hist", "") or ""


# ============================================================== the map
def load_map():
    """Both contracts, concatenated.

    Delta 3 carries no `source_run`, while the consolidated map uses it to separate legacy
    from v2. The label is stamped on READ so every existing downstream branch keeps working
    unchanged -- a default, not a decision, and the maps stay separate on disk.
    """
    with open(MAP_PATH, encoding="utf-8") as fh:
        rows = json.load(fh)["columns"]
    if os.path.exists(DELTA3_MAP_PATH):
        with open(DELTA3_MAP_PATH, encoding="utf-8") as fh:
            d3 = json.load(fh)["columns"]
        for r in d3:
            r.setdefault("source_run", DELTA3_RUN)
        rows = rows + d3
    return rows



def norm_component(c):
    """A child-key component in ONE shape, whichever map it came from.

    115 writes {name, value, resolved_on_view}; delta 3 writes {leg, ...}. The reader normalises;
    the maps are left exactly as their publishers issued them.
    """
    if isinstance(c, dict) and "name" not in c and "leg" in c:
        c = dict(c)
        c["name"] = c["leg"]
    return c


def assert_map_fields(rows):
    """Raise on any field this reader has not been told about, at EVERY level."""
    bad = collections.defaultdict(set)
    for r in rows:
        bad["row"] |= set(r) - RECOGNISED_MAP_FIELDS["row"]
        for cont in ("target", "augmentation"):
            o = r.get(cont)
            if isinstance(o, dict):
                bad[cont] |= set(o) - RECOGNISED_MAP_FIELDS[cont]
                rk = o.get("resolved_key")
                if isinstance(rk, dict):
                    bad["resolved_key"] |= set(rk) - RECOGNISED_MAP_FIELDS["resolved_key"]
                    for _d in (rk.get("key_reject_declaration") or []):
                        if isinstance(_d, dict):
                            bad["reject_declaration"] |= (
                                set(_d) - RECOGNISED_MAP_FIELDS["reject_declaration"])
                cc = o.get("child_key_components")
                if isinstance(cc, list):
                    for c in cc:
                        if isinstance(c, dict):
                            bad["component"] |= set(c) - RECOGNISED_MAP_FIELDS["component"]
        ra = r.get("reanchor")
        if isinstance(ra, dict):
            bad["reanchor"] |= set(ra) - RECOGNISED_MAP_FIELDS["reanchor"]
    found = {k: sorted(v) for k, v in bad.items() if v}
    if found:
        raise AssertionError("UNRECOGNISED MAP FIELD(S): %s -- the map changed and this reader "
                             "has not. Do NOT skip them (s2.2)." % found)
    return True


# ============================================================== three-state field reading
def state_of(container, field):
    """ABSENT vs PRESENT_NULL vs the literal string 'None' vs POPULATED. THREE states plus the
    populated one -- not two.

    This distinction is load-bearing and nearly invisible. On the 54 MEMBER group rows key_name and
    instance are PRESENT-AND-NULL while child_key_value, child_key_components and child_key are
    ABSENT. Both mean 'no discriminator', so refuse-and-declare is unchanged -- but a future reader
    fixing a 'null' will never look for an 'absent'.
    """
    if not isinstance(container, dict) or field not in container:
        return "ABSENT"
    v = container[field]
    if v is None:
        return "PRESENT_NULL"
    if v == "None":
        return "STRING_None"
    if v == "" or v == [] or v == {}:
        return "PRESENT_EMPTY"
    return "POPULATED"


def populated(container, field):
    return state_of(container, field) == "POPULATED"


def assert_child_key_cooccurrence(rows):
    """Re-measure the four-field co-occurrence matrix and FAIL on an unexpected combination."""
    got = collections.Counter()
    for r in rows:
        for cont in ("target", "augmentation"):
            o = r.get(cont)
            if not isinstance(o, dict):
                continue
            got[tuple(f for f in CHILD_KEY_FAMILY if populated(o, f))] += 1
    novel = sorted(set(got) - set(CHILD_KEY_COOCCURRENCE))
    if novel:
        raise AssertionError(
            "UNEXPECTED CHILD-KEY FIELD COMBINATION(S) %s -- this reader has not met this shape "
            "and must not guess which field is the key." % novel)
    drift = {k: (got[k], CHILD_KEY_COOCCURRENCE[k]) for k in CHILD_KEY_COOCCURRENCE
             if got[k] != CHILD_KEY_COOCCURRENCE[k]}
    if drift:
        raise AssertionError("CHILD-KEY CO-OCCURRENCE DRIFT (got, expected): %s" % drift)
    # key_name: DISJOINT from the family, and that disjointness is what makes the exclusion
    # safe to automate. 184 of its 306 values carry parenthesised prose
    # ('Policy Number (canonical contract key)'), so one written into a child key puts prose into
    # emitted SQL -- s3, and it has passed both gates before.
    # STAGE 6 BROKE THE DISJOINTNESS ON EXACTLY 3 CONTAINERS, and the exception is bounded BY
    # MEASUREMENT rather than by relaxing the check. On BJAZ_SH_MEM_DTLS_EXTN (DIABETES_YN,
    # HYPERTENSION_YN, ASTHMA_YN -> SAT_RISK_HEALTH_MEMBER_MEDICAL) key_name was written with the
    # CHILD-KEY name 'Member Reference + Condition Code', which is not what key_name holds
    # anywhere else -- it holds a HUB business-key name, prose-bearing on 184 of 306 values.
    # The pre-Stage-6 map had 0 such containers.
    #
    # It is harmless in VALUE on all three: key_name == child_key exactly, a duplication rather
    # than a second, different claim. So the assertion is NARROWED, not dropped: a co-occurrence
    # is tolerated ONLY where key_name is byte-equal to child_key. Prose in key_name, or any value
    # that disagrees with the child key, still fails the build -- which is the protection the
    # original disjointness was standing in for.
    #
    # Noted because it widens a known hazard: 'Member Reference + Condition Code' is one of the
    # four child-key-name PREFIX pairs in data_7.js ('Member Reference' prefixes it), so the same
    # string now appears in a second field and a containment reader has one more place to go wrong.
    # Routed to the mapper as a field-misuse finding; the build reads child_key, never key_name.
    clash = []
    for r in rows:
        for cont in ("target", "augmentation"):
            o = r.get(cont)
            if not isinstance(o, dict):
                continue
            if populated(o, "key_name") and any(populated(o, g) for g in CHILD_KEY_FAMILY):
                clash.append((r.get("table_name"), r.get("column_name"), cont,
                              o.get("key_name"), o.get("child_key")))
    disagree = [c for c in clash if c[3] != c[4]]
    if disagree:
        raise AssertionError(
            "key_name co-occurs with a child-key field AND DISAGREES with it on %d container(s): "
            "%s -- the disjointness this reader relies on no longer holds, and the two fields are "
            "making different claims. A key_name must never be read as a child key (s3)."
            % (len(disagree), disagree[:5]))
    if len(clash) != 3:
        raise AssertionError(
            "key_name/child-key co-occurrence count moved: expected the 3 measured "
            "BJAZ_SH_MEM_DTLS_EXTN duplications, got %d: %s" % (len(clash), clash[:6]))

    # child_key_vocabulary: NOT disjoint -- it co-occurs with a real child key on every one of its
    # containers, because it names the CONVENTION the child key follows. It is excluded for what it
    # HOLDS, so the assertion is on its VALUE SET: every value must be a convention token, never a
    # data value. 'canonical_source_column_prefix_token' inside a key is the key_name prose mistake
    # in a new costume.
    vocab = collections.Counter()
    for r in rows:
        for cont in ("target", "augmentation"):
            o = r.get(cont)
            if isinstance(o, dict) and populated(o, "child_key_vocabulary"):
                vocab[str(o["child_key_vocabulary"])] += 1
    for v in vocab:
        if not re.fullmatch(r"[a-z0-9_]+", v):
            raise AssertionError(
                "child_key_vocabulary holds %r, which is not a lower_snake convention token. If "
                "this field has started carrying DATA VALUES the exclusion reasoning no longer "
                "applies and the field must be re-characterised, not read." % v)
    return {"cooccurrence": dict(got), "key_name_clash": len(clash),
            "key_name_clash_detail": clash,
            "key_name_clash_disposition":
                "3 BJAZ_SH_MEM_DTLS_EXTN containers where Stage 6 wrote the CHILD-KEY name into "
                "key_name; tolerated ONLY because key_name == child_key byte-for-byte on all 3. "
                "A disagreement, or any 4th container, fails the build. The build reads child_key, "
                "never key_name. Routed to the mapper as a field-misuse finding.",
            "child_key_vocabulary_values": dict(vocab)}


# ============================================================== the child-key reader
def read_child_key(container, satellite):
    """Read the child key from ONE container. FOUR fields, three states, never key_name.

    Returns a dict:
      declared_legs     legs the MODEL declares for this satellite (split on ' + ')
      named_legs        legs the MAP names, from child_key or usage_child_key (split on ' + ')
      components        resolved [{leg, sql_or_literal, resolved_on_view}] from child_key_components
      rendered_value    child_key_value VERBATIM, for comparison only -- NEVER emitted as SQL
      states            the three-state reading of every family field plus key_name and instance
      subpopulation     one of nothing_at_all / leg_no_value / leg_and_value / value_no_leg
      resolvable        legs this build can actually render
      refused           legs it cannot
    """
    declared = N.split_legs(model_childkey(satellite)) if satellite else []
    states = {f: state_of(container, f) for f in CHILD_KEY_FAMILY}
    states["key_name"] = state_of(container, "key_name")
    states["instance"] = state_of(container, "instance")

    named = []
    if populated(container, "child_key"):
        named = N.split_legs(container["child_key"])
    elif populated(container, "usage_child_key"):
        # a FOURTH family member, disjoint from child_key on this map (34 containers, 0 overlap)
        named = N.split_legs(container["usage_child_key"])

    comps = []
    raw = container.get("child_key_components")
    if isinstance(raw, list):
        # leg arity read PER ROW from the array, never inferred from characters in a value (s5.8)
        for c in raw:
            if not isinstance(c, dict):
                refuse("component_not_a_dict", satellite=satellite,
                       detail="child_key_components entry is %r" % type(c).__name__)
                continue
            # ONE shape from here on. delta 3 spells `name` as `leg`; without this call every
            # delta-3 component reads as unnamed and is REFUSED, which costs the satellite a leg
            # and collapses rows that differ only in it. A refusal is a legitimate outcome, so
            # neither the register nor any gate can tell a wrong one from a right one -- this call
            # being absent cost 254 legs and was reported as a defect in the MAP.
            c = norm_component(c)
            leg = c.get("name")
            val = c.get("value")
            rov = c.get("resolved_on_view")
            if not isinstance(leg, str) or not leg.strip():
                refuse("component_unnamed_leg", satellite=satellite,
                       detail="component carries no name: %r" % (c,))
                continue
            col = N.placeholder_column(val)
            if col:
                comps.append({"leg": leg.strip(), "kind": "column", "column": col,
                              "resolved_on_view": bool(rov)})
            elif isinstance(val, str) and val.strip() and not N.looks_like_prose(val):
                comps.append({"leg": leg.strip(), "kind": "literal", "literal": val.strip(),
                              "resolved_on_view": bool(rov)})
            else:
                refuse("component_value_is_prose_or_empty", satellite=satellite, leg=leg,
                       detail="component value %r is neither a {COLUMN} placeholder nor a "
                              "renderable literal; a brace-wrapped phrase renders to SQL naming a "
                              "column that cannot exist" % (val,))

    has_value = populated(container, "child_key_value") or bool(comps)
    if named and has_value:
        sub = "leg_and_value"
    elif named:
        sub = "leg_no_value"
    elif has_value:
        sub = "value_no_leg"
    else:
        sub = "nothing_at_all"

    resolvable = [c for c in comps]
    resolved_legs = {c["leg"] for c in comps}
    refused_legs = [l for l in (declared or named) if l not in resolved_legs]

    return {"declared_legs": declared, "named_legs": named, "components": comps,
            "rendered_value": container.get("child_key_value"),
            "states": states, "subpopulation": sub,
            "resolvable": resolvable, "refused_legs": refused_legs}


# ---- the sole relabelling -------------------------------------------------------------------
# SAT_POLICY_DISCOUNT_LOADING_APPLIED: 30 blocks, ALL prose, 15 distinct values x 2 feeds.
# Concept-for-concept onto the model's declared 'Item Code'. ANY value with no v2 counterpart is
# REFUSED, not coined. The table below is the 15 measured values; the v2 counterpart is looked up
# from v2's own emitted child-key literals at build time, so nothing here invents a code.
RELABEL_SATELLITE = "SAT_POLICY_DISCOUNT_LOADING_APPLIED"
RELABEL_VALUES = tuple(PROFILE["r6_r7_childkeys"]["relabel_exception"]["values"])


def relabel_discount_item_code(value, v2_vocabulary):
    """Map one legacy prose discount/loading label onto a v2 Item Code, or refuse.

    v2_vocabulary is the set of child-key values v2 ACTUALLY writes on this satellite, read from
    the map. A legacy label is relabelled only when an identical-after-normalisation v2 value
    exists; otherwise it is refused. No code is coined.
    """
    if not isinstance(value, str) or not value.strip():
        return None, "empty"
    want = re.sub(r"[^a-z0-9]+", "", value.lower())
    for cand in sorted(v2_vocabulary):
        if re.sub(r"[^a-z0-9]+", "", str(cand).lower()) == want:
            return cand, "matched"
    return None, "no_v2_counterpart"


# ============================================================== expression grammar
def classify_expression(expr):
    """Exactly one of the five declared forms, or raise. Sweep the set; never name one (s1.5)."""
    if not isinstance(expr, str) or not expr.strip():
        raise AssertionError("empty key expression")
    hits = [f for f in GRAMMAR_FORMS if RX_FORM[f].match(expr.strip())]
    if len(hits) != 1:
        raise AssertionError(
            "UNRECOGNISED KEY EXPRESSION FORM (%d of the %d declared forms match): %r"
            % (len(hits), len(GRAMMAR_FORMS), expr[:160]))
    return hits[0]


def assert_no_walk_operators(strings, label):
    """PROVE THE ZERO. The walk-only-cast and resolver layers are omitted because the grammar has
    no walk operator -- and an omission with no measurement behind it is indistinguishable from an
    oversight. Returns the per-operator counts so the zero is reported, not assumed."""
    counts = {op: 0 for op in WALK_OPERATORS}
    for s in strings:
        if not isinstance(s, str):
            continue
        for op in WALK_OPERATORS:
            if op in s:
                counts[op] += 1
    hits = {k: v for k, v in counts.items() if v}
    if hits:
        raise AssertionError(
            "WALK OPERATOR(S) PRESENT in %s: %s -- the hop-view and resolver layers were omitted "
            "on the strength of a measured zero that no longer holds. Expand every hop into its "
            "real per-level chain (s4) before building." % (label, hits))
    return counts


def parse_expression(expr):
    """Parse one resolved_key expression into something renderable.

    An expression is emitted VERBATIM -- separators and the inner coalesce of a content hash are
    NOT tidied. The parse exists to classify, to find the legs of a link, and to refuse what it
    does not understand; it does not rewrite SQL.
    """
    form = classify_expression(expr)
    out = {"form": form, "semantics": FORM_SEMANTICS[form], "verbatim": expr.strip(),
           "legs": None, "uses_normalise": "normalise(" in expr}
    if form == "LNK_composite":
        inner = expr.strip()
        if not inner.endswith(")"):
            raise AssertionError("LNK( form is not closed: %r" % expr[:120])
        body = inner[len("LNK("):-1]
        legs = {}
        marks = list(RX_LNK_LEG.finditer(body))
        if not marks:
            raise AssertionError("LNK( form names no leg: %r" % expr[:160])
        for i, m in enumerate(marks):
            end = marks[i + 1].start() if i + 1 < len(marks) else len(body)
            seg = body[m.end():end].strip().rstrip(",").strip()
            if not seg:
                # an empty replacement span is FATAL (s1.6) -- never silently skipped
                raise AssertionError("EMPTY LINK LEG EXPRESSION for %s in %r"
                                     % (m.group(1), expr[:160]))
            legs[m.group(1)] = seg
        out["legs"] = legs
    return out


def read_ck_markers(container):
    """Read the childkey[...] markers out of key_derivation.

    key_derivation is PROSE and is in PROSE_DENY: not one character of it is ever rendered. It is
    read here ONLY as an exact bracketed token, because it is the sole signal in this bundle for
    the column-as-instance family, and the alternative is to guess the unpivot layer's population
    from column names. An unrecognised marker RAISES.
    """
    out = set()
    for f in ("key_derivation",):
        v = container.get(f)
        if isinstance(v, str):
            for m in RX_CK_MARKER.finditer(v):
                tok = m.group(1)
                if tok not in CK_MARKERS:
                    raise AssertionError(
                        "UNRECOGNISED childkey[...] MARKER %r -- sweep the set, do not skip the "
                        "member (s1.5). Known: %s" % (tok, list(CK_MARKERS)))
                out.add(tok)
    return out


# ============================================================== null safety
def null_safe_concat(operands):
    """Coalesce EACH non-literal operand separately, never the finished composite (s5.3).

    coalesce(a || '|' || b, '') is null whenever either side is null, so one missing operand
    annihilates the whole key. Per-operand is the only form that degrades instead of vanishing.
    """
    if not operands:
        raise AssertionError("null_safe_concat got no operands")
    parts = []
    for op in operands:
        if op.startswith("'") and op.endswith("'"):
            parts.append(op)
        else:
            parts.append("coalesce(cast(%s as varchar), '')" % op)
    return " || '|' || ".join(parts)


def guarded_hashdiff(satellite, payload_columns):
    """A content hash GUARDED against an all-null input (s5.5).

    Without the guard every all-null row hashes to ONE value and the satellite collapses to one
    row -- and the collapse looks like correct change detection.
    """
    if not payload_columns:
        raise AssertionError("guarded_hashdiff got an empty payload for %s" % satellite)
    guard = " or ".join("%s is not null" % c for c in payload_columns)
    body = null_safe_concat(list(payload_columns))
    return ("case when %s\n             then md5(upper(%s))\n        end as %s"
            % (guard, body, N.hashdiff(satellite)))


def r8_precedence_for(attribute, satellite, writers_by_run):
    """The DECLARED source precedence for one attribute. Never a key change; never RECORD_SOURCE
    in a key, which would silently alter grain."""
    order = [r for r in R8_PRECEDENCE if r in writers_by_run]
    unknown = sorted(set(writers_by_run) - set(R8_PRECEDENCE))
    if unknown:
        raise AssertionError("writer from an unrecognised source_run %s on %s.%s"
                             % (unknown, satellite, attribute))
    return order


def carried_forward_caveat(vault_table):
    """The s9.8 reconciliation blocks from the two originals, reproduced VERBATIM.

    FIVE of them exist, not one: hub_party, hub_claim, hub_policy, hub_product, lnk_party_role.
    Each is carried byte-for-byte out of carried_forward_caveats.json -- a paraphrase of a
    reconciliation risk is a different risk.
    """
    path = os.path.join(REPORTS, "carried_forward_caveats.json")
    with open(path, encoding="utf-8") as fh:
        rows = json.load(fh)
    declared = PROFILE["carried_forward_caveats"]["count"]
    if len(rows) != declared:
        raise AssertionError("carried_forward_caveats.json holds %d, profile declares %d"
                             % (len(rows), declared))
    for r in rows:
        if r["vault_table"] == vault_table:
            return r["comment"]
    return None


def all_carried_forward_tables():
    path = os.path.join(REPORTS, "carried_forward_caveats.json")
    with open(path, encoding="utf-8") as fh:
        return [r["vault_table"] for r in json.load(fh)]


def normalise_policy():
    """Build directive 8: RAISED, not resolved.

    normalise() is emitted 38 times across 28 v2 models and is defined in NO macro file, NO UDF and
    NO package in either project. v2's 31 content-hash key expressions already contain it and are
    emitted VERBATIM; this build introduces it into NO NEW expression. Any model carrying it says
    so in its header.
    """
    return ("normalise() is UNDEFINED in both originals and in this project. It is emitted here "
            "ONLY where it was already present in a v2 key expression carried over verbatim; it "
            "is introduced into no new expression. Treated as a pre-existing Snowflake UDF. "
            "UNRESOLVED -- see open item normalise-udf.")


# ============================================================== legacy key archaeology
RX_REF = re.compile(r"\{\{\s*ref\(\s*['\"]([A-Za-z0-9_]+)['\"]\s*\)\s*\}\}")
RX_SRC_MODEL = re.compile(r"^\s*source_model:\s*['\"]([A-Za-z0-9_]+)['\"]", re.M)
RX_NK_DECL = re.compile(
    r"^\s*([A-Za-z_][A-Za-z0-9_]*_NK):\s*\"'((?:HUB|LNK|REF)_[A-Z0-9_]+)\|'\s*\|\|\s*(.+?)\"\s*$",
    re.M)
RX_CTE = re.compile(r"(?:^|,|\bwith\b)\s*([a-z_][a-z0-9_]*)\s+as\s*\(", re.I | re.M)
RX_ALIAS = re.compile(r"([A-Za-z_][A-Za-z0-9_().,'|\s]*?)\s+as\s+([a-z_][a-z0-9_]*)\s*(?=,|\n|$)",
                      re.I)
RX_LEG_RAW_VIEW = re.compile(r"^stg_health__(.+)$")
RX_SELECT_NOISE = re.compile(r"^(?:select\s+distinct|select)\s+", re.I | re.S)
RX_BARE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")

LEGACY_PROJECT = os.path.join(REPO_ROOT, "health_dv_dbt")


def probe_legacy_patterns():
    cases = [
        (RX_REF, "from {{ ref('stg_health__ba_hcp_dt_mem') }}", True),
        (RX_REF, "from RAW.HEALTH.BA_HCP_DT_MEM", False),
        (RX_SRC_MODEL, "source_model: 'stitch_account_definition'\n", True),
        (RX_NK_DECL, "  FINANCIAL_ACCOUNT_NK: \"'HUB_FINANCIAL_ACCOUNT|' || PARENT_BK\"\n", True),
        (RX_NK_DECL, "  FINANCIAL_ACCOUNT_NK: \"PARENT_BK\"\n", False),
        (RX_CTE, "    with t0 as (\n", True),
        (RX_CTE, "    with t0 select\n", False),
        (RX_ALIAS, "mlac_emi_pc_loan_account_no as parent_bk,", True),
    ]
    for pat, s, want in cases:
        if bool(pat.search(s)) != want:
            raise AssertionError("legacy pattern probe failed: %r on %r" % (pat.pattern, s))
    return len(cases)


def _cte_bodies(text):
    for m in RX_CTE.finditer(text):
        i = m.end() - 1
        depth = 0
        for j in range(i, len(text)):
            if text[j] == "(":
                depth += 1
            elif text[j] == ")":
                depth -= 1
                if depth == 0:
                    yield m.group(1), text[i + 1:j]
                    break


def legacy_key_forms(verbose=False):
    """Recover (raw_view, hub) -> business-key expression from health_dv_dbt's EMITTED SQL.

    READ-ONLY. See BUILDER_DECISIONS BD2 for why this exists and what it costs. Every declaration
    this reader cannot resolve is REFUSED into UNRESOLVED, never guessed.
    """
    if not LEGACY_ARCHAEOLOGY_ENABLED:
        return {}, {"enabled": False}
    probe_legacy_patterns()
    files = {}
    for p in glob.glob(os.path.join(LEGACY_PROJECT, "models", "**", "*.sql"), recursive=True):
        with open(p, encoding="utf-8") as fh:
            files[os.path.basename(p)[:-4]] = fh.read()
    decls = []
    for name, text in files.items():
        sm = RX_SRC_MODEL.search(text)
        for m in RX_NK_DECL.finditer(text):
            decls.append({"model": name, "hub": m.group(2), "rhs": m.group(3).strip(),
                          "source_model": sm.group(1) if sm else name})
    recovered = collections.defaultdict(set)
    composite = 0
    for d in decls:
        rhs = d["rhs"]
        inner = rhs[1:-1].strip() if rhs.startswith("(") and rhs.endswith(")") else rhs
        if not RX_BARE.match(inner):
            composite += 1
            continue
        alias = inner.lower()
        sm = d["source_model"]
        text = files.get(sm, "")
        direct = RX_LEG_RAW_VIEW.match(sm)
        if direct:
            recovered[(direct.group(1), d["hub"])].add(alias)
        for _cname, body in _cte_bodies(text):
            views = [RX_LEG_RAW_VIEW.match(r).group(1) for r in RX_REF.findall(body)
                     if RX_LEG_RAW_VIEW.match(r)]
            if not views:
                continue
            for expr, al in RX_ALIAS.findall(body):
                if al.lower() != alias:
                    continue
                e = RX_SELECT_NOISE.sub("", expr.strip()).strip()
                e = e.split("\n")[-1].strip().rstrip(",")
                if not RX_BARE.match(e):
                    continue
                for v in views:
                    recovered[(v, d["hub"])].add(e.lower())
    out = {}
    ambiguous = 0
    for (view, hub), exprs in recovered.items():
        ex = sorted(exprs)
        if len(ex) > 1:
            ambiguous += 1
            # MORE THAN ONE registry for this (view, hub). Both are kept as separate key SLOTS --
            # merging them would assert they are one identifier population, which is exactly the
            # undetermined question this build must not answer.
            out[(view, hub)] = ex
        else:
            out[(view, hub)] = ex
    stats = {"enabled": True, "legacy_models_read": len(files), "nk_declarations": len(decls),
             "composite_rhs_skipped": composite,
             "view_hub_pairs_recovered": len(out),
             "views_recovered": len({k[0] for k in out}),
             "pairs_with_multiple_registries": ambiguous,
             "matcher_note": "unit = one derived_columns line of the form "
                             "<X>_NK: \"'HUB_Y|' || rhs\" in a health_dv_dbt .sql; bare-identifier "
                             "rhs only, composites counted and skipped",
             "profile_claims_nk_declarations":
                 PROFILE["legacy_key_forms"]["nk_namespaced_declarations"]}
    if verbose:
        print("  legacy archaeology: %s" % json.dumps(stats, indent=None))
    return out, stats


# ============================================================== profile claim assertions
def assert_profile_claims(rows):
    """Assert the profile's load-bearing claims against the settled map, and record the ones that
    DO NOT hold. A profile is a counterparty artifact; a figure relayed unmeasured is a figure
    nobody measured."""
    out = {"agree": [], "contradicted": []}

    def chk(label, got, want):
        (out["agree"] if got == want else out["contradicted"]).append(
            {"claim": label, "profile": want, "measured": got})

    chk("map_shape.rows", len(rows), PROFILE["map_shape"]["rows"])
    byrun = collections.Counter(r["source_run"] for r in rows)
    for run, n in PROFILE["map_shape"]["by_source_run"].items():
        chk("by_source_run.%s" % run, byrun[run], n)
    oc = collections.Counter(r["outcome"] for r in rows)
    for k, n in PROFILE["legacy_half_status"]["reissue_diff"]["outcomes_post"].items():
        chk("outcomes_post.%s" % k, oc.get(k, 0), n)
    chk("distinct_tables.union", len({r["table_name"] for r in rows}),
        PROFILE["map_shape"]["distinct_tables"]["union"])
    chk("resolved_key_on_legacy_rows",
        sum(1 for r in rows if r["source_run"] == "opus_health_legacy_v4"
            and isinstance((r.get("target") or {}).get("resolved_key"), dict)),
        PROFILE["legacy_half_status"]["resolved_key_on_legacy_rows"])
    chk("resolved_key_on_v2_rows",
        sum(1 for r in rows if r["source_run"] == "opus_health_v2"
            and isinstance((r.get("target") or {}).get("resolved_key"), dict)),
        PROFILE["legacy_half_status"]["resolved_key_on_v2_rows"])

    # the claim the coordinator WITHDREW mid-run. Measured both ways so the withdrawal is proved,
    # not taken on trust. MATCHER: a block is a (row, container) pair carrying a satellite home;
    # 'names a leg' = child_key POPULATED on that container.
    shared16 = set(PROFILE["r6_r7_childkeys"]["per_satellite"])
    lb = ln = 0
    verbatim_agree = verbatim_dis = 0
    for r in rows:
        if r["source_run"] != "opus_health_legacy_v4":
            continue
        for cont in ("target", "augmentation"):
            o = r.get(cont)
            if not isinstance(o, dict):
                continue
            sat = None
            for sp in ("satellite", "best_home_satellite", "new_satellite"):
                v = o.get(sp)
                if isinstance(v, str) and v.strip():
                    sat = v.strip()
                    break
            if sat not in shared16:
                continue
            lb += 1
            if populated(o, "child_key"):
                ln += 1
                if o["child_key"] == model_childkey(sat):
                    verbatim_agree += 1
                else:
                    verbatim_dis += 1
    chk("r6_r7.legacy_blocks", lb, PROFILE["r6_r7_childkeys"]["legacy_blocks"])
    chk("r6_r7.legacy_blocks_naming_a_leg", ln,
        PROFILE["r6_r7_childkeys"]["legacy_blocks_naming_a_leg"])
    out["leg_naming_measured"] = {
        "legacy_blocks_naming_a_leg": ln,
        "child_key_equals_model_declared_childkey_verbatim": verbatim_agree,
        "disagreeing": verbatim_dis,
        "matcher_note": "unit = (row, container) block on one of the 16 shared multi-active "
                        "satellites; 'names a leg' = child_key POPULATED; comparison is against "
                        "data_7.js childkey held WHOLE, not split",
    }
    return out


def member_group_census(rows):
    """The BJAZ_WS_FAMILY_DTLS_BANDHAN repeating group, at every scope that matters.

    MATCHER on every figure below: SUBSTRING r'MEMBER[1-8]' or the substring 'SELF' in
    column_name. A WORD-BOUNDARY regex r'\bMEMBER[1-8]\b' matches ZERO of them, because an
    alphanumeric follows the digit (MEMBER1DOB). Identical mechanism to spine_present defeating
    r'\bspine\b'.

    UNIT on every figure: one row of map['columns'].
    """
    ss = re.compile(r"MEMBER[1-8]")
    wb = re.compile(r"\bMEMBER[1-8]\b")
    table = "BJAZ_WS_FAMILY_DTLS_BANDHAN"
    group = [r for r in rows if r["table_name"] == table
             and (ss.search(r["column_name"]) or "SELF" in r["column_name"])]
    out = {
        "matcher_note": "SUBSTRING 'MEMBER[1-8]' or 'SELF' in column_name; unit = map row; "
                        "population = the one source table BJAZ_WS_FAMILY_DTLS_BANDHAN",
        "group_total_all_satellites": len(group),
        "word_boundary_would_match": sum(1 for r in group if wb.search(r["column_name"])),
        "by_satellite": {},
        "by_satellite_and_outcome": {},
        "by_attribute": {},
    }
    for r in group:
        sat = _home_of(r) or "(no home)"
        out["by_satellite"][sat] = out["by_satellite"].get(sat, 0) + 1
        k = "%s|%s" % (sat, r["outcome"])
        out["by_satellite_and_outcome"][k] = out["by_satellite_and_outcome"].get(k, 0) + 1
        a = _attribute_of(r) or "(no attribute)"
        out["by_attribute"]["%s|%s" % (sat, a)] = out["by_attribute"].get("%s|%s" % (sat, a), 0) + 1
    # GRAIN IS PART OF A SLOT FAMILY'S IDENTITY, NOT A DETAIL OF IT.
    # A repeating group spanning two satellites spans two REMEDIES when those satellites differ
    # in grain: a multi-active target is missing a declared discriminator; a single-active target
    # cannot have one, so the same nine slots writing one attribute are an attribute FAN-IN.
    # Grain is read from data_7.js (MODEL_SATS), never from the map and never from a claim.
    out["by_grain"] = {}
    out["remedy_by_satellite"] = {}
    for sat in sorted(out["by_satellite"]):
        ms = MODEL_SATS.get(sat) or {}
        hist = str(ms.get("hist") or "")
        ma = "Multi-Active" in hist
        ck = ms.get("childkey") or ""
        gr = "MULTI_ACTIVE" if ma else "SINGLE_ACTIVE"
        out["by_grain"]["%s|%s" % (sat, gr)] = out["by_satellite"][sat]
        fanin = {}
        for k, v in out["by_attribute"].items():
            s2, a2 = k.split("|", 1)
            if s2 == sat and v > 1:
                fanin[a2] = v
        out["remedy_by_satellite"][sat] = {
            "hist": hist,
            "declared_childkey": ck,
            "grain": gr,
            "blocks": out["by_satellite"][sat],
            "in_model": bool(ms),
            "remedy_token": ("REFUSE_AND_DECLARE_MISSING_DISCRIMINATOR" if ma
                             else "ATTRIBUTE_FAN_IN_NOT_A_CHILD_KEY"),
            "writers_per_attribute": fanin,
            "note": (
                "Multi-Active with a declared childkey, so the absent discriminator IS the "
                "defect and refuse-and-declare is the remedy."
                if ma else
                "SINGLE-ACTIVE: hist carries no 'Multi-Active' and childkey is '' in data_7.js, "
                "so this satellite holds ONE ROW PER ANCHOR KEY and has no discriminator to be "
                "absent. A declared-grain note here would state something FALSE. The slots are "
                "an ATTRIBUTE FAN-IN -- N columns from one view writing one attribute on a "
                "single-active target -- and the remedy is a Stage-4 precedence or shred "
                "decision, not a child key. The emitted model is single-active (one group-by on "
                "the anchor hash key, no _CK column) and no child-key refusal was filed for it."),
        }
    out["refuse_and_declare_population"] = sum(
        v["blocks"] for v in out["remedy_by_satellite"].values() if v["grain"] == "MULTI_ACTIVE")
    out["fan_in_population"] = sum(
        v["blocks"] for v in out["remedy_by_satellite"].values() if v["grain"] == "SINGLE_ACTIVE")
    out["fan_in_gate_visibility_note"] = (
        "check_collapse groups on (table, satellite, attribute, instance, child_key) and would "
        "see this fan-in -- it is ONE table -- but every one of the single-active blocks carries "
        "outcome='augmentation_needed', and the gate's population is scope-by-outcome, so it "
        "fires on ZERO of them. Scope by presence, never by outcome, inside the gate itself. "
        "vault_tools is NOT edited here: it is shared by closed builds.")
    out["declared_scope_54_note"] = (
        "The profile and declared_unresolved_grain.json both scope the group to 54 = "
        "outcome='mapped' on SAT_RISK_PERSON_MEMBER. That scope is CORRECT but NARROWER than the "
        "group: 36 further rows sit in the same repeating group on the same source view. "
        "CORRECTED: the earlier wording said all 36 share 'the SAME absent Member Sequence "
        "discriminator'. That is FALSE for half of them. 18 are on SAT_RISK_PERSON_MEMBER "
        "(Multi-Active SCD2, childkey 'Member Sequence') where the discriminator is genuinely "
        "absent; 18 are on SAT_LNK_ROLE_NOMINEE_BENEFICIARY, which is SCD2 with childkey='' and "
        "therefore has no discriminator to be absent. THE REFUSE-AND-DECLARE POPULATION FOR THIS "
        "GROUP IS 72, NOT 90. One slot family, two grains, two remedies -- see "
        "remedy_by_satellite.")
    out["correction_provenance"] = (
        "The '90 blocks over two satellites, declare all 90' framing originated on THIS side. The "
        "grain split was raised by the mapping counterparty's Stage 6 agent, which read data_7.js "
        "rather than inheriting the claim, and is re-derived here from data_7.js directly: "
        "SAT_LNK_ROLE_NOMINEE_BENEFICIARY parent='LNK_PARTY_ROLE' hist='SCD2' childkey=''. "
        "THE BUILD WAS ALREADY CORRECT -- the emitted satellite is single-active and 0 of the 291 "
        "declared-grain refusals name it -- so this corrects a REPORT, not a model. A report and "
        "the artifact it describes are two artifacts (BUILD_RULES.md 1.45).")
    return out


def assert_matcher_discipline(rows):
    """SUBSTRING OR CHARACTER CLASS, NEVER A WORD BOUNDARY.

    Reproduces profile.matcher_discipline.evidence on ITS OWN SCOPE -- outcome='mapped' on
    SAT_RISK_PERSON_MEMBER -- so the drift assertion keeps its teeth, and returns the wider census
    beside it so the narrower scope can never be mistaken for the whole group.
    """
    wb = re.compile(r"\bMEMBER[1-8]\b")
    ss = re.compile(r"MEMBER[1-8]")
    sat = PROFILE["r6_r7_childkeys"]["additional_refuse_and_declare"]["satellite"]
    scoped = [r for r in rows if _home_of(r) == sat and r["outcome"] == "mapped"
              and (ss.search(r["column_name"]) or "SELF" in r["column_name"])]
    got = {"regex_word_boundary_MEMBER_1_8": sum(1 for r in scoped if wb.search(r["column_name"])),
           "substring_MEMBER_1_8": sum(1 for r in scoped if ss.search(r["column_name"])),
           "SELF_substring": sum(1 for r in scoped if "SELF" in r["column_name"]),
           "group_total": len(scoped)}
    want = PROFILE["matcher_discipline"]["evidence"]
    if got != want:
        raise AssertionError("MATCHER DISCIPLINE EVIDENCE DRIFT on the profile's own scope "
                             "(satellite=%s, outcome=mapped): measured %s, profile %s"
                             % (sat, got, want))
    return {"profile_scope": got, "wider_census": member_group_census(rows)}


def _attribute_of(row):
    for cont in ("target", "augmentation"):
        o = row.get(cont)
        if not isinstance(o, dict):
            continue
        for sp in ("attribute", "proposed_attribute"):
            v = o.get(sp)
            if isinstance(v, str) and v.strip():
                return v.strip()
    return None


def _home_of(row):
    for cont in ("target", "augmentation"):
        o = row.get(cont)
        if not isinstance(o, dict):
            continue
        for sp in ("satellite", "best_home_satellite", "new_satellite"):
            v = o.get(sp)
            if isinstance(v, str) and v.strip():
                code, _prose = N.vault_code(v)
                return code or v.strip()
    return None


def selftest():
    print("  profile fields recognised: %d" % assert_profile_recognised())
    rows = load_map()
    assert_map_fields(rows)
    print("  map fields: every field at every level is recognised (%d rows)" % len(rows))
    ck = assert_child_key_cooccurrence(rows)
    co = ck["cooccurrence"]
    print("  child-key co-occurrence over 4 fields: %d combinations, all expected" % len(co))
    print("    %s" % {("+".join(k) or "(none)"): v for k, v in sorted(co.items())})
    print("  key_name x child-key-family clash: %d (3 expected, all exact duplications; "
          "a disagreement or a 4th fails)" % ck["key_name_clash"])
    for _c in ck["key_name_clash_detail"]:
        print("      %s.%s [%s] key_name == child_key == %r" % (_c[0], _c[1], _c[2], _c[3]))
    print("  child_key_vocabulary values (convention tokens, NEVER read as a key): %s"
          % ck["child_key_vocabulary_values"])
    md = assert_matcher_discipline(rows)
    print("  matcher discipline reproduced on the profile's scope: %s" % md["profile_scope"])
    wc = md["wider_census"]
    print("  WIDER repeating-group census (matcher = substring, unit = map row):")
    print("    group total over all satellites: %d ; a word-boundary regex would match %d"
          % (wc["group_total_all_satellites"], wc["word_boundary_would_match"]))
    print("    by satellite: %s" % wc["by_satellite"])
    print("    by satellite|outcome: %s" % wc["by_satellite_and_outcome"])
    exprs = []
    for r in rows:
        for cont in ("target", "augmentation"):
            rk = (r.get(cont) or {}).get("resolved_key")
            if isinstance(rk, dict) and rk.get("expression"):
                exprs.append(rk["expression"])
    forms = collections.Counter(classify_expression(e) for e in exprs)
    print("  grammar census (population = %d resolved_key expressions): %s"
          % (len(exprs), dict(forms)))
    if len(exprs) != PROFILE["grammar_population"]:
        raise AssertionError("grammar population %d != profile %d"
                             % (len(exprs), PROFILE["grammar_population"]))
    allstr = exprs + [str((r.get(cont) or {}).get("child_key_value"))
                      for r in rows for cont in ("target", "augmentation")]
    walk = assert_no_walk_operators(allstr, "resolved_key.expression + child_key_value")
    print("  walk operators PROVEN ZERO over %d strings: %s" % (len(allstr), walk))
    claims = assert_profile_claims(rows)
    print("  profile claims: %d agree, %d CONTRADICTED" % (len(claims["agree"]),
                                                           len(claims["contradicted"])))
    for c in claims["contradicted"]:
        print("    CONTRADICTED %s: profile %r, measured %r"
              % (c["claim"], c["profile"], c["measured"]))
    print("  leg naming measured: %s" % claims["leg_naming_measured"])
    _lk, stats = legacy_key_forms()
    print("  legacy archaeology: %s" % stats)
    print("  BUILDER_DECISIONS: %d   BUILD_DIRECTIVES: %d   UNRESOLVED so far: %d"
          % (len(BUILDER_DECISIONS), len(BUILD_DIRECTIVES), len(UNRESOLVED)))


if __name__ == "__main__":
    N.probe_patterns()
    selftest()
