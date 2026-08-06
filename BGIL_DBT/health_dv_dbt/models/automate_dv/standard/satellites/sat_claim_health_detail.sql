{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_CLAIM_HEALTH_DETAIL (HUB_CLAIM grain) -- stitch-backed, 25 table(s) joined.
-- Source: stg2_claim_health_detail.

{%- set yaml_metadata -%}
source_model: 'stg2_claim_health_detail'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ACTUAL_PACKAGE_AMOUNT'
  - 'ADMISSION_DATE'
  - 'ADMISSION_TIME'
  - 'AILMENT_DESCRIPTION'
  - 'AMBULANCE_CHARGES'
  - 'ANAESTHETIST_FEE'
  - 'CASHLESS_AUTHORISATION_NUMBER'
  - 'CO_PAY_AMOUNT'
  - 'DIAGNOSIS_CODE'
  - 'DISALLOWANCE_REASON'
  - 'DISALLOWED_AMOUNT'
  - 'DISCHARGE_DATE'
  - 'DISCHARGE_TIME'
  - 'ELIGIBLE_ROOM_CATEGORY'
  - 'ELIGIBLE_ROOM_RENT'
  - 'EXPECTED_DISCHARGE_DATE'
  - 'FINAL_BILL_AMOUNT'
  - 'HEALTH_CLAIM_REMARKS'
  - 'HOSPITAL_REFERENCE'
  - 'ICD_CODE'
  - 'ICU_CHARGES_AMOUNT'
  - 'ICU_RENT_AMOUNT'
  - 'IMPLANT_COST'
  - 'IMPLANT_INDICATOR'
  - 'INVESTIGATION_CHARGES'
  - 'IPD_NUMBER'
  - 'LENGTH_OF_STAY'
  - 'MISCELLANEOUS_CHARGES_AMOUNT'
  - 'NETWORK_DISCOUNT_AMOUNT'
  - 'NETWORK_HOSPITAL_INDICATOR'
  - 'NURSING_CHARGES'
  - 'OT_CHARGES'
  - 'OTHER_DEDUCTION_AMOUNT'
  - 'PHARMACY_AMOUNT'
  - 'POST_HOSPITALISATION_AMOUNT'
  - 'PRE_AUTHORISATION_AMOUNT'
  - 'PRE_AUTHORISATION_REMARKS'
  - 'PRE_HOSPITALISATION_AMOUNT'
  - 'PROCEDURE_CODE'
  - 'PROCEDURE_DESCRIPTION'
  - 'ROOM_CATEGORY'
  - 'ROOM_RENT_AMOUNT'
  - 'SPECIALTY'
  - 'SURGEON_FEE'
  - 'SURGERY_INDICATOR'
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
