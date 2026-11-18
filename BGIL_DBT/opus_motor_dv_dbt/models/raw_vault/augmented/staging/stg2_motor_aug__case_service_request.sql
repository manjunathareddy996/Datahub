-- automate_dv.stage() for SAT_AUG_CASE_SERVICE_REQUEST, read off central view stitch_motor__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v09_party'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSISTANCE_OFFER_PUSHED_INDICATOR'
derived_columns:
  CASE_NK: "case when AUG_CASE_SERVICE_REQUEST__ASSISTANCE_OFFER_PUSHED_INDICATOR is not null then 'HUB_CASE|' || CASE_BK end"
  ASSISTANCE_OFFER_PUSHED_INDICATOR: 'AUG_CASE_SERVICE_REQUEST__ASSISTANCE_OFFER_PUSHED_INDICATOR'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
