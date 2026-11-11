-- automate_dv.stage() for SAT_AUG_CLAIM_QUALITY_AUDIT, read off central view stitch_v05_claim.
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
      - 'QUALITY_REVIEW_REQUIRED_INDICATOR'
derived_columns:
  CLAIM_NK: "case when AUG_CLAIM_QUALITY_AUDIT__QUALITY_REVIEW_REQUIRED_INDICATOR is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  QUALITY_REVIEW_REQUIRED_INDICATOR: 'AUG_CLAIM_QUALITY_AUDIT__QUALITY_REVIEW_REQUIRED_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
