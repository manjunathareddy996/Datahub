{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_FINANCIAL_ACCOUNT branch 'BJAZ_HEALTH_WEBSERVICE_INFO'.
-- Not covered by a stitch for this hub -- FINANCIAL_ACCOUNT_HKEY hashed directly here,
-- namespaced ('HUB_FINANCIAL_ACCOUNT|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  FINANCIAL_ACCOUNT_HKEY: 'FINANCIAL_ACCOUNT_NK'
derived_columns:
  PARENT_BK: 'loan_accno'
  FINANCIAL_ACCOUNT_NK: "'HUB_FINANCIAL_ACCOUNT|' || loan_accno"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
