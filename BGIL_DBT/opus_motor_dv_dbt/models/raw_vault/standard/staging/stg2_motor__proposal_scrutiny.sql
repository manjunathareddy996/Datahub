-- automate_dv.stage() for SAT_PROPOSAL_SCRUTINY, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'QUALITY_CHECK_STATUS'
      - 'SCRUTINY_REFERENCE'
derived_columns:
  PROPOSAL_NK: "case when coalesce(PROPOSAL_SCRUTINY__QUALITY_CHECK_STATUS, PROPOSAL_SCRUTINY__SCRUTINY_REFERENCE) is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  QUALITY_CHECK_STATUS: 'PROPOSAL_SCRUTINY__QUALITY_CHECK_STATUS'
  SCRUTINY_REFERENCE: 'PROPOSAL_SCRUTINY__SCRUTINY_REFERENCE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v06_distribution_channel'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
