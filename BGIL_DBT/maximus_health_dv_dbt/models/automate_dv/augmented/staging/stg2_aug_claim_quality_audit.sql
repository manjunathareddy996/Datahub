-- automate_dv.stage() for SAT_AUG_CLAIM_QUALITY_AUDIT, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'QUALITY_CHECK_REMARKS'
      - 'SPECIAL_AUTHORITY_OBSERVATION'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_QUALITY_AUDIT__QUALITY_CHECK_REMARKS, AUG_CLAIM_QUALITY_AUDIT__SPECIAL_AUTHORITY_OBSERVATION) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  QUALITY_CHECK_REMARKS: 'AUG_CLAIM_QUALITY_AUDIT__QUALITY_CHECK_REMARKS'
  SPECIAL_AUTHORITY_OBSERVATION: 'AUG_CLAIM_QUALITY_AUDIT__SPECIAL_AUTHORITY_OBSERVATION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
