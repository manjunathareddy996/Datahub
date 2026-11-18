-- automate_dv.stage() for SAT_AUG_LOSS_EVENT_DETAIL, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  LOSS_EVENT_HKEY: 'LOSS_EVENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CAUSE_TYPE_CODE'
derived_columns:
  LOSS_EVENT_NK: "case when AUG_LOSS_EVENT_DETAIL__CAUSE_TYPE_CODE is not null then 'HUB_LOSS_EVENT|' || LOSS_EVENT_BK end"
  CAUSE_TYPE_CODE: 'AUG_LOSS_EVENT_DETAIL__CAUSE_TYPE_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
