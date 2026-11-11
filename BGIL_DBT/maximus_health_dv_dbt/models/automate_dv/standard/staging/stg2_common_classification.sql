-- automate_dv.stage() for SAT_COMMON_CLASSIFICATION, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CATEGORY_CODE'
      - 'SEGMENT_CODE'
      - 'SEGMENT_NAME'
      - 'TIER_CODE'
      - 'VALUE_BAND'
derived_columns:
  PARTY_NK: "case when coalesce(COMMON_CLASSIFICATION__CATEGORY_CODE, COMMON_CLASSIFICATION__SEGMENT_CODE, COMMON_CLASSIFICATION__SEGMENT_NAME, COMMON_CLASSIFICATION__TIER_CODE, COMMON_CLASSIFICATION__VALUE_BAND) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CATEGORY_CODE: 'COMMON_CLASSIFICATION__CATEGORY_CODE'
  SEGMENT_CODE: 'COMMON_CLASSIFICATION__SEGMENT_CODE'
  SEGMENT_NAME: 'COMMON_CLASSIFICATION__SEGMENT_NAME'
  TIER_CODE: 'COMMON_CLASSIFICATION__TIER_CODE'
  VALUE_BAND: 'COMMON_CLASSIFICATION__VALUE_BAND'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
