-- automate_dv.stage() for SAT_POLICY_CERTIFICATE, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CERTIFICATE_NUMBER'
      - 'CERTIFICATE_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when POLICY_CERTIFICATE__CERTIFICATE_NUMBER is not null then 'HUB_POLICY|' || POLICY_BK end"
  CERTIFICATE_NUMBER_CK: 'POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK'
  CERTIFICATE_NUMBER: 'POLICY_CERTIFICATE__CERTIFICATE_NUMBER'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
