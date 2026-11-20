-- automate_dv.stage() for SAT_MOTOR_AUG_PRODUCT_RATING_STRUCTURE, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MINIMUM_DEPOSIT_PREMIUM_TYPE'
derived_columns:
  PRODUCT_NK: "case when AUG_PRODUCT_RATING_STRUCTURE__MINIMUM_DEPOSIT_PREMIUM_TYPE is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  MINIMUM_DEPOSIT_PREMIUM_TYPE: 'AUG_PRODUCT_RATING_STRUCTURE__MINIMUM_DEPOSIT_PREMIUM_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
