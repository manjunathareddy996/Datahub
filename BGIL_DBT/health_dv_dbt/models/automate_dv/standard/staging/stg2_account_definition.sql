{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_account_definition -- serves SAT_ACCOUNT_DEFINITION.
-- The ONE place FINANCIAL_ACCOUNT_HK gets hashed for this cluster (namespaced: 'HUB_FINANCIAL_ACCOUNT|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_account_definition'
hashed_columns:
  FINANCIAL_ACCOUNT_HKEY: 'FINANCIAL_ACCOUNT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_CATEGORY'
      - 'ACCOUNT_TYPE'
      - 'CLOSING_DATE'
derived_columns:
  FINANCIAL_ACCOUNT_NK: "'HUB_FINANCIAL_ACCOUNT|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
