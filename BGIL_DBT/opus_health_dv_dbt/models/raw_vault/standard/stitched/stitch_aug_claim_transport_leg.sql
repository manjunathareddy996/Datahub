{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_TRANSPORT_LEG only. Original precedence comments are kept below (from stitch_v05_claim).
-- CENTRAL VIEW v05_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_CLAIM_CLOSE (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_AUTOALLOCATION (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_HM_PREAUTH_QUERY (opus_health_legacy_v4)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
--   NG_FAX_INWARD_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CASE_HEADER
--   SAT_AUG_CLAIM_COVER_SECTION_ASSESSMENT
--   SAT_AUG_CLAIM_DISABILITY_HEAD
--   SAT_AUG_CLAIM_HEADER
--   SAT_AUG_CLAIM_HOSPITAL_DAY_LIMIT
--   SAT_AUG_CLAIM_PA_DETAIL
--   SAT_AUG_CLAIM_QUALITY_AUDIT
--   SAT_AUG_CLAIM_SLA_TRACKING
--   SAT_AUG_CLAIM_TRANSPORT_LEG
--   SAT_CASE_HEADER
--   SAT_CLAIM_RESERVE_HEAD
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CASE_DOCUMENT
--   LNK_CASE_PARTY
--   LNK_CLAIM_CASE
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_POLICY
--   LNK_CLAIM_RISK_OBJECT
--   LNK_PARTY_DOCUMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_hcs_tech_assess_cov') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'aug_claim_transport_leg__cover_section_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'aug_claim_transport_leg__transport_mode_code_ck'},
        {'src': 'travel_date', 'tgt': 'aug_claim_transport_leg__journey_date'},
        {'src': 'trv_to_city', 'tgt': 'aug_claim_transport_leg__journey_destination_city'},
        {'src': 'trv_from_city', 'tgt': 'aug_claim_transport_leg__journey_origin_city'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~') || '|' || 'AIR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_transport_leg__cover_section_code_ck'},
        {'src': "'AIR'", 'tgt': 'aug_claim_transport_leg__transport_mode_code_ck'},
        {'src': 'air_amb_type', 'tgt': 'aug_claim_transport_leg__ambulance_type'},
        {'src': 'arrival', 'tgt': 'aug_claim_transport_leg__transport_arrival'},
        {'src': 'departure', 'tgt': 'aug_claim_transport_leg__transport_departure'},
        {'src': 'provider_address', 'tgt': 'aug_claim_transport_leg__transport_provider_address_text'},
        {'src': 'contact_details', 'tgt': 'aug_claim_transport_leg__transport_provider_contact_number'},
        {'src': 'provider_name', 'tgt': 'aug_claim_transport_leg__transport_provider_name'},
        {'src': 'std_code', 'tgt': 'aug_claim_transport_leg__transport_provider_std_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~') || '|' || 'ROAD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_transport_leg__cover_section_code_ck'},
        {'src': "'ROAD'", 'tgt': 'aug_claim_transport_leg__transport_mode_code_ck'},
        {'src': 'road_amb_type', 'tgt': 'aug_claim_transport_leg__ambulance_type'},
        {'src': 'road_arrival', 'tgt': 'aug_claim_transport_leg__transport_arrival'},
        {'src': 'road_departure', 'tgt': 'aug_claim_transport_leg__transport_departure'},
        {'src': 'road_provider_add', 'tgt': 'aug_claim_transport_leg__transport_provider_address_text'},
        {'src': 'road_contact_dtls', 'tgt': 'aug_claim_transport_leg__transport_provider_contact_number'},
        {'src': 'road_provider_name', 'tgt': 'aug_claim_transport_leg__transport_provider_name'},
        {'src': 'road_std_code', 'tgt': 'aug_claim_transport_leg__transport_provider_std_code'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_bk',
    'aug_claim_transport_leg__cover_section_code_ck',
    'aug_claim_transport_leg__transport_mode_code_ck',
    'aug_claim_transport_leg__journey_date',
    'aug_claim_transport_leg__journey_destination_city',
    'aug_claim_transport_leg__journey_origin_city',
    'aug_claim_transport_leg__ambulance_type',
    'aug_claim_transport_leg__transport_arrival',
    'aug_claim_transport_leg__transport_departure',
    'aug_claim_transport_leg__transport_provider_address_text',
    'aug_claim_transport_leg__transport_provider_contact_number',
    'aug_claim_transport_leg__transport_provider_name',
    'aug_claim_transport_leg__transport_provider_std_code'
] -%}
{%- set coalesce_rules = {
    'claim_bk': ['t0', 't1', 't2'],
    'aug_claim_transport_leg__cover_section_code_ck': ['t0', 't1', 't2'],
    'aug_claim_transport_leg__transport_mode_code_ck': ['t0', 't1', 't2'],
    'aug_claim_transport_leg__journey_date': ['t0'],
    'aug_claim_transport_leg__journey_destination_city': ['t0'],
    'aug_claim_transport_leg__journey_origin_city': ['t0'],
    'aug_claim_transport_leg__ambulance_type': ['t1', 't2'],
    'aug_claim_transport_leg__transport_arrival': ['t1', 't2'],
    'aug_claim_transport_leg__transport_departure': ['t1', 't2'],
    'aug_claim_transport_leg__transport_provider_address_text': ['t1', 't2'],
    'aug_claim_transport_leg__transport_provider_contact_number': ['t1', 't2'],
    'aug_claim_transport_leg__transport_provider_name': ['t1', 't2'],
    'aug_claim_transport_leg__transport_provider_std_code': ['t1', 't2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_claim_transport_leg_pk',
    target_sat='sat_aug_claim_transport_leg'
) }}
