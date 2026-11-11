-- automate_dv.stage() for SAT_ACCOUNT_BALANCE, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  FINANCIAL_ACCOUNT_HKEY: 'FINANCIAL_ACCOUNT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OPENING_BALANCE'
derived_columns:
  FINANCIAL_ACCOUNT_NK: "case when ACCOUNT_BALANCE__OPENING_BALANCE is not null then 'HUB_FINANCIAL_ACCOUNT|' || FINANCIAL_ACCOUNT_BK end"
  OPENING_BALANCE: 'ACCOUNT_BALANCE__OPENING_BALANCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
