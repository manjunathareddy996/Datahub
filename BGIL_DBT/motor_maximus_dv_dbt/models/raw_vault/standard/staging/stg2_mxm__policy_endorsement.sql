-- automate_dv.stage() for SAT_POLICY_ENDORSEMENT, read off central view stitch_mxm__v13_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v13_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EFFECTIVE_DATE'
      - 'ENDORSEMENT_NUMBER'
      - 'ENDORSEMENT_REASON'
      - 'ENDORSEMENT_TYPE'
      - 'PREMIUM_IMPACT_AMOUNT'
      - 'SUM_INSURED_IMPACT_AMOUNT'
      - 'ENDORSEMENT_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_ENDORSEMENT__EFFECTIVE_DATE, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER, POLICY_ENDORSEMENT__ENDORSEMENT_REASON, POLICY_ENDORSEMENT__ENDORSEMENT_TYPE, POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT, POLICY_ENDORSEMENT__SUM_INSURED_IMPACT_AMOUNT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ENDORSEMENT_NUMBER_CK: 'POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK'
  EFFECTIVE_DATE: 'POLICY_ENDORSEMENT__EFFECTIVE_DATE'
  ENDORSEMENT_NUMBER: 'POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER'
  ENDORSEMENT_REASON: 'POLICY_ENDORSEMENT__ENDORSEMENT_REASON'
  ENDORSEMENT_TYPE: 'POLICY_ENDORSEMENT__ENDORSEMENT_TYPE'
  PREMIUM_IMPACT_AMOUNT: 'POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT'
  SUM_INSURED_IMPACT_AMOUNT: 'POLICY_ENDORSEMENT__SUM_INSURED_IMPACT_AMOUNT'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v13_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
