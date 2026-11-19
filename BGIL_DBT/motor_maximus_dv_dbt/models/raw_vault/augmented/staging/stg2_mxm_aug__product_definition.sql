-- automate_dv.stage() for SAT_MOTOR_AUG_PRODUCT_DEFINITION, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PARTNER_PRODUCT_NAME'
      - 'PRODUCT_DETAIL_TEXT'
derived_columns:
  PRODUCT_NK: "case when coalesce(AUG_PRODUCT_DEFINITION__PARTNER_PRODUCT_NAME, AUG_PRODUCT_DEFINITION__PRODUCT_DETAIL_TEXT) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  PARTNER_PRODUCT_NAME: 'AUG_PRODUCT_DEFINITION__PARTNER_PRODUCT_NAME'
  PRODUCT_DETAIL_TEXT: 'AUG_PRODUCT_DEFINITION__PRODUCT_DETAIL_TEXT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
