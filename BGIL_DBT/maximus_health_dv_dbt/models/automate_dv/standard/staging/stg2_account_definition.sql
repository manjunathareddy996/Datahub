-- automate_dv.stage() for SAT_ACCOUNT_DEFINITION, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  FINANCIAL_ACCOUNT_HKEY: 'FINANCIAL_ACCOUNT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_CATEGORY'
      - 'ACCOUNT_TYPE'
derived_columns:
  FINANCIAL_ACCOUNT_NK: "case when coalesce(ACCOUNT_DEFINITION__ACCOUNT_CATEGORY, ACCOUNT_DEFINITION__ACCOUNT_TYPE) is not null then 'HUB_FINANCIAL_ACCOUNT|' || FINANCIAL_ACCOUNT_BK end"
  ACCOUNT_CATEGORY: 'ACCOUNT_DEFINITION__ACCOUNT_CATEGORY'
  ACCOUNT_TYPE: 'ACCOUNT_DEFINITION__ACCOUNT_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
