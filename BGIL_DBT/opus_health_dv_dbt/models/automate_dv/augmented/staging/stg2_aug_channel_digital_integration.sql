-- automate_dv.stage() for SAT_AUG_CHANNEL_DIGITAL_INTEGRATION, read off central view stitch_v34_risk_object.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v34_risk_object'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SUBMITTING_USER_LOGIN_IDENTIFIER'
derived_columns:
  DISTRIBUTION_CHANNEL_NK: "case when AUG_CHANNEL_DIGITAL_INTEGRATION__SUBMITTING_USER_LOGIN_IDENTIFIER is not null then 'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK end"
  SUBMITTING_USER_LOGIN_IDENTIFIER: 'AUG_CHANNEL_DIGITAL_INTEGRATION__SUBMITTING_USER_LOGIN_IDENTIFIER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v34_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
