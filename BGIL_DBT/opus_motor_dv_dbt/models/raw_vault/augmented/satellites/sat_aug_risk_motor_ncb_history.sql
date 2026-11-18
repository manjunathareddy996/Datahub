-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_RISK_MOTOR_NCB_HISTORY (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v25_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_motor_ncb_history'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE'
  - 'CLAIM_COUNT_TWO_YEAR'
  - 'CLAIM_DATES_LIST'
  - 'ELIGIBLE_NCB_PERCENTAGE'
  - 'LAST_CLAIM_TRANSACTION_DATE'
  - 'NCB_CARRY_FORWARD_PREVIOUS_POLICY_NUMBER'
  - 'NCB_SOURCE_CODE'
  - 'NO_CLAIM_BONUS_AMOUNT'
  - 'PREVIOUS_CLAIM_PATTERN'
  - 'PREVIOUS_NCB_AMOUNT'
  - 'REQUOTED_CLAIM_COUNT'
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
