-- automate_dv.stage() for SAT_CLAIM_SLA_TRACKING, read off central view stitch_v34_risk_object.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v34_risk_object'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LAST_ACTION_DATE'
derived_columns:
  CLAIM_NK: "case when CLAIM_SLA_TRACKING__LAST_ACTION_DATE is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  LAST_ACTION_DATE: 'CLAIM_SLA_TRACKING__LAST_ACTION_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v34_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
