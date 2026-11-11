-- automate_dv.stage() for SAT_AUG_CLAIM_ASSESSMENT_SUMMARY, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AUTO_ADJUDICATION_ENGINE_INDICATOR'
derived_columns:
  CLAIM_NK: "case when AUG_CLAIM_ASSESSMENT_SUMMARY__AUTO_ADJUDICATION_ENGINE_INDICATOR is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  AUTO_ADJUDICATION_ENGINE_INDICATOR: 'AUG_CLAIM_ASSESSMENT_SUMMARY__AUTO_ADJUDICATION_ENGINE_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
