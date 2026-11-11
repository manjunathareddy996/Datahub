{{ config(materialized='view') }}
-- This part feeds SAT_COMMON_ADDRESS only. Original precedence comments are kept below (from stitch_v11_claim).
-- CENTRAL VIEW v11_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EHH_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GENERIC_LOADER_LOG_TABLE (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_SETTLEMENT
--   SAT_AUG_FINTXN_CLAIM_PAYMENT
--   SAT_AUG_PARTY_BANKING
--   SAT_AUG_PROVIDER_BANKING
--   SAT_CLAIM_COMMUNICATION
--   SAT_CLAIM_DISBURSEMENT_BATCH
--   SAT_CLAIM_FNOL
--   SAT_COMMON_ADDRESS
--   SAT_COMMON_GEO
--   SAT_FINTXN_CLAIM_PAYMENT
--   SAT_LNK_ROLE_TPA
--   SAT_LOSS_EVENT_DETAIL
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_CHANNEL
--   LNK_AGREEMENT_PARTY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_LOSS_EVENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_PAYMENT_INSTRUMENT
--   LNK_CLAIM_POLICY
--   LNK_FINTXN_CLAIM
--   LNK_FINTXN_INSTRUMENT
--   LNK_FINTXN_PARTY
--   LNK_FINTXN_POLICY
--   LNK_LOSS_EVENT_LOCATION
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_DOCUMENT
--   LNK_PARTY_LOCATION
--   LNK_PARTY_ORG_UNIT
--   LNK_PARTY_PAYMENT_INSTRUMENT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_LOCATION
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PAYMENT_INSTRUMENT
--   LNK_POLICY_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
-- depends_on: {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_generic_loader_log_table') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hospital_master') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_orphan_reg') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_pp_mem_dtls',
      'alias': 't0',
      'key_column': "coalesce(nullif(upper(trim(to_varchar(dc_address))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(dc_location))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(dc_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(dc_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(dc_pincode))), ''), '')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PP_MEM_DTLS',
      'columns': [
        {'src': 'dc_address', 'tgt': 'common_address__address_line_1'},
        {'src': 'dc_city', 'tgt': 'common_address__city'},
        {'src': 'dc_location', 'tgt': 'common_address__locality'},
        {'src': 'dc_pincode', 'tgt': 'common_address__postal_code'},
        {'src': 'dc_state', 'tgt': 'common_address__state_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_bandhan_medi_clam',
      'alias': 't1',
      'key_column': 'location_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BANDHAN_MEDI_CLAM',
      'columns': [
        {'src': 'coalesce(m_address_line_1, p_address_line_1)', 'tgt': 'common_address__address_line_1'},
        {'src': 'coalesce(m_address_line_2, p_address_line_2)', 'tgt': 'common_address__address_line_2'},
        {'src': 'coalesce(m_city, p_city)', 'tgt': 'common_address__city'},
        {'src': 'coalesce(m_pincode, p_pincode)', 'tgt': 'common_address__postal_code'},
        {'src': 'coalesce(m_state, p_state)', 'tgt': 'common_address__state_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ehh_pol_dtls',
      'alias': 't2',
      'key_column': 'risk_location',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EHH_POL_DTLS',
      'columns': [
        {'src': 'address_line1', 'tgt': 'common_address__address_line_1'},
        {'src': 'address_line2', 'tgt': 'common_address__address_line_2'},
        {'src': 'city', 'tgt': 'common_address__city'},
        {'src': 'area', 'tgt': 'common_address__locality'},
        {'src': 'postcode', 'tgt': 'common_address__postal_code'},
        {'src': 'state', 'tgt': 'common_address__state_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_generic_loader_log_table',
      'alias': 't3',
      'key_column': 'locationcode',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GENERIC_LOADER_LOG_TABLE',
      'columns': [
        {'src': 'building', 'tgt': 'common_address__building_name'},
        {'src': 'city', 'tgt': 'common_address__city'},
        {'src': 'country', 'tgt': 'common_address__country_name'},
        {'src': 'pincode', 'tgt': 'common_address__postal_code'},
        {'src': 'state', 'tgt': 'common_address__state_name'},
        {'src': 'streetname', 'tgt': 'common_address__street_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_id_mem_detls',
      'alias': 't4',
      'key_column': "coalesce(nullif(upper(trim(to_varchar(addline1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(addline2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin))), ''), '')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_ID_MEM_DETLS',
      'columns': [
        {'src': 'addline1', 'tgt': 'common_address__address_line_1'},
        {'src': 'addline2', 'tgt': 'common_address__address_line_2'},
        {'src': 'city', 'tgt': 'common_address__city'},
        {'src': 'pin', 'tgt': 'common_address__postal_code'},
        {'src': 'state', 'tgt': 'common_address__state_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't5',
      'key_column': 'policy_location',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'coalesce(add1, patient_address)', 'tgt': 'common_address__address_line_1'},
        {'src': 'add2', 'tgt': 'common_address__address_line_2'},
        {'src': 'city', 'tgt': 'common_address__city'},
        {'src': 'pin', 'tgt': 'common_address__postal_code'},
        {'src': 'state', 'tgt': 'common_address__state_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hospital_master',
      'alias': 't6',
      'key_column': 'pin_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HOSPITAL_MASTER',
      'columns': [
        {'src': 'address1', 'tgt': 'common_address__address_line_1'},
        {'src': 'address2', 'tgt': 'common_address__address_line_2'},
        {'src': 'city_name', 'tgt': 'common_address__city'},
        {'src': 'pin_code', 'tgt': 'common_address__postal_code'},
        {'src': 'state_name', 'tgt': 'common_address__state_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_inward_dtls',
      'alias': 't7',
      'key_column': 'location_code',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_DTLS',
      'columns': [
        {'src': 'city_name', 'tgt': 'common_address__city'},
        {'src': 'pin_code', 'tgt': 'common_address__postal_code'},
        {'src': 'state_name', 'tgt': 'common_address__state_name'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_orphan_reg',
      'alias': 't8',
      'key_column': 'orphan_loc',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_ORPHAN_REG',
      'columns': [
        {'src': 'address', 'tgt': 'common_address__address_line_1'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't9',
      'key_column': "nullif(upper(trim(coalesce(payee_address, ''))), '')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'coalesce(address, payee_address)', 'tgt': 'common_address__address_line_1'},
        {'src': 'coalesce(city, hospital_city, ins_city)', 'tgt': 'common_address__city'},
        {'src': 'area', 'tgt': 'common_address__locality'},
        {'src': 'pincode', 'tgt': 'common_address__postal_code'},
        {'src': 'coalesce(hospital_state, ins_state, state)', 'tgt': 'common_address__state_name'}
      ]
    }
] -%}
{%- set output_columns = [
    'common_address__address_line_1',
    'common_address__city',
    'common_address__locality',
    'common_address__postal_code',
    'common_address__state_name',
    'common_address__address_line_2',
    'common_address__state_code',
    'common_address__building_name',
    'common_address__country_name',
    'common_address__street_name'
] -%}
{%- set coalesce_rules = {
    'common_address__address_line_1': ['t0', 't1', 't2', 't4', 't5', 't6', 't8', 't9'],
    'common_address__city': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't9'],
    'common_address__locality': ['t0', 't2', 't9'],
    'common_address__postal_code': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't9'],
    'common_address__state_name': ['t0', 't2', 't3', 't4', 't5', 't6', 't7', 't9'],
    'common_address__address_line_2': ['t1', 't2', 't4', 't5', 't6'],
    'common_address__state_code': ['t1'],
    'common_address__building_name': ['t3'],
    'common_address__country_name': ['t3'],
    'common_address__street_name': ['t3']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='location_bk',
    target_sat='sat_common_address'
) }}
