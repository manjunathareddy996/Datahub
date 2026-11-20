-- automate_dv.stage() for SAT_CLAIM_REPUDIATION, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REPUDIATION_CATEGORY'
      - 'REPUDIATION_REASON'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_REPUDIATION__REPUDIATION_CATEGORY, CLAIM_REPUDIATION__REPUDIATION_REASON) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  REPUDIATION_CATEGORY: 'CLAIM_REPUDIATION__REPUDIATION_CATEGORY'
  REPUDIATION_REASON: 'CLAIM_REPUDIATION__REPUDIATION_REASON'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
