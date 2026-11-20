-- automate_dv.stage() for SAT_CLAIM_BENEFIT_HEAD, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_REFERENCE'
      - 'HEAD_DESCRIPTION'
      - 'BENEFIT_HEAD_CODE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_BENEFIT_HEAD__COVERAGE_REFERENCE, CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  BENEFIT_HEAD_CODE_CK: 'CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK'
  COVERAGE_REFERENCE: 'CLAIM_BENEFIT_HEAD__COVERAGE_REFERENCE'
  HEAD_DESCRIPTION: 'CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v04_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
