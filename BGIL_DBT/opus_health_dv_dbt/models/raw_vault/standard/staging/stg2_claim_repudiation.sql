-- automate_dv.stage() for SAT_CLAIM_REPUDIATION, read off central view stitch_v07_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v07_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REPUDIATION_DATE'
      - 'REPUDIATION_REASON'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_REPUDIATION__REPUDIATION_DATE, CLAIM_REPUDIATION__REPUDIATION_REASON) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  REPUDIATION_DATE: 'CLAIM_REPUDIATION__REPUDIATION_DATE'
  REPUDIATION_REASON: 'CLAIM_REPUDIATION__REPUDIATION_REASON'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v07_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
