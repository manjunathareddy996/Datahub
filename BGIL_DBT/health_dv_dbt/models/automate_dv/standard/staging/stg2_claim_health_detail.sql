{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_claim_health_detail -- serves SAT_CLAIM_HEALTH_DETAIL.
-- The ONE place CLAIM_HK gets hashed for this cluster (namespaced: 'HUB_CLAIM|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_claim_health_detail'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
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
derived_columns:
  CLAIM_NK: "'HUB_CLAIM|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
