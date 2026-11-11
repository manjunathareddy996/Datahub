{{ config(materialized='view') }}
-- This part feeds SAT_LNK_POLICY_PARTY_ROLE only. Original precedence comments are kept below (from stitch_v23_policy).
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
-- depends_on: {{ ref('stg_health__bjaz_hat_pol_emp_map') }}
-- depends_on: {{ ref('stg_health__ocp_interested_parties') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hat_pol_emp_map',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('EMP:' || coalesce(nullif(trim(policy_no),''),'') || '#' || coalesce(nullif(trim(emp_code),''),''), 'EMP:#'))) || '|' || trim(to_varchar(nullif(trim(policy_no),''))) || '|' || 'ENROLLED_EMPLOYEE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_POL_EMP_MAP',
      'columns': [
        {'src': "nullif('EMP:' || coalesce(nullif(trim(policy_no),''),'') || '#' || coalesce(nullif(trim(emp_code),''),''), 'EMP:#')", 'tgt': 'party_bk'},
        {'src': "nullif(trim(policy_no),'')", 'tgt': 'policy_bk'},
        {'src': "'ENROLLED_EMPLOYEE'", 'tgt': 'lnk_policy_party_role__party_role_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_policy_party_role__role_sequence_ck'},
        {'src': 'effective_date', 'tgt': 'lnk_policy_party_role__role_effective_date'},
        {'src': 'status', 'tgt': 'lnk_policy_party_role__role_status'}
      ]
    },
    {
      'model': 'stg_health__ocp_interested_parties',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif('PARTNER:' || nullif(trim(partner_id),''), 'PARTNER:'))) || '|' || trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_OCP_INTERESTED_PARTIES',
      'columns': [
        {'src': "nullif('PARTNER:' || nullif(trim(partner_id),''), 'PARTNER:')", 'tgt': 'party_bk'},
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_policy_party_role__party_role_type_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_policy_party_role__role_sequence_ck'},
        {'src': 'ip_no', 'tgt': 'lnk_policy_party_role__role_sequence'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'policy_bk',
    'lnk_policy_party_role__party_role_type_ck',
    'lnk_policy_party_role__role_sequence_ck',
    'lnk_policy_party_role__role_effective_date',
    'lnk_policy_party_role__role_status',
    'lnk_policy_party_role__role_sequence'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1'],
    'policy_bk': ['t0', 't1'],
    'lnk_policy_party_role__party_role_type_ck': ['t0', 't1'],
    'lnk_policy_party_role__role_sequence_ck': ['t0', 't1'],
    'lnk_policy_party_role__role_effective_date': ['t0'],
    'lnk_policy_party_role__role_status': ['t0'],
    'lnk_policy_party_role__role_sequence': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='lnk_policy_party_role_pk',
    target_sat='sat_lnk_policy_party_role'
) }}
