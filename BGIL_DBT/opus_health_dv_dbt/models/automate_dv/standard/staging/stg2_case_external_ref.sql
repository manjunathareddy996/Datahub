-- automate_dv.stage() for SAT_CASE_EXTERNAL_REF, read off central view stitch_v04_case.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_case'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXTERNAL_REFERENCE'
      - 'REFERENCE_TYPE_CK'
derived_columns:
  CASE_NK: "case when CASE_EXTERNAL_REF__EXTERNAL_REFERENCE is not null then 'HUB_CASE|' || CASE_BK end"
  REFERENCE_TYPE_CK: 'CASE_EXTERNAL_REF__REFERENCE_TYPE_CK'
  EXTERNAL_REFERENCE: 'CASE_EXTERNAL_REF__EXTERNAL_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_case'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
