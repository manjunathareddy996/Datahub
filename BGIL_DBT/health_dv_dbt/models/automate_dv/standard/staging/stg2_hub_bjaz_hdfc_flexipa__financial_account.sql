{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for HUB_FINANCIAL_ACCOUNT branch 'BJAZ_HDFC_FLEXIPA'.
-- Not covered by a stitch for this hub -- FINANCIAL_ACCOUNT_HKEY hashed directly here,
-- namespaced ('HUB_FINANCIAL_ACCOUNT|' || raw key), same convention as every other hkey
-- in this build (see gen_common.namespaced_hash). PARENT_BK is the raw,
-- un-namespaced business key -- used as hub()'s src_nk display column, same
-- column name every stitch-stage model already exposes for this purpose.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hdfc_flexipa'
hashed_columns:
  FINANCIAL_ACCOUNT_HKEY: 'FINANCIAL_ACCOUNT_NK'
derived_columns:
  PARENT_BK: 's_account_number'
  FINANCIAL_ACCOUNT_NK: "'HUB_FINANCIAL_ACCOUNT|' || s_account_number"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HDFC_FLEXIPA'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
