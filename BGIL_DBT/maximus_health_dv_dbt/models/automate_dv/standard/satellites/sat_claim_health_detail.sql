-- Standard sat() for SAT_CLAIM_HEALTH_DETAIL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_claim_health_detail'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ADMISSION_DATE'
  - 'ADMISSION_TIME'
  - 'AILMENT_DESCRIPTION'
  - 'AYUSH_TREATMENT_INDICATOR'
  - 'CASHLESS_AUTHORISATION_NUMBER'
  - 'DEDUCTIBLE_DETAIL'
  - 'DIAGNOSIS_CODE'
  - 'DISALLOWED_AMOUNT'
  - 'DISCHARGE_DATE'
  - 'DISCHARGE_TIME'
  - 'ELIGIBLE_ROOM_CATEGORY'
  - 'ELIGIBLE_ROOM_RENT'
  - 'EXPECTED_DISCHARGE_DATE'
  - 'HOSPITAL_REFERENCE'
  - 'ICD_CODE'
  - 'IPD_NUMBER'
  - 'LENGTH_OF_STAY'
  - 'NETWORK_DISCOUNT_AMOUNT'
  - 'PROCEDURE_CODE'
  - 'PROCEDURE_DESCRIPTION'
  - 'ROOM_CATEGORY'
  - 'TREATING_DOCTOR_NAME'
  - 'TREATMENT_TYPE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_payload=metadata_dict['src_payload'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
