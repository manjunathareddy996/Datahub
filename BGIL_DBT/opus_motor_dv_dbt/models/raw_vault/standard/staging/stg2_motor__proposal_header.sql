-- automate_dv.stage() for SAT_PROPOSAL_HEADER, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PROPOSAL_CREATION_TIME'
      - 'PROPOSAL_DATE'
      - 'PROPOSAL_STATUS'
      - 'RECEIPT_DATE'
      - 'SUBMISSION_CHANNEL'
derived_columns:
  PROPOSAL_NK: "case when coalesce(PROPOSAL_HEADER__PROPOSAL_CREATION_TIME, PROPOSAL_HEADER__PROPOSAL_DATE, PROPOSAL_HEADER__PROPOSAL_STATUS, PROPOSAL_HEADER__RECEIPT_DATE, PROPOSAL_HEADER__SUBMISSION_CHANNEL) is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  PROPOSAL_CREATION_TIME: 'PROPOSAL_HEADER__PROPOSAL_CREATION_TIME'
  PROPOSAL_DATE: 'PROPOSAL_HEADER__PROPOSAL_DATE'
  PROPOSAL_STATUS: 'PROPOSAL_HEADER__PROPOSAL_STATUS'
  RECEIPT_DATE: 'PROPOSAL_HEADER__RECEIPT_DATE'
  SUBMISSION_CHANNEL: 'PROPOSAL_HEADER__SUBMISSION_CHANNEL'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V06_DISTRIBUTION_CHANNEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
