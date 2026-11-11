-- automate_dv.stage() for SAT_POLICY_TERMS, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_PAYMENT_PERCENTAGE'
      - 'DEDUCTIBLE_TOTAL'
      - 'GEOGRAPHICAL_SCOPE'
      - 'REINSTATEMENT_OF_SUM_INSURED_INDICATOR'
      - 'SPECIAL_CONDITIONS'
      - 'WAITING_PERIOD'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TERMS__CO_PAYMENT_PERCENTAGE, POLICY_TERMS__DEDUCTIBLE_TOTAL, POLICY_TERMS__GEOGRAPHICAL_SCOPE, POLICY_TERMS__REINSTATEMENT_OF_SUM_INSURED_INDICATOR, POLICY_TERMS__SPECIAL_CONDITIONS, POLICY_TERMS__WAITING_PERIOD) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CO_PAYMENT_PERCENTAGE: 'POLICY_TERMS__CO_PAYMENT_PERCENTAGE'
  DEDUCTIBLE_TOTAL: 'POLICY_TERMS__DEDUCTIBLE_TOTAL'
  GEOGRAPHICAL_SCOPE: 'POLICY_TERMS__GEOGRAPHICAL_SCOPE'
  REINSTATEMENT_OF_SUM_INSURED_INDICATOR: 'POLICY_TERMS__REINSTATEMENT_OF_SUM_INSURED_INDICATOR'
  SPECIAL_CONDITIONS: 'POLICY_TERMS__SPECIAL_CONDITIONS'
  WAITING_PERIOD: 'POLICY_TERMS__WAITING_PERIOD'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
