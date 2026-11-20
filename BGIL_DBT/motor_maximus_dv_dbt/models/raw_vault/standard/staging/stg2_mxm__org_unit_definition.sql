-- automate_dv.stage() for SAT_ORG_UNIT_DEFINITION, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ORG_UNIT_NAME'
derived_columns:
  ORG_UNIT_NK: "case when ORG_UNIT_DEFINITION__ORG_UNIT_NAME is not null then 'HUB_ORG_UNIT|' || ORG_UNIT_BK end"
  ORG_UNIT_NAME: 'ORG_UNIT_DEFINITION__ORG_UNIT_NAME'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v12_policy'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
