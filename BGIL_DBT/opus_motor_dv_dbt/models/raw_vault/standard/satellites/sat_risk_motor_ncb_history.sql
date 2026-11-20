-- Standard sat() for SAT_RISK_MOTOR_NCB_HISTORY (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v25_risk_object.
-- SINGLE WRITER (G-3) BJAZ_MOT_WINBACK_DTLS | SAT_RISK_MOTOR_NCB_HISTORY | Previous Policy Number | None: emits PREV_POLICYNO; withheld PREV_POLICY_NUMBER
-- SINGLE WRITER (G-3) BJAZ_SCR_MOT_VEH_DTLS | SAT_RISK_MOTOR_NCB_HISTORY | No Claim Bonus Percentage | None: emits NCB_PERCENT; withheld NCB_RATE
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_motor_ncb_history'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'BREAK_IN_INSURANCE_INDICATOR'
  - 'IDV_PREVIOUS_YEAR'
  - 'NCB_CARRIED_FORWARD_PERCENTAGE'
  - 'NCB_ELIGIBLE_INDICATOR'
  - 'NO_CLAIM_BONUS_PERCENTAGE'
  - 'PREVIOUS_CLAIM_COUNT'
  - 'PREVIOUS_CLAIM_INDICATOR'
  - 'PREVIOUS_INSURER_ADDRESS'
  - 'PREVIOUS_INSURER_CODE'
  - 'PREVIOUS_INSURER_NAME'
  - 'PREVIOUS_NCB_PERCENTAGE'
  - 'PREVIOUS_POLICY_EFFECTIVE_FROM_DATE'
  - 'PREVIOUS_POLICY_EXPIRY_DATE'
  - 'PREVIOUS_POLICY_NUMBER'
  - 'PREVIOUS_POLICY_START_DATE'
  - 'TRANSFER_OF_NCB_INDICATOR'
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
