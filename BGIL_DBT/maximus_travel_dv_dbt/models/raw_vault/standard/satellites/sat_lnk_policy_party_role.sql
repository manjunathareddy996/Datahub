{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat_multi_source() for SAT_LNK_POLICY_PARTY_ROLE.
-- Writes the SAME physical table as opus_partner / opus_health: separate projects, separate
-- pipelines, one shared vault. Grain is unchanged: POLICY_PARTY_HKEY, multi-active on
-- PARTY_ROLE_TYPE + ROLE_SEQUENCE, bare HASHDIFF.
--
-- ma_sat_multi_source groups change detection by (POLICY_PARTY_HKEY, RECORD_SOURCE) and takes the
-- watermark from MAX(DBT_RUN_TS) of MAXIMUS_TRAVEL_* rows only, so this project never compares
-- against (or is compared by) the other projects' rows, even though their cdk sets differ.
-- One satfeed per stage (no UNION).

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_ins_mbr'
  - 'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_ins_mbr_party_relation'
  - 'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_policy_relation'
  - 'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_prp'
  - 'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_prp_party_relation'
src_pk: 'POLICY_PARTY_HKEY'
src_cdk:
  - 'PARTY_ROLE_TYPE'
  - 'ROLE_SEQUENCE'
src_payload:
  - 'ATTRIBUTION_PERCENTAGE'
  - 'ROLE_EFFECTIVE_DATE'
  - 'ROLE_END_DATE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mt_sat_lnk_policy_party_role__uwr_pol_ins_mbr: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_lnk_policy_party_role__uwr_pol_ins_mbr_party_relation: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_lnk_policy_party_role__uwr_pol_policy_relation: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_lnk_policy_party_role__uwr_pol_prp: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_lnk_policy_party_role__uwr_pol_prp_party_relation: 'MAXIMUS_TRAVEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_record_source_map=metadata_dict['src_record_source_map'],
                       src_column_map={
                        'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_ins_mbr': ['ATTRIBUTION_PERCENTAGE', 'ROLE_EFFECTIVE_DATE', 'ROLE_END_DATE'],
                        'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_ins_mbr_party_relation': ['ATTRIBUTION_PERCENTAGE', 'ROLE_EFFECTIVE_DATE', 'ROLE_END_DATE'],
                        'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_policy_relation': ['ATTRIBUTION_PERCENTAGE', 'ROLE_EFFECTIVE_DATE', 'ROLE_END_DATE'],
                        'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_prp': ['ATTRIBUTION_PERCENTAGE', 'ROLE_EFFECTIVE_DATE', 'ROLE_END_DATE'],
                        'satfeed_mt_sat_lnk_policy_party_role__uwr_pol_prp_party_relation': ['ATTRIBUTION_PERCENTAGE', 'ROLE_EFFECTIVE_DATE', 'ROLE_END_DATE']
                       }) }}
