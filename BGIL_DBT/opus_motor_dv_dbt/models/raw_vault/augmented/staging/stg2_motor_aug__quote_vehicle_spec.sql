-- automate_dv.stage() for SAT_AUG_QUOTE_VEHICLE_SPEC, read off central view stitch_motor__v22_quote.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v22_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CNG_LPG_KIT_VALUE'
      - 'FIBRE_GLASS_FITMENT_VALUE'
      - 'SIDE_CAR_IDV'
      - 'TRAILER_COUNT'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_VEHICLE_SPEC__CNG_LPG_KIT_VALUE, AUG_QUOTE_VEHICLE_SPEC__FIBRE_GLASS_FITMENT_VALUE, AUG_QUOTE_VEHICLE_SPEC__SIDE_CAR_IDV, AUG_QUOTE_VEHICLE_SPEC__TRAILER_COUNT) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  CNG_LPG_KIT_VALUE: 'AUG_QUOTE_VEHICLE_SPEC__CNG_LPG_KIT_VALUE'
  FIBRE_GLASS_FITMENT_VALUE: 'AUG_QUOTE_VEHICLE_SPEC__FIBRE_GLASS_FITMENT_VALUE'
  SIDE_CAR_IDV: 'AUG_QUOTE_VEHICLE_SPEC__SIDE_CAR_IDV'
  TRAILER_COUNT: 'AUG_QUOTE_VEHICLE_SPEC__TRAILER_COUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v22_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
