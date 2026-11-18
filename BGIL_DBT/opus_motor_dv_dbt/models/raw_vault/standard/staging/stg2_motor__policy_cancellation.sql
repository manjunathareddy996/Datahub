-- automate_dv.stage() for SAT_POLICY_CANCELLATION, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CANCELLATION_REASON'
      - 'CANCELLATION_STATUS'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_CANCELLATION__CANCELLATION_REASON, POLICY_CANCELLATION__CANCELLATION_STATUS) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CANCELLATION_REASON: 'POLICY_CANCELLATION__CANCELLATION_REASON'
  CANCELLATION_STATUS: 'POLICY_CANCELLATION__CANCELLATION_STATUS'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v06_distribution_channel'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
