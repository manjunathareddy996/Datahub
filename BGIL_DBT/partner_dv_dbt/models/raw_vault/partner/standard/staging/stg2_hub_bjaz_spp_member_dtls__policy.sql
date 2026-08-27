{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_POLICY branch 'BJAZ_SPP_MEMBER_DTLS'.
-- Provenance: explicit.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_spp_member_dtls'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'policy_number'
  PARENT_NK: "'HUB_POLICY|' || (policy_number)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_SPP_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
