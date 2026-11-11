{{ config(materialized='view') }}
-- This part feeds SAT_AUG_PRODUCT_CAPTURE_PARAMETER only. Original precedence comments are kept below (from stitch_v31_product).
-- CENTRAL VIEW v31_product -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_COVERS_EXT (opus_health_v2)
--   BJAZ_CTNGY_SCHEME_NR_PARMS (opus_health_v2)
--   BJAZ_CTNGY_SCHEME_PLANS (opus_health_v2)
--   BA_HCP_DT_MEM (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HCS_PLANSI_MAPP (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BA_CCP_SUB_MATER_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PRODUCT_CAPTURE_PARAMETER
--   SAT_AUG_PRODUCT_DISTRIBUTION_RULES
--   SAT_AUG_PRODUCT_ISSUANCE_OUTPUT_RULE
--   SAT_AUG_PRODUCT_RATING_STRUCTURE
--   SAT_AUG_RISK_OBJECT_INSURABLE_INTEREST
--   SAT_FINTXN_COMMISSION
--   SAT_FINTXN_HEADER
--   SAT_FINTXN_PREMIUM
--   SAT_FINTXN_RECON_INSTRUMENT
--   SAT_FIN_RECEIPT
--   SAT_POLICY_CLAUSE_ATTACHED
--   SAT_POLICY_PREMIUM_HEAD
--   SAT_POLICY_RENEWAL
--   SAT_PRODUCT_DISTRIBUTION_RULES
--   SAT_PRODUCT_HEALTH_MEMBERSHIP_RULES
--   SAT_PRODUCT_TERMS
--   SAT_PRODUCT_VERSION
--   SAT_PROPOSAL_UNDERWRITING
--   SAT_QUOTE_RATING
--   SAT_RISK_OBJECT_INSURABLE_INTEREST
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_CHANNEL
--   LNK_AGREEMENT_PRODUCT
--   LNK_CHANNEL_ORG_UNIT
--   LNK_FINTXN_ACCOUNT
--   LNK_FINTXN_POLICY
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_scheme_nr_parms') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_scheme_nr_parms',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('SCHEME:' || nullif(trim(scheme_code),''), 'SCHEME:'))) || '|' || coalesce(scheme_version, '~') || '|' || coalesce(param_ref, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_SCHEME_NR_PARMS',
      'columns': [
        {'src': "nullif('SCHEME:' || nullif(trim(scheme_code),''), 'SCHEME:')", 'tgt': 'product_bk'},
        {'src': 'scheme_version', 'tgt': 'aug_product_capture_parameter__scheme_version_ck'},
        {'src': 'param_ref', 'tgt': 'aug_product_capture_parameter__parameter_reference_ck'},
        {'src': 'isalpha', 'tgt': 'aug_product_capture_parameter__alphabetic_only_indicator'},
        {'src': 'cover_code', 'tgt': 'aug_product_capture_parameter__applicable_cover_code'},
        {'src': 'plan_ids', 'tgt': 'aug_product_capture_parameter__applicable_plan_identifier_list'},
        {'src': 'section_id', 'tgt': 'aug_product_capture_parameter__applicable_section_identifier'},
        {'src': 'display_cvr_validate', 'tgt': 'aug_product_capture_parameter__display_and_validate_cover_scope'},
        {'src': 'maxlength', 'tgt': 'aug_product_capture_parameter__maximum_value_length'},
        {'src': 'mem_param_ref', 'tgt': 'aug_product_capture_parameter__member_level_parameter_reference'},
        {'src': 'minlength', 'tgt': 'aug_product_capture_parameter__minimum_value_length'},
        {'src': 'nil_endorse_yn', 'tgt': 'aug_product_capture_parameter__nil_endorsement_allowed_indicator'},
        {'src': 'nil_end_param_ref', 'tgt': 'aug_product_capture_parameter__nil_endorsement_parameter_reference'},
        {'src': 'is_nrsearch', 'tgt': 'aug_product_capture_parameter__nr_search_field_indicator'},
        {'src': 'param_data_type', 'tgt': 'aug_product_capture_parameter__parameter_data_type'},
        {'src': 'param_ref_label', 'tgt': 'aug_product_capture_parameter__parameter_display_label'},
        {'src': 'param_id', 'tgt': 'aug_product_capture_parameter__parameter_identifier'},
        {'src': 'param_list_val', 'tgt': 'aug_product_capture_parameter__parameter_permitted_values_list'},
        {'src': 'param_ref', 'tgt': 'aug_product_capture_parameter__parameter_term_name'},
        {'src': 'is_post_updateyn', 'tgt': 'aug_product_capture_parameter__post_issuance_update_allowed_indicator'},
        {'src': 'post_update', 'tgt': 'aug_product_capture_parameter__post_issuance_update_rule'},
        {'src': 'print_single_member', 'tgt': 'aug_product_capture_parameter__print_once_per_member_indicator'},
        {'src': 'print_yn', 'tgt': 'aug_product_capture_parameter__print_on_document_indicator'},
        {'src': 'transscript_param_ref', 'tgt': 'aug_product_capture_parameter__transcript_parameter_reference'},
        {'src': 'validate_stop_y_n', 'tgt': 'aug_product_capture_parameter__validation_hard_stop_indicator'},
        {'src': 'validate_stop_value', 'tgt': 'aug_product_capture_parameter__validation_stop_trigger_value'}
      ]
    }
] -%}
{%- set output_columns = [
    'product_bk',
    'aug_product_capture_parameter__scheme_version_ck',
    'aug_product_capture_parameter__parameter_reference_ck',
    'aug_product_capture_parameter__alphabetic_only_indicator',
    'aug_product_capture_parameter__applicable_cover_code',
    'aug_product_capture_parameter__applicable_plan_identifier_list',
    'aug_product_capture_parameter__applicable_section_identifier',
    'aug_product_capture_parameter__display_and_validate_cover_scope',
    'aug_product_capture_parameter__maximum_value_length',
    'aug_product_capture_parameter__member_level_parameter_reference',
    'aug_product_capture_parameter__minimum_value_length',
    'aug_product_capture_parameter__nil_endorsement_allowed_indicator',
    'aug_product_capture_parameter__nil_endorsement_parameter_reference',
    'aug_product_capture_parameter__nr_search_field_indicator',
    'aug_product_capture_parameter__parameter_data_type',
    'aug_product_capture_parameter__parameter_display_label',
    'aug_product_capture_parameter__parameter_identifier',
    'aug_product_capture_parameter__parameter_permitted_values_list',
    'aug_product_capture_parameter__parameter_term_name',
    'aug_product_capture_parameter__post_issuance_update_allowed_indicator',
    'aug_product_capture_parameter__post_issuance_update_rule',
    'aug_product_capture_parameter__print_once_per_member_indicator',
    'aug_product_capture_parameter__print_on_document_indicator',
    'aug_product_capture_parameter__transcript_parameter_reference',
    'aug_product_capture_parameter__validation_hard_stop_indicator',
    'aug_product_capture_parameter__validation_stop_trigger_value'
] -%}
{%- set coalesce_rules = {
    'product_bk': ['t0'],
    'aug_product_capture_parameter__scheme_version_ck': ['t0'],
    'aug_product_capture_parameter__parameter_reference_ck': ['t0'],
    'aug_product_capture_parameter__alphabetic_only_indicator': ['t0'],
    'aug_product_capture_parameter__applicable_cover_code': ['t0'],
    'aug_product_capture_parameter__applicable_plan_identifier_list': ['t0'],
    'aug_product_capture_parameter__applicable_section_identifier': ['t0'],
    'aug_product_capture_parameter__display_and_validate_cover_scope': ['t0'],
    'aug_product_capture_parameter__maximum_value_length': ['t0'],
    'aug_product_capture_parameter__member_level_parameter_reference': ['t0'],
    'aug_product_capture_parameter__minimum_value_length': ['t0'],
    'aug_product_capture_parameter__nil_endorsement_allowed_indicator': ['t0'],
    'aug_product_capture_parameter__nil_endorsement_parameter_reference': ['t0'],
    'aug_product_capture_parameter__nr_search_field_indicator': ['t0'],
    'aug_product_capture_parameter__parameter_data_type': ['t0'],
    'aug_product_capture_parameter__parameter_display_label': ['t0'],
    'aug_product_capture_parameter__parameter_identifier': ['t0'],
    'aug_product_capture_parameter__parameter_permitted_values_list': ['t0'],
    'aug_product_capture_parameter__parameter_term_name': ['t0'],
    'aug_product_capture_parameter__post_issuance_update_allowed_indicator': ['t0'],
    'aug_product_capture_parameter__post_issuance_update_rule': ['t0'],
    'aug_product_capture_parameter__print_once_per_member_indicator': ['t0'],
    'aug_product_capture_parameter__print_on_document_indicator': ['t0'],
    'aug_product_capture_parameter__transcript_parameter_reference': ['t0'],
    'aug_product_capture_parameter__validation_hard_stop_indicator': ['t0'],
    'aug_product_capture_parameter__validation_stop_trigger_value': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_product_capture_parameter_pk',
    target_sat='sat_aug_product_capture_parameter'
) }}
