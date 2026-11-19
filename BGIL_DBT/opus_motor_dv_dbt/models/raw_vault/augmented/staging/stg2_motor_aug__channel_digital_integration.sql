-- automate_dv.stage() for SAT_MOTOR_AUG_CHANNEL_DIGITAL_INTEGRATION, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PARTNER_REQUEST_REFERENCE'
derived_columns:
  DISTRIBUTION_CHANNEL_NK: "case when AUG_CHANNEL_DIGITAL_INTEGRATION__PARTNER_REQUEST_REFERENCE is not null then 'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK end"
  PARTNER_REQUEST_REFERENCE: 'AUG_CHANNEL_DIGITAL_INTEGRATION__PARTNER_REQUEST_REFERENCE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
