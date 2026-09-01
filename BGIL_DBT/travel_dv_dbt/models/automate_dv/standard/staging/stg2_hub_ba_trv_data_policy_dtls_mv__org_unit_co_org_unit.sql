{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_ORG_UNIT branch 'BA_TRV_DATA_POLICY_DTLS_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  ORG_UNIT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'co_org_unit'
  PARENT_NK: "'HUB_ORG_UNIT|' || (co_org_unit)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
