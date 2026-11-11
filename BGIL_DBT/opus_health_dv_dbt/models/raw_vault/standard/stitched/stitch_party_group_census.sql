{{ config(materialized='view') }}
-- This part feeds SAT_PARTY_GROUP_CENSUS only. Original precedence comments are kept below (from stitch_v09_claim).
-- CENTRAL VIEW v09_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_USER_TAT (opus_health_v2)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_ECARD_MEMBR_DEL_DTLS (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_CO_RI_SHARE
--   SAT_AUG_CLAIM_PROCESS_STEP_LOG
--   SAT_AUG_PARTY_CLAIM_HISTORY
--   SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_AUG_POLICY_CERTIFICATE
--   SAT_CLAIM_CO_RI_SHARE
--   SAT_CLAIM_RESERVE
--   SAT_DOCUMENT_CHECKLIST
--   SAT_INSTRUMENT_DEFINITION
--   SAT_LOCATION_PROFILE
--   SAT_PARTY_GROUP_CENSUS
--   SAT_PARTY_GROUP_SCHEME
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_DOCUMENT
--   LNK_AGREEMENT_PARTY
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_LOSS_EVENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_PAYMENT_INSTRUMENT
--   LNK_CLAIM_POLICY
--   LNK_FINTXN_ACCOUNT
--   LNK_FINTXN_CLAIM
--   LNK_FINTXN_INSTRUMENT
--   LNK_FINTXN_PARTY
--   LNK_FINTXN_POLICY
--   LNK_LOSS_EVENT_LOCATION
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_DOCUMENT
--   LNK_PARTY_LOCATION
--   LNK_PARTY_PAYMENT_INSTRUMENT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PAYMENT_INSTRUMENT
--   LNK_POLICY_PRODUCT
--   LNK_QUOTE_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bgil_gmc_final_instl_data') }}
-- depends_on: {{ ref('stg_health__bjaz_ecard_membr_del_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
-- depends_on: {{ ref('stg_health__bjaz_hc_part_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bgil_gmc_final_instl_data',
      'alias': 't0',
      'key_column': "emp_code || '|' || coalesce(emp_code, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BGIL_GMC_FINAL_INSTL_DATA',
      'columns': [
        {'src': 'emp_code', 'tgt': 'party_bk'},
        {'src': 'emp_code', 'tgt': 'party_group_census__member_reference_ck'},
        {'src': 'doj', 'tgt': 'party_group_census__date_of_joining'},
        {'src': 'grade_code', 'tgt': 'party_group_census__designation_band'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ecard_membr_del_dtls',
      'alias': 't1',
      'key_column': "emp_code || '|' || coalesce(emp_code, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ECARD_MEMBR_DEL_DTLS',
      'columns': [
        {'src': 'emp_code', 'tgt': 'party_bk'},
        {'src': 'emp_code', 'tgt': 'party_group_census__member_reference_ck'},
        {'src': 'emp_neme', 'tgt': 'party_group_census__member_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_id_mem_detls',
      'alias': 't2',
      'key_column': "member_no || '|' || coalesce(member_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_ID_MEM_DETLS',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': 'member_no', 'tgt': 'party_group_census__member_reference_ck'},
        {'src': 'emp_no', 'tgt': 'party_group_census__employee_id'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hc_part_extn',
      'alias': 't3',
      'key_column': "part_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HC_PART_EXTN',
      'columns': [
        {'src': 'part_id', 'tgt': 'party_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'party_group_census__member_reference_ck'},
        {'src': 'status', 'tgt': 'party_group_census__active_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_coinsu_clm_dtls',
      'alias': 't4',
      'key_column': "ldr_pid || '|' || coalesce(emp_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_COINSU_CLM_DTLS',
      'columns': [
        {'src': 'ldr_pid', 'tgt': 'party_bk'},
        {'src': 'emp_no', 'tgt': 'party_group_census__member_reference_ck'},
        {'src': 'emp_no', 'tgt': 'party_group_census__employee_id'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't5',
      'key_column': "hospital_id || '|' || coalesce(id_card, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'hospital_id', 'tgt': 'party_bk'},
        {'src': 'id_card', 'tgt': 'party_group_census__member_reference_ck'},
        {'src': 'doj', 'tgt': 'party_group_census__date_of_joining'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't6',
      'key_column': "member_id || '|' || coalesce(member_id, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'member_id', 'tgt': 'party_bk'},
        {'src': 'member_id', 'tgt': 'party_group_census__member_reference_ck'},
        {'src': 'grade', 'tgt': 'party_group_census__designation_band'},
        {'src': 'hat_empcode', 'tgt': 'party_group_census__employee_id'},
        {'src': 'employee_location', 'tgt': 'party_group_census__location_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't7',
      'key_column': "payer_code || '|' || coalesce(employee_id, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'payer_code', 'tgt': 'party_bk'},
        {'src': 'employee_id', 'tgt': 'party_group_census__member_reference_ck'},
        {'src': 'employee_id', 'tgt': 'party_group_census__employee_id'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'party_group_census__member_reference_ck',
    'party_group_census__date_of_joining',
    'party_group_census__designation_band',
    'party_group_census__member_name',
    'party_group_census__employee_id',
    'party_group_census__active_indicator',
    'party_group_census__location_reference'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7'],
    'party_group_census__member_reference_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7'],
    'party_group_census__date_of_joining': ['t0', 't5'],
    'party_group_census__designation_band': ['t0', 't6'],
    'party_group_census__member_name': ['t1'],
    'party_group_census__employee_id': ['t2', 't4', 't6', 't7'],
    'party_group_census__active_indicator': ['t3'],
    'party_group_census__location_reference': ['t6']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_group_census_pk',
    target_sat='sat_party_group_census'
) }}
