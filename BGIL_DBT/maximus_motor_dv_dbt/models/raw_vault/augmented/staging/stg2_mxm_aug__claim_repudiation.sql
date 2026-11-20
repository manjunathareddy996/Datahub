-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_REPUDIATION, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXCLUSION_CODE'
      - 'EXCLUSION_DETAIL'
      - 'REPUDIATION_REMARKS'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_REPUDIATION__EXCLUSION_CODE, AUG_CLAIM_REPUDIATION__EXCLUSION_DETAIL, AUG_CLAIM_REPUDIATION__REPUDIATION_REMARKS) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  EXCLUSION_CODE: 'AUG_CLAIM_REPUDIATION__EXCLUSION_CODE'
  EXCLUSION_DETAIL: 'AUG_CLAIM_REPUDIATION__EXCLUSION_DETAIL'
  REPUDIATION_REMARKS: 'AUG_CLAIM_REPUDIATION__REPUDIATION_REMARKS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
