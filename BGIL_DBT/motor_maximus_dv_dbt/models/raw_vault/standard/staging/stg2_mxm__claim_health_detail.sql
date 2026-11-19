-- automate_dv.stage() for SAT_CLAIM_HEALTH_DETAIL, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADMISSION_DATE'
      - 'AILMENT_DESCRIPTION'
      - 'DISCHARGE_DATE'
      - 'HEALTH_CLAIM_REMARKS'
      - 'ICD_CODE'
      - 'PRE_EXISTING_DISEASE_RELATED_INDICATOR'
      - 'TREATING_DOCTOR_NAME'
      - 'TREATMENT_TYPE'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_HEALTH_DETAIL__ADMISSION_DATE, CLAIM_HEALTH_DETAIL__AILMENT_DESCRIPTION, CLAIM_HEALTH_DETAIL__DISCHARGE_DATE, CLAIM_HEALTH_DETAIL__HEALTH_CLAIM_REMARKS, CLAIM_HEALTH_DETAIL__ICD_CODE, CLAIM_HEALTH_DETAIL__PRE_EXISTING_DISEASE_RELATED_INDICATOR, CLAIM_HEALTH_DETAIL__TREATING_DOCTOR_NAME, CLAIM_HEALTH_DETAIL__TREATMENT_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ADMISSION_DATE: 'CLAIM_HEALTH_DETAIL__ADMISSION_DATE'
  AILMENT_DESCRIPTION: 'CLAIM_HEALTH_DETAIL__AILMENT_DESCRIPTION'
  DISCHARGE_DATE: 'CLAIM_HEALTH_DETAIL__DISCHARGE_DATE'
  HEALTH_CLAIM_REMARKS: 'CLAIM_HEALTH_DETAIL__HEALTH_CLAIM_REMARKS'
  ICD_CODE: 'CLAIM_HEALTH_DETAIL__ICD_CODE'
  PRE_EXISTING_DISEASE_RELATED_INDICATOR: 'CLAIM_HEALTH_DETAIL__PRE_EXISTING_DISEASE_RELATED_INDICATOR'
  TREATING_DOCTOR_NAME: 'CLAIM_HEALTH_DETAIL__TREATING_DOCTOR_NAME'
  TREATMENT_TYPE: 'CLAIM_HEALTH_DETAIL__TREATMENT_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
