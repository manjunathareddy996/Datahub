{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_ENDORSEMENT only. Original precedence comments are kept below (from stitch_v23_policy).
-- CENTRAL VIEW v23_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HAT_POL_EMP_MAP (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_POLICY_USERMAPPING (opus_health_legacy_v4)
--   BJAZ_PMJAY_PRMBOOK_DTLS (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
--   BJAZ_VERSIONS_EXTN (opus_health_delta3)
--   OCP_INTERESTED_PARTIES (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COMMON_BUSINESS_AUDIT
--   SAT_AUG_LNK_POLICY_PARTY_ROLE
--   SAT_AUG_PARTY_HIERARCHY
--   SAT_AUG_POLICY_ENDORSEMENT
--   SAT_AUG_POLICY_INTERMEDIARY_SPLIT
--   SAT_COMMON_COMMUNICATION_PREFERENCE
--   SAT_COMMON_LIFECYCLE
--   SAT_LNK_POLICY_PARTY_ROLE
--   SAT_PARTY_DIGITAL_IDENTITY
--   SAT_POLICY_ENDORSEMENT
--   SAT_POLICY_EXTERNAL_TP_LINK
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_FINTXN_POLICY
--   LNK_PARTY_LOCATION
--   LNK_POLICY_ENDORSEMENT
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_pmjay_prmbook_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}
-- depends_on: {{ ref('stg_health__bjaz_versions_extn') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't0',
      'key_column': "contract_id || '|' || coalesce(endorsement_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'endorsement_no', 'tgt': 'policy_endorsement__endorsement_number_ck'},
        {'src': 'endorsement_date', 'tgt': 'policy_endorsement__endorsement_date'},
        {'src': 'endorsement_no', 'tgt': 'policy_endorsement__endorsement_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't1',
      'key_column': "contract_id || '|' || coalesce(add_endorsement_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'add_endorsement_no', 'tgt': 'policy_endorsement__endorsement_number_ck'},
        {'src': 'add_endorsement_no', 'tgt': 'policy_endorsement__endorsement_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't2',
      'key_column': "contract_id || '|' || coalesce(del_endorsement_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'del_endorsement_no', 'tgt': 'policy_endorsement__endorsement_number_ck'},
        {'src': 'del_endorsement_no', 'tgt': 'policy_endorsement__endorsement_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmjay_prmbook_dtls',
      'alias': 't3',
      'key_column': "policy_ref || '|' || coalesce(endt_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMJAY_PRMBOOK_DTLS',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': 'endt_no', 'tgt': 'policy_endorsement__endorsement_number_ck'},
        {'src': 'endt_eff_date', 'tgt': 'policy_endorsement__effective_date'},
        {'src': 'endtpass_on', 'tgt': 'policy_endorsement__endorsement_date'},
        {'src': 'endt_no', 'tgt': 'policy_endorsement__endorsement_number'},
        {'src': 'endt_type', 'tgt': 'policy_endorsement__endorsement_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_endorsement__endorsement_number_ck'},
        {'src': 'endorse_premium', 'tgt': 'policy_endorsement__premium_impact_amount'},
        {'src': 'endorse_stamp_amt', 'tgt': 'policy_endorsement__stamp_duty_on_endorsement'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't5',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_endorsement__endorsement_number_ck'},
        {'src': 'endt_reason', 'tgt': 'policy_endorsement__endorsement_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_versions_extn',
      'alias': 't6',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(endorsement_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_VERSIONS_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'endorsement_no', 'tgt': 'policy_endorsement__endorsement_number_ck'},
        {'src': 'endorsement_no', 'tgt': 'policy_endorsement__endorsement_number'},
        {'src': 'endorse_reason', 'tgt': 'policy_endorsement__endorsement_reason'},
        {'src': 'endorse_sub_type', 'tgt': 'policy_endorsement__endorsement_sub_type'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'policy_endorsement__endorsement_number_ck',
    'policy_endorsement__endorsement_date',
    'policy_endorsement__endorsement_number',
    'policy_endorsement__effective_date',
    'policy_endorsement__endorsement_type',
    'policy_endorsement__premium_impact_amount',
    'policy_endorsement__stamp_duty_on_endorsement',
    'policy_endorsement__endorsement_reason',
    'policy_endorsement__endorsement_sub_type'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'policy_endorsement__endorsement_number_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'policy_endorsement__endorsement_date': ['t0', 't3'],
    'policy_endorsement__endorsement_number': ['t0', 't1', 't2', 't3', 't6'],
    'policy_endorsement__effective_date': ['t3'],
    'policy_endorsement__endorsement_type': ['t3'],
    'policy_endorsement__premium_impact_amount': ['t4'],
    'policy_endorsement__stamp_duty_on_endorsement': ['t4'],
    'policy_endorsement__endorsement_reason': ['t5', 't6'],
    'policy_endorsement__endorsement_sub_type': ['t6']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_endorsement_pk',
    target_sat='sat_policy_endorsement'
) }}
