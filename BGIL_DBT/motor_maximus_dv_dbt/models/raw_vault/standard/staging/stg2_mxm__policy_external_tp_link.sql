-- automate_dv.stage() for SAT_POLICY_EXTERNAL_TP_LINK, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXTERNAL_TP_POLICY_INDICATOR'
      - 'TP_INSURER_NAME'
      - 'TP_POLICY_END_DATE'
      - 'TP_POLICY_NUMBER'
      - 'TP_POLICY_START_DATE'
      - 'TP_TENURE_YEARS'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_EXTERNAL_TP_LINK__EXTERNAL_TP_POLICY_INDICATOR, POLICY_EXTERNAL_TP_LINK__TP_INSURER_NAME, POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE, POLICY_EXTERNAL_TP_LINK__TP_POLICY_NUMBER, POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE, POLICY_EXTERNAL_TP_LINK__TP_TENURE_YEARS) is not null then 'HUB_POLICY|' || POLICY_BK end"
  EXTERNAL_TP_POLICY_INDICATOR: 'POLICY_EXTERNAL_TP_LINK__EXTERNAL_TP_POLICY_INDICATOR'
  TP_INSURER_NAME: 'POLICY_EXTERNAL_TP_LINK__TP_INSURER_NAME'
  TP_POLICY_END_DATE: 'POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE'
  TP_POLICY_NUMBER: 'POLICY_EXTERNAL_TP_LINK__TP_POLICY_NUMBER'
  TP_POLICY_START_DATE: 'POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE'
  TP_TENURE_YEARS: 'POLICY_EXTERNAL_TP_LINK__TP_TENURE_YEARS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
