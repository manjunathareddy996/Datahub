-- automate_dv.stage() for SAT_AUG_ACCOUNT_BALANCE, read off central view stitch_v13_financial_account.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v13_financial_account'
hashed_columns:
  FINANCIAL_ACCOUNT_HKEY: 'FINANCIAL_ACCOUNT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSIGNMENT_AMOUNT'
      - 'EMI_AMOUNT'
derived_columns:
  FINANCIAL_ACCOUNT_NK: "case when coalesce(AUG_ACCOUNT_BALANCE__ASSIGNMENT_AMOUNT, AUG_ACCOUNT_BALANCE__EMI_AMOUNT) is not null then 'HUB_FINANCIAL_ACCOUNT|' || FINANCIAL_ACCOUNT_BK end"
  ASSIGNMENT_AMOUNT: 'AUG_ACCOUNT_BALANCE__ASSIGNMENT_AMOUNT'
  EMI_AMOUNT: 'AUG_ACCOUNT_BALANCE__EMI_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v13_financial_account'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
