-- automate_dv.stage() for SAT_MOTOR_AUG_ASSESSMENT_HEADER, read off central view stitch_motor__v01_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v01_claim'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSESSMENT_VERSION_NUMBER'
      - 'INSPECTION_TRANSACTION_REFERENCE'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(AUG_ASSESSMENT_HEADER__ASSESSMENT_VERSION_NUMBER, AUG_ASSESSMENT_HEADER__INSPECTION_TRANSACTION_REFERENCE) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  ASSESSMENT_VERSION_NUMBER: 'AUG_ASSESSMENT_HEADER__ASSESSMENT_VERSION_NUMBER'
  INSPECTION_TRANSACTION_REFERENCE: 'AUG_ASSESSMENT_HEADER__INSPECTION_TRANSACTION_REFERENCE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v01_claim'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
