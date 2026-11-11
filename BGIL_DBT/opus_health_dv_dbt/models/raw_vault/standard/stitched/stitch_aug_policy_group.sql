{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_GROUP only. Original precedence comments are kept below (from stitch_v33_quote).
-- CENTRAL VIEW v33_quote -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1 (opus_health_v2)
--   BJAZ_HM_MEMBER_HLTH_DTLS (opus_health_v2)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PARTY_ORGANISATION_PROFILE
--   SAT_AUG_POLICY_GROUP
--   SAT_AUG_POLICY_GROUP_DOCUMENT_CONTROL
--   SAT_AUG_PROPOSAL_HEADER
--   SAT_AUG_PROPOSAL_UNDERWRITING
--   SAT_AUG_QUOTE_HEADER
--   SAT_AUG_QUOTE_PREMIUM_RATE_AGE_BAND
--   SAT_AUG_QUOTE_PREMIUM_RATE_SLAB
--   SAT_AUG_QUOTE_RATING
--   SAT_AUG_RISK_HEALTH_MEMBER_COVERAGE
--   SAT_POLICY_DOC_CHECKLIST
--   SAT_QUOTE_RATING_INPUT
--   SAT_RISK_HEALTH_PED_WAITING
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_gc_control') }}
-- depends_on: {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_hlth_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_gmc_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_gc_control',
      'alias': 't0',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_GC_CONTROL',
      'columns': [
        {'src': 'ckyc_yn', 'tgt': 'aug_policy_group__ckyc_capture_required_indicator'},
        {'src': 'corona_yn', 'tgt': 'aug_policy_group__corona_cover_variant_enabled_indicator'},
        {'src': 'ff_details_yn', 'tgt': 'aug_policy_group__family_floater_details_captured_indicator'},
        {'src': 'login_id', 'tgt': 'aug_policy_group__group_contract_portal_login_identifier'},
        {'src': 'gc_hcm_no_of_days_mul', 'tgt': 'aug_policy_group__group_cover_day_count_multiplier'},
        {'src': 'gc_hcm_no_of_days_years_mul', 'tgt': 'aug_policy_group__group_cover_day_count_years_multiplier'},
        {'src': 'scheme_code', 'tgt': 'aug_policy_group__group_scheme_code'},
        {'src': 'gc_issuance_hat_refered_yn', 'tgt': 'aug_policy_group__health_assessment_tool_referral_indicator'},
        {'src': 'isactive', 'tgt': 'aug_policy_group__master_contract_configuration_active_indicator'},
        {'src': 'bmi_calculation_yn', 'tgt': 'aug_policy_group__member_bmi_calculation_indicator'},
        {'src': 'loader_yn', 'tgt': 'aug_policy_group__member_bulk_loader_enabled_indicator'},
        {'src': 'loader_type', 'tgt': 'aug_policy_group__member_bulk_loader_format'},
        {'src': 'mem_dob_rate_age_val_yn', 'tgt': 'aug_policy_group__member_dob_rating_age_validation_indicator'},
        {'src': 'mem_data_yn', 'tgt': 'aug_policy_group__member_level_data_captured_indicator'},
        {'src': 'bypass_mobile_yn', 'tgt': 'aug_policy_group__mobile_capture_bypass_allowed_indicator'},
        {'src': 'remapping_master_policy', 'tgt': 'aug_policy_group__remapped_master_policy_reference'},
        {'src': 'si_in_rate_factor_yn', 'tgt': 'aug_policy_group__sum_insured_rating_factor_indicator'},
        {'src': 'uw_remarks_yn', 'tgt': 'aug_policy_group__underwriting_remarks_captured_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't1',
      'key_column': "nullif(trim(policy_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'issuancewithdata_yn', 'tgt': 'aug_policy_group__issuance_with_member_data_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't2',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': 'no_of_dependents', 'tgt': 'aug_policy_group__dependent_member_count'},
        {'src': 'relationship', 'tgt': 'aug_policy_group__eligible_relationship_set'},
        {'src': 'risk_covered', 'tgt': 'aug_policy_group__family_definition_description'},
        {'src': 'members_per_family', 'tgt': 'aug_policy_group__maximum_members_per_family'},
        {'src': 'parental_si_restriction', 'tgt': 'aug_policy_group__parental_sum_insured_restriction'},
        {'src': 'no_of_employees', 'tgt': 'aug_policy_group__primary_member_count'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't3',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': 'gmc_group_no', 'tgt': 'aug_policy_group__group_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ecard_pol_dtls_config',
      'alias': 't4',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ECARD_POL_DTLS_CONFIG',
      'columns': [
        {'src': 'comp_contr_amt', 'tgt': 'aug_policy_group__employer_contribution_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't5',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'member_count_expiring', 'tgt': 'aug_policy_group__expiring_member_count'},
        {'src': 'final_memb_count_atexpiry', 'tgt': 'aug_policy_group__final_member_count_at_expiry'},
        {'src': 'addition_in_year', 'tgt': 'aug_policy_group__members_added_in_year'},
        {'src': 'deletion_inayear', 'tgt': 'aug_policy_group__members_deleted_in_year'},
        {'src': 'age_bracket', 'tgt': 'aug_policy_group__member_age_band'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gmc_bases_extn',
      'alias': 't6',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GMC_BASES_EXTN',
      'columns': [
        {'src': 'relationship', 'tgt': 'aug_policy_group__eligible_relationship_set'},
        {'src': 'risk_covered', 'tgt': 'aug_policy_group__family_definition_description'},
        {'src': 'family_includes', 'tgt': 'aug_policy_group__family_inclusion_definition'},
        {'src': 'members_per_family', 'tgt': 'aug_policy_group__maximum_members_per_family'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't7',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': 'no_of_dependents', 'tgt': 'aug_policy_group__dependent_member_count'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_group__ckyc_capture_required_indicator',
    'aug_policy_group__corona_cover_variant_enabled_indicator',
    'aug_policy_group__family_floater_details_captured_indicator',
    'aug_policy_group__group_contract_portal_login_identifier',
    'aug_policy_group__group_cover_day_count_multiplier',
    'aug_policy_group__group_cover_day_count_years_multiplier',
    'aug_policy_group__group_scheme_code',
    'aug_policy_group__health_assessment_tool_referral_indicator',
    'aug_policy_group__master_contract_configuration_active_indicator',
    'aug_policy_group__member_bmi_calculation_indicator',
    'aug_policy_group__member_bulk_loader_enabled_indicator',
    'aug_policy_group__member_bulk_loader_format',
    'aug_policy_group__member_dob_rating_age_validation_indicator',
    'aug_policy_group__member_level_data_captured_indicator',
    'aug_policy_group__mobile_capture_bypass_allowed_indicator',
    'aug_policy_group__remapped_master_policy_reference',
    'aug_policy_group__sum_insured_rating_factor_indicator',
    'aug_policy_group__underwriting_remarks_captured_indicator',
    'aug_policy_group__issuance_with_member_data_indicator',
    'aug_policy_group__dependent_member_count',
    'aug_policy_group__eligible_relationship_set',
    'aug_policy_group__family_definition_description',
    'aug_policy_group__maximum_members_per_family',
    'aug_policy_group__parental_sum_insured_restriction',
    'aug_policy_group__primary_member_count',
    'aug_policy_group__group_number',
    'aug_policy_group__employer_contribution_amount',
    'aug_policy_group__expiring_member_count',
    'aug_policy_group__final_member_count_at_expiry',
    'aug_policy_group__members_added_in_year',
    'aug_policy_group__members_deleted_in_year',
    'aug_policy_group__member_age_band',
    'aug_policy_group__family_inclusion_definition'
] -%}
{%- set coalesce_rules = {
    'aug_policy_group__ckyc_capture_required_indicator': ['t0'],
    'aug_policy_group__corona_cover_variant_enabled_indicator': ['t0'],
    'aug_policy_group__family_floater_details_captured_indicator': ['t0'],
    'aug_policy_group__group_contract_portal_login_identifier': ['t0'],
    'aug_policy_group__group_cover_day_count_multiplier': ['t0'],
    'aug_policy_group__group_cover_day_count_years_multiplier': ['t0'],
    'aug_policy_group__group_scheme_code': ['t0'],
    'aug_policy_group__health_assessment_tool_referral_indicator': ['t0'],
    'aug_policy_group__master_contract_configuration_active_indicator': ['t0'],
    'aug_policy_group__member_bmi_calculation_indicator': ['t0'],
    'aug_policy_group__member_bulk_loader_enabled_indicator': ['t0'],
    'aug_policy_group__member_bulk_loader_format': ['t0'],
    'aug_policy_group__member_dob_rating_age_validation_indicator': ['t0'],
    'aug_policy_group__member_level_data_captured_indicator': ['t0'],
    'aug_policy_group__mobile_capture_bypass_allowed_indicator': ['t0'],
    'aug_policy_group__remapped_master_policy_reference': ['t0'],
    'aug_policy_group__sum_insured_rating_factor_indicator': ['t0'],
    'aug_policy_group__underwriting_remarks_captured_indicator': ['t0'],
    'aug_policy_group__issuance_with_member_data_indicator': ['t1'],
    'aug_policy_group__dependent_member_count': ['t2', 't7'],
    'aug_policy_group__eligible_relationship_set': ['t2', 't6'],
    'aug_policy_group__family_definition_description': ['t2', 't6'],
    'aug_policy_group__maximum_members_per_family': ['t2', 't6'],
    'aug_policy_group__parental_sum_insured_restriction': ['t2'],
    'aug_policy_group__primary_member_count': ['t2'],
    'aug_policy_group__group_number': ['t3'],
    'aug_policy_group__employer_contribution_amount': ['t4'],
    'aug_policy_group__expiring_member_count': ['t5'],
    'aug_policy_group__final_member_count_at_expiry': ['t5'],
    'aug_policy_group__members_added_in_year': ['t5'],
    'aug_policy_group__members_deleted_in_year': ['t5'],
    'aug_policy_group__member_age_band': ['t5'],
    'aug_policy_group__family_inclusion_definition': ['t6']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_group'
) }}
