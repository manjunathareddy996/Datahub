-- automate_dv.stage() for SAT_MOTOR_AUG_QUOTE_PRIOR_INSURANCE, read off central view stitch_motor__v23_quote.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v23_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRIOR_INSURER_NAME'
      - 'PRIOR_POLICY_CLAIM_COUNT'
      - 'PRIOR_POLICY_END_DATE'
      - 'PRIOR_POLICY_NUMBER'
      - 'PRIOR_POLICY_START_DATE'
      - 'PRIOR_TENURE_YEARS'
      - 'PRIOR_POLICY_COMPONENT_CK'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_PRIOR_INSURANCE__PRIOR_INSURER_NAME, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_CLAIM_COUNT, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_END_DATE, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_NUMBER, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_START_DATE, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_TENURE_YEARS) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  PRIOR_POLICY_COMPONENT_CK: 'AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK'
  PRIOR_INSURER_NAME: 'AUG_QUOTE_PRIOR_INSURANCE__PRIOR_INSURER_NAME'
  PRIOR_POLICY_CLAIM_COUNT: 'AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_CLAIM_COUNT'
  PRIOR_POLICY_END_DATE: 'AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_END_DATE'
  PRIOR_POLICY_NUMBER: 'AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_NUMBER'
  PRIOR_POLICY_START_DATE: 'AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_START_DATE'
  PRIOR_TENURE_YEARS: 'AUG_QUOTE_PRIOR_INSURANCE__PRIOR_TENURE_YEARS'
  LOAD_DATETIME: 'QUOTE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v23_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
