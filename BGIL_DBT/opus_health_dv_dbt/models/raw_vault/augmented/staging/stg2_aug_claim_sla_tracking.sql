-- automate_dv.stage() for SAT_AUG_CLAIM_SLA_TRACKING, read off central view stitch_v05_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v05_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LAST_ACTION_BY_USER_REFERENCE'
derived_columns:
  CLAIM_NK: "case when AUG_CLAIM_SLA_TRACKING__LAST_ACTION_BY_USER_REFERENCE is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  LAST_ACTION_BY_USER_REFERENCE: 'AUG_CLAIM_SLA_TRACKING__LAST_ACTION_BY_USER_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
