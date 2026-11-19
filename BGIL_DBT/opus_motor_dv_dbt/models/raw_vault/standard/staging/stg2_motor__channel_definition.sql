-- automate_dv.stage() for SAT_CHANNEL_DEFINITION, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHANNEL_CATEGORY'
      - 'CHANNEL_NAME'
      - 'CHANNEL_TYPE'
      - 'SUB_CHANNEL_CODE'
derived_columns:
  DISTRIBUTION_CHANNEL_NK: "case when coalesce(CHANNEL_DEFINITION__CHANNEL_CATEGORY, CHANNEL_DEFINITION__CHANNEL_NAME, CHANNEL_DEFINITION__CHANNEL_TYPE, CHANNEL_DEFINITION__SUB_CHANNEL_CODE) is not null then 'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK end"
  CHANNEL_CATEGORY: 'CHANNEL_DEFINITION__CHANNEL_CATEGORY'
  CHANNEL_NAME: 'CHANNEL_DEFINITION__CHANNEL_NAME'
  CHANNEL_TYPE: 'CHANNEL_DEFINITION__CHANNEL_TYPE'
  SUB_CHANNEL_CODE: 'CHANNEL_DEFINITION__SUB_CHANNEL_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v06_distribution_channel'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
