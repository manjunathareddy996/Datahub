{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_TAX_HEAD, table 'BJAZ_GENERIC_LOADER_LOG_TABLE' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_generic_loader_log_table'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TAX_AMOUNT'
derived_columns:
  PARENT_BK: 'pmasterpolicynumber'
  PARENT_NK: "'HUB_POLICY|' || (pmasterpolicynumber)"
  TAX_HEAD_CODE_CK: '!'
  TAX_AMOUNT: 'pservicetax'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GENERIC_LOADER_LOG_TABLE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
