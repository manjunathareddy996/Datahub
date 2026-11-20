-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_BENEFIT_HEAD, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_NAME'
      - 'COVER_TAKEN_INDICATOR'
      - 'DAYS_AVAILED_COUNT'
      - 'HEAD_BASE_SUM_INSURED'
      - 'BENEFIT_HEAD_CODE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_BENEFIT_HEAD__COVERAGE_NAME, AUG_CLAIM_BENEFIT_HEAD__COVER_TAKEN_INDICATOR, AUG_CLAIM_BENEFIT_HEAD__DAYS_AVAILED_COUNT, AUG_CLAIM_BENEFIT_HEAD__HEAD_BASE_SUM_INSURED) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  BENEFIT_HEAD_CODE_CK: 'AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK'
  COVERAGE_NAME: 'AUG_CLAIM_BENEFIT_HEAD__COVERAGE_NAME'
  COVER_TAKEN_INDICATOR: 'AUG_CLAIM_BENEFIT_HEAD__COVER_TAKEN_INDICATOR'
  DAYS_AVAILED_COUNT: 'AUG_CLAIM_BENEFIT_HEAD__DAYS_AVAILED_COUNT'
  HEAD_BASE_SUM_INSURED: 'AUG_CLAIM_BENEFIT_HEAD__HEAD_BASE_SUM_INSURED'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
