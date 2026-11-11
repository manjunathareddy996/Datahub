{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_COVERAGE_SCHEDULE only. Original precedence comments are kept below (from stitch_v25_policy).
-- CENTRAL VIEW v25_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_COVERS_EXT (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BA_HCP_DT_POL_COV (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_STARPKG_COVER_DTLS (opus_health_delta3)
--   OCP_POLICY_COVERS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_COVERAGE_SCHEDULE
--   SAT_POLICY_COVERAGE_SCHEDULE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_covers_ext') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_cover_dtls') }}
-- depends_on: {{ ref('stg_health__ocp_policy_covers') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_covers_ext',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(cover_code, '~') || '|' || coalesce(cover_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_COVERS_EXT',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cover_code', 'tgt': 'aug_policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cover_no', 'tgt': 'aug_policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'plan_id', 'tgt': 'aug_policy_coverage_schedule__plan_reference'},
        {'src': 'section_id', 'tgt': 'aug_policy_coverage_schedule__section_reference'},
        {'src': 'version_no', 'tgt': 'aug_policy_coverage_schedule__source_row_version_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_cover_dtls',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(cover_code, '~') || '|' || coalesce(cover_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_COVER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cover_code', 'tgt': 'aug_policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cover_no', 'tgt': 'aug_policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'cover_plan', 'tgt': 'aug_policy_coverage_schedule__plan_reference'},
        {'src': 'section_code', 'tgt': 'aug_policy_coverage_schedule__section_reference'},
        {'src': 'version_no', 'tgt': 'aug_policy_coverage_schedule__source_row_version_number'}
      ]
    },
    {
      'model': 'stg_health__ocp_policy_covers',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(cover_code, '~') || '|' || coalesce(cover_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_OCP_POLICY_COVERS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cover_code', 'tgt': 'aug_policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cover_no', 'tgt': 'aug_policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'agent_commission_company_share', 'tgt': 'aug_policy_coverage_schedule__agent_commission_company_share_amount'},
        {'src': 'agent_commission_com_share_swf', 'tgt': 'aug_policy_coverage_schedule__agent_commission_company_share_currency_code'},
        {'src': 'agent_commission_whole_cover', 'tgt': 'aug_policy_coverage_schedule__agent_commission_whole_cover_amount'},
        {'src': 'agent_commission_whole_cov_swf', 'tgt': 'aug_policy_coverage_schedule__agent_commission_whole_cover_currency_code'},
        {'src': 'cvc_code', 'tgt': 'aug_policy_coverage_schedule__cover_variant_classification_code'},
        {'src': 'share_portion', 'tgt': 'aug_policy_coverage_schedule__co_insurance_share_portion'},
        {'src': 'ftpremium_or_company_share', 'tgt': 'aug_policy_coverage_schedule__full_term_premium_original_company_share'},
        {'src': 'ftpremium_or_company_share_swf', 'tgt': 'aug_policy_coverage_schedule__full_term_premium_original_company_share_currency_code'},
        {'src': 'ftpremium_or_whole_cover', 'tgt': 'aug_policy_coverage_schedule__full_term_premium_original_whole_cover'},
        {'src': 'ftpremium_or_whole_cover_swf', 'tgt': 'aug_policy_coverage_schedule__full_term_premium_original_whole_cover_currency_code'},
        {'src': 'ftpremium_sys_company_share', 'tgt': 'aug_policy_coverage_schedule__full_term_premium_system_company_share'},
        {'src': 'ftpremium_sys_comp_share_swf', 'tgt': 'aug_policy_coverage_schedule__full_term_premium_system_company_share_currency_code'},
        {'src': 'ftpremium_sys_whole_cover_swf', 'tgt': 'aug_policy_coverage_schedule__full_term_premium_system_whole_cover_currency_code'},
        {'src': 'pcov_contract_id', 'tgt': 'aug_policy_coverage_schedule__parent_coverage_contract_reference'},
        {'src': 'pcov_partition_no', 'tgt': 'aug_policy_coverage_schedule__parent_coverage_partition_number'},
        {'src': 'pcov_cover_code', 'tgt': 'aug_policy_coverage_schedule__parent_coverage_reference'},
        {'src': 'pcov_cover_no', 'tgt': 'aug_policy_coverage_schedule__parent_coverage_sequence'},
        {'src': 'reinsurable_risk_amount', 'tgt': 'aug_policy_coverage_schedule__reinsurable_risk_amount'},
        {'src': 'reinsurable_risk_amount_swf', 'tgt': 'aug_policy_coverage_schedule__reinsurable_risk_amount_currency_code'},
        {'src': 'version_no', 'tgt': 'aug_policy_coverage_schedule__source_row_version_number'},
        {'src': 'sum_insured_company_share', 'tgt': 'aug_policy_coverage_schedule__sum_insured_company_share'},
        {'src': 'sum_insured_company_share_swf', 'tgt': 'aug_policy_coverage_schedule__sum_insured_company_share_currency_code'},
        {'src': 'sum_insured_whole_cover_swf', 'tgt': 'aug_policy_coverage_schedule__sum_insured_whole_cover_currency_code'},
        {'src': 'surcharge_discount', 'tgt': 'aug_policy_coverage_schedule__surcharge_or_discount_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'aug_policy_coverage_schedule__coverage_reference_ck',
    'aug_policy_coverage_schedule__coverage_sequence_ck',
    'aug_policy_coverage_schedule__plan_reference',
    'aug_policy_coverage_schedule__section_reference',
    'aug_policy_coverage_schedule__source_row_version_number',
    'aug_policy_coverage_schedule__agent_commission_company_share_amount',
    'aug_policy_coverage_schedule__agent_commission_company_share_currency_code',
    'aug_policy_coverage_schedule__agent_commission_whole_cover_amount',
    'aug_policy_coverage_schedule__agent_commission_whole_cover_currency_code',
    'aug_policy_coverage_schedule__cover_variant_classification_code',
    'aug_policy_coverage_schedule__co_insurance_share_portion',
    'aug_policy_coverage_schedule__full_term_premium_original_company_share',
    'aug_policy_coverage_schedule__full_term_premium_original_company_share_currency_code',
    'aug_policy_coverage_schedule__full_term_premium_original_whole_cover',
    'aug_policy_coverage_schedule__full_term_premium_original_whole_cover_currency_code',
    'aug_policy_coverage_schedule__full_term_premium_system_company_share',
    'aug_policy_coverage_schedule__full_term_premium_system_company_share_currency_code',
    'aug_policy_coverage_schedule__full_term_premium_system_whole_cover_currency_code',
    'aug_policy_coverage_schedule__parent_coverage_contract_reference',
    'aug_policy_coverage_schedule__parent_coverage_partition_number',
    'aug_policy_coverage_schedule__parent_coverage_reference',
    'aug_policy_coverage_schedule__parent_coverage_sequence',
    'aug_policy_coverage_schedule__reinsurable_risk_amount',
    'aug_policy_coverage_schedule__reinsurable_risk_amount_currency_code',
    'aug_policy_coverage_schedule__sum_insured_company_share',
    'aug_policy_coverage_schedule__sum_insured_company_share_currency_code',
    'aug_policy_coverage_schedule__sum_insured_whole_cover_currency_code',
    'aug_policy_coverage_schedule__surcharge_or_discount_amount'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0', 't1', 't2'],
    'aug_policy_coverage_schedule__coverage_reference_ck': ['t0', 't1', 't2'],
    'aug_policy_coverage_schedule__coverage_sequence_ck': ['t0', 't1', 't2'],
    'aug_policy_coverage_schedule__plan_reference': ['t0', 't1'],
    'aug_policy_coverage_schedule__section_reference': ['t0', 't1'],
    'aug_policy_coverage_schedule__source_row_version_number': ['t0', 't1', 't2'],
    'aug_policy_coverage_schedule__agent_commission_company_share_amount': ['t2'],
    'aug_policy_coverage_schedule__agent_commission_company_share_currency_code': ['t2'],
    'aug_policy_coverage_schedule__agent_commission_whole_cover_amount': ['t2'],
    'aug_policy_coverage_schedule__agent_commission_whole_cover_currency_code': ['t2'],
    'aug_policy_coverage_schedule__cover_variant_classification_code': ['t2'],
    'aug_policy_coverage_schedule__co_insurance_share_portion': ['t2'],
    'aug_policy_coverage_schedule__full_term_premium_original_company_share': ['t2'],
    'aug_policy_coverage_schedule__full_term_premium_original_company_share_currency_code': ['t2'],
    'aug_policy_coverage_schedule__full_term_premium_original_whole_cover': ['t2'],
    'aug_policy_coverage_schedule__full_term_premium_original_whole_cover_currency_code': ['t2'],
    'aug_policy_coverage_schedule__full_term_premium_system_company_share': ['t2'],
    'aug_policy_coverage_schedule__full_term_premium_system_company_share_currency_code': ['t2'],
    'aug_policy_coverage_schedule__full_term_premium_system_whole_cover_currency_code': ['t2'],
    'aug_policy_coverage_schedule__parent_coverage_contract_reference': ['t2'],
    'aug_policy_coverage_schedule__parent_coverage_partition_number': ['t2'],
    'aug_policy_coverage_schedule__parent_coverage_reference': ['t2'],
    'aug_policy_coverage_schedule__parent_coverage_sequence': ['t2'],
    'aug_policy_coverage_schedule__reinsurable_risk_amount': ['t2'],
    'aug_policy_coverage_schedule__reinsurable_risk_amount_currency_code': ['t2'],
    'aug_policy_coverage_schedule__sum_insured_company_share': ['t2'],
    'aug_policy_coverage_schedule__sum_insured_company_share_currency_code': ['t2'],
    'aug_policy_coverage_schedule__sum_insured_whole_cover_currency_code': ['t2'],
    'aug_policy_coverage_schedule__surcharge_or_discount_amount': ['t2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_policy_coverage_schedule_pk',
    target_sat='sat_aug_policy_coverage_schedule'
) }}
