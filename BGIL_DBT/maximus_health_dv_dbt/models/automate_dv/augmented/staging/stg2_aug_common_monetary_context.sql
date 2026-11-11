-- automate_dv.stage() for SAT_AUG_COMMON_MONETARY_CONTEXT, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SUM_INSURED_TRANSACTION_CURRENCY_CODE'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when AUG_COMMON_MONETARY_CONTEXT__SUM_INSURED_TRANSACTION_CURRENCY_CODE is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  SUM_INSURED_TRANSACTION_CURRENCY_CODE: 'AUG_COMMON_MONETARY_CONTEXT__SUM_INSURED_TRANSACTION_CURRENCY_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
