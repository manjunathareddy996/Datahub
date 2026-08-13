{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_DIGITAL_IDENTITY, table 'BJAZ_HM_POLICY_USERMAPPING' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_policy_usermapping'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOGIN_IDENTIFIER'
derived_columns:
  PARENT_BK: 'loginname'
  PARENT_NK: "'HUB_PARTY|' || (loginname)"
  LOGIN_IDENTIFIER: 'loginname'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_POLICY_USERMAPPING'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
