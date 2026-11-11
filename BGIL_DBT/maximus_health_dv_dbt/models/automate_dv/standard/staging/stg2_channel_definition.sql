-- automate_dv.stage() for SAT_CHANNEL_DEFINITION, read off central view stitch_v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_party'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHANNEL_NAME'
      - 'CHANNEL_REMARKS'
      - 'CHANNEL_TYPE'
      - 'SUB_CHANNEL_CODE'
derived_columns:
  DISTRIBUTION_CHANNEL_NK: "case when coalesce(CHANNEL_DEFINITION__CHANNEL_NAME, CHANNEL_DEFINITION__CHANNEL_REMARKS, CHANNEL_DEFINITION__CHANNEL_TYPE, CHANNEL_DEFINITION__SUB_CHANNEL_CODE) is not null then 'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK end"
  CHANNEL_NAME: 'CHANNEL_DEFINITION__CHANNEL_NAME'
  CHANNEL_REMARKS: 'CHANNEL_DEFINITION__CHANNEL_REMARKS'
  CHANNEL_TYPE: 'CHANNEL_DEFINITION__CHANNEL_TYPE'
  SUB_CHANNEL_CODE: 'CHANNEL_DEFINITION__SUB_CHANNEL_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
