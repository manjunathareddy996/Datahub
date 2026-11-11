-- automate_dv.stage() for SAT_POLICY_TERMS, read off central view stitch_v30_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v30_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_PAYMENT_PERCENTAGE'
      - 'DEDUCTIBLE_TOTAL'
      - 'SPECIAL_CONDITIONS'
      - 'WARRANTY_CONDITIONS'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TERMS__CO_PAYMENT_PERCENTAGE, POLICY_TERMS__DEDUCTIBLE_TOTAL, POLICY_TERMS__SPECIAL_CONDITIONS, POLICY_TERMS__WARRANTY_CONDITIONS) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CO_PAYMENT_PERCENTAGE: 'POLICY_TERMS__CO_PAYMENT_PERCENTAGE'
  DEDUCTIBLE_TOTAL: 'POLICY_TERMS__DEDUCTIBLE_TOTAL'
  SPECIAL_CONDITIONS: 'POLICY_TERMS__SPECIAL_CONDITIONS'
  WARRANTY_CONDITIONS: 'POLICY_TERMS__WARRANTY_CONDITIONS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v30_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
