-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_BILL_LINE (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v08_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_bill_line'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'BILL_LINE_TYPE_CK'
  - 'LINE_PARTICULAR_CK'
  - 'BILL_HEAD_CODE_CK'
src_payload:
  - 'BILL_HEAD_CODE'
  - 'BILL_HEAD_LEVEL_1_NAME'
  - 'BILL_HEAD_LEVEL_2_NAME'
  - 'BILL_HEAD_LEVEL_3_NAME'
  - 'LINE_AMOUNT'
  - 'LINE_AMOUNT_PER_UNIT'
  - 'LINE_CLAIMED_AMOUNT'
  - 'LINE_PARTICULAR'
  - 'LINE_PARTICULAR_LEAD_TERM'
  - 'LINE_PARTICULAR_PROFILE_TERM'
  - 'LINE_PAYABLE_INDICATOR'
  - 'LINE_SEQUENCE_NUMBER'
  - 'LINE_UNIT_COUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
