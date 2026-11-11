-- automate_dv.stage() for SAT_POLICY_PREMIUM_SUMMARY, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INSTALMENT_INDICATOR'
      - 'LOYALTY_DISCOUNT_AMOUNT'
      - 'NET_PREMIUM'
      - 'PREMIUM_OUTSTANDING'
      - 'TOTAL_PREMIUM_COLLECTED'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_PREMIUM_SUMMARY__INSTALMENT_INDICATOR, POLICY_PREMIUM_SUMMARY__LOYALTY_DISCOUNT_AMOUNT, POLICY_PREMIUM_SUMMARY__NET_PREMIUM, POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING, POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED) is not null then 'HUB_POLICY|' || POLICY_BK end"
  INSTALMENT_INDICATOR: 'POLICY_PREMIUM_SUMMARY__INSTALMENT_INDICATOR'
  LOYALTY_DISCOUNT_AMOUNT: 'POLICY_PREMIUM_SUMMARY__LOYALTY_DISCOUNT_AMOUNT'
  NET_PREMIUM: 'POLICY_PREMIUM_SUMMARY__NET_PREMIUM'
  PREMIUM_OUTSTANDING: 'POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING'
  TOTAL_PREMIUM_COLLECTED: 'POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
