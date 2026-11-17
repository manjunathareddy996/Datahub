{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL ma_sat_multi_source() for SAT_LNK_POLICY_PARTY_ROLE, per data_5a.js M2
-- (parent LNK_POLICY_PARTY, canonical childkey "Party Role Type + Role Sequence").
-- Party Role Type is NOT mapped in Partner's source -- childkey here is Role Sequence
-- only. Payload is PRIMARY_INDICATOR (TOP_INDICATOR); the other canonical attributes
-- (Party Role Type, Role Category, Intermediary Sub-Type, Attribution Percentage,
-- Role Effective/End Date, Role Status, Appointment Reference) are unmapped.
-- Flagged for the mapper, not fabricated.
--
-- ma_sat_multi_source groups change detection by (POLICY_PARTY_HKEY, RECORD_SOURCE) and takes the
-- watermark from MAX(DBT_RUN_TS) of OPUS_PARTNER_* rows only, so this project never compares
-- against the other projects' rows on the shared table, even though their childkeys differ.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_pprole_ocp_interested_parties'
src_pk: 'POLICY_PARTY_HKEY'
src_cdk:
  - 'ROLE_SEQUENCE'
src_payload:
  - 'PRIMARY_INDICATOR'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_pprole_ocp_interested_parties: 'OPUS_PARTNER'
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
                           'stg2_pprole_ocp_interested_parties': ['PRIMARY_INDICATOR']
                       }) }}
