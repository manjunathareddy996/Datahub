-- automate_dv.stage() for SAT_POLICY_TP_PRIOR_PERIOD, read off central view stitch_motor__v18_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v18_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRIOR_INSURER_CODE'
      - 'PRIOR_INSURER_NAME'
      - 'PRIOR_POLICY_END_DATE'
      - 'PRIOR_POLICY_NUMBER'
      - 'PRIOR_POLICY_START_DATE'
      - 'PRIOR_POLICY_SEQUENCE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_CODE, POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_NAME, POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_END_DATE, POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_NUMBER, POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_START_DATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  PRIOR_POLICY_SEQUENCE_CK: 'POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_SEQUENCE_CK'
  PRIOR_INSURER_CODE: 'POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_CODE'
  PRIOR_INSURER_NAME: 'POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_NAME'
  PRIOR_POLICY_END_DATE: 'POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_END_DATE'
  PRIOR_POLICY_NUMBER: 'POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_NUMBER'
  PRIOR_POLICY_START_DATE: 'POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_START_DATE'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v18_policy'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
