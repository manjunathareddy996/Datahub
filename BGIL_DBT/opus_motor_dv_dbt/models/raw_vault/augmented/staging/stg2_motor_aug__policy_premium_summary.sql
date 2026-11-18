-- automate_dv.stage() for SAT_AUG_POLICY_PREMIUM_SUMMARY, read off central view stitch_motor__v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v16_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BOOKED_PREMIUM_AMOUNT'
      - 'DEVIATED_GROSS_PREMIUM'
      - 'FULL_TERM_PREMIUM'
      - 'MINIMUM_GROSS_PREMIUM'
      - 'PREMIUM_BREAKUP_TEXT'
      - 'PREMIUM_CALCULATED_BY'
      - 'PREMIUM_PAYMENT_MODE'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_PREMIUM_SUMMARY__BOOKED_PREMIUM_AMOUNT, AUG_POLICY_PREMIUM_SUMMARY__DEVIATED_GROSS_PREMIUM, AUG_POLICY_PREMIUM_SUMMARY__FULL_TERM_PREMIUM, AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM, AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BREAKUP_TEXT, AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATED_BY, AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  BOOKED_PREMIUM_AMOUNT: 'AUG_POLICY_PREMIUM_SUMMARY__BOOKED_PREMIUM_AMOUNT'
  DEVIATED_GROSS_PREMIUM: 'AUG_POLICY_PREMIUM_SUMMARY__DEVIATED_GROSS_PREMIUM'
  FULL_TERM_PREMIUM: 'AUG_POLICY_PREMIUM_SUMMARY__FULL_TERM_PREMIUM'
  MINIMUM_GROSS_PREMIUM: 'AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM'
  PREMIUM_BREAKUP_TEXT: 'AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BREAKUP_TEXT'
  PREMIUM_CALCULATED_BY: 'AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATED_BY'
  PREMIUM_PAYMENT_MODE: 'AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
