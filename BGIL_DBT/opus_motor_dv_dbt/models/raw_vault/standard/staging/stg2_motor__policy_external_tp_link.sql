-- automate_dv.stage() for SAT_POLICY_EXTERNAL_TP_LINK, read off central view stitch_motor__v25_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v25_risk_object'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'STANDALONE_TP_INDICATOR'
      - 'TP_FINANCE_TYPE'
      - 'TP_POLICY_END_DATE'
      - 'TP_POLICY_START_DATE'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_EXTERNAL_TP_LINK__STANDALONE_TP_INDICATOR, POLICY_EXTERNAL_TP_LINK__TP_FINANCE_TYPE, POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE, POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  STANDALONE_TP_INDICATOR: 'POLICY_EXTERNAL_TP_LINK__STANDALONE_TP_INDICATOR'
  TP_FINANCE_TYPE: 'POLICY_EXTERNAL_TP_LINK__TP_FINANCE_TYPE'
  TP_POLICY_END_DATE: 'POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE'
  TP_POLICY_START_DATE: 'POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v25_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
