-- automate_dv.stage() for SAT_POLICY_ENDORSEMENT, read off central view stitch_v23_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v23_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EFFECTIVE_DATE'
      - 'ENDORSEMENT_DATE'
      - 'ENDORSEMENT_NUMBER'
      - 'ENDORSEMENT_REASON'
      - 'ENDORSEMENT_SUB_TYPE'
      - 'ENDORSEMENT_TYPE'
      - 'PREMIUM_IMPACT_AMOUNT'
      - 'STAMP_DUTY_ON_ENDORSEMENT'
      - 'ENDORSEMENT_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_ENDORSEMENT__EFFECTIVE_DATE, POLICY_ENDORSEMENT__ENDORSEMENT_DATE, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER, POLICY_ENDORSEMENT__ENDORSEMENT_REASON, POLICY_ENDORSEMENT__ENDORSEMENT_SUB_TYPE, POLICY_ENDORSEMENT__ENDORSEMENT_TYPE, POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT, POLICY_ENDORSEMENT__STAMP_DUTY_ON_ENDORSEMENT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ENDORSEMENT_NUMBER_CK: 'POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK'
  EFFECTIVE_DATE: 'POLICY_ENDORSEMENT__EFFECTIVE_DATE'
  ENDORSEMENT_DATE: 'POLICY_ENDORSEMENT__ENDORSEMENT_DATE'
  ENDORSEMENT_NUMBER: 'POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER'
  ENDORSEMENT_REASON: 'POLICY_ENDORSEMENT__ENDORSEMENT_REASON'
  ENDORSEMENT_SUB_TYPE: 'POLICY_ENDORSEMENT__ENDORSEMENT_SUB_TYPE'
  ENDORSEMENT_TYPE: 'POLICY_ENDORSEMENT__ENDORSEMENT_TYPE'
  PREMIUM_IMPACT_AMOUNT: 'POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT'
  STAMP_DUTY_ON_ENDORSEMENT: 'POLICY_ENDORSEMENT__STAMP_DUTY_ON_ENDORSEMENT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v23_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
