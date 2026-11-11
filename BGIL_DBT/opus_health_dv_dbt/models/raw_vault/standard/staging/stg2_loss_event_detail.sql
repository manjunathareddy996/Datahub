-- automate_dv.stage() for SAT_LOSS_EVENT_DETAIL, read off central view stitch_v11_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_claim'
hashed_columns:
  LOSS_EVENT_HKEY: 'LOSS_EVENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOSS_DATE'
      - 'LOSS_EVENT_TYPE'
derived_columns:
  LOSS_EVENT_NK: "case when coalesce(LOSS_EVENT_DETAIL__LOSS_DATE, LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE) is not null then 'HUB_LOSS_EVENT|' || LOSS_EVENT_BK end"
  LOSS_DATE: 'LOSS_EVENT_DETAIL__LOSS_DATE'
  LOSS_EVENT_TYPE: 'LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
