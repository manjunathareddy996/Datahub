{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_POLICY branch 'BJAZ_CTNGY_FF_DTLS_EXTN'.
-- Provenance: explicit.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_ctngy_ff_dtls_extn'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CTNGY_FF_DTLS_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
