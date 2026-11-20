-- automate_dv.stage() for SAT_CHANNEL_DEFINITION, read off central view stitch_mxm__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v10_party'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHANNEL_TYPE'
      - 'SUB_CHANNEL_CODE'
      - 'SUB_CHANNEL_EFFECTIVE_DATE'
derived_columns:
  DISTRIBUTION_CHANNEL_NK: "case when coalesce(CHANNEL_DEFINITION__CHANNEL_TYPE, CHANNEL_DEFINITION__SUB_CHANNEL_CODE, CHANNEL_DEFINITION__SUB_CHANNEL_EFFECTIVE_DATE) is not null then 'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK end"
  CHANNEL_TYPE: 'CHANNEL_DEFINITION__CHANNEL_TYPE'
  SUB_CHANNEL_CODE: 'CHANNEL_DEFINITION__SUB_CHANNEL_CODE'
  SUB_CHANNEL_EFFECTIVE_DATE: 'CHANNEL_DEFINITION__SUB_CHANNEL_EFFECTIVE_DATE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v10_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
