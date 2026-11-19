-- automate_dv.stage() for SAT_CHANNEL_FIELD_ACTIVITY, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACTIVITY_REFERENCE'
      - 'FOLLOW_UP_DATE'
      - 'LEAD_REFERENCE'
      - 'MEETING_PURPOSE'
      - 'OUTCOME_STATUS'
      - 'ACTIVITY_REFERENCE_CK'
derived_columns:
  DISTRIBUTION_CHANNEL_NK: "case when coalesce(CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE, CHANNEL_FIELD_ACTIVITY__FOLLOW_UP_DATE, CHANNEL_FIELD_ACTIVITY__LEAD_REFERENCE, CHANNEL_FIELD_ACTIVITY__MEETING_PURPOSE, CHANNEL_FIELD_ACTIVITY__OUTCOME_STATUS) is not null then 'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK end"
  ACTIVITY_REFERENCE_CK: 'CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK'
  ACTIVITY_REFERENCE: 'CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE'
  FOLLOW_UP_DATE: 'CHANNEL_FIELD_ACTIVITY__FOLLOW_UP_DATE'
  LEAD_REFERENCE: 'CHANNEL_FIELD_ACTIVITY__LEAD_REFERENCE'
  MEETING_PURPOSE: 'CHANNEL_FIELD_ACTIVITY__MEETING_PURPOSE'
  OUTCOME_STATUS: 'CHANNEL_FIELD_ACTIVITY__OUTCOME_STATUS'
  LOAD_DATETIME: 'DISTRIBUTION_CHANNEL_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_MOTOR_V06_DISTRIBUTION_CHANNEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
