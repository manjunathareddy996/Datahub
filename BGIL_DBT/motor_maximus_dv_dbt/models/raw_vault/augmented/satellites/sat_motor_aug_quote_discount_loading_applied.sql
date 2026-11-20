-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_QUOTE_DISCOUNT_LOADING_APPLIED (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_mxm__v01_assessment.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__quote_discount_loading_applied'
src_pk:
  - 'QUOTE_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'ITEM_CODE_CK'
src_payload:
  - 'AMOUNT_APPLIED'
  - 'COMMISSION_DISCOUNT_AMOUNT'
  - 'EXTRA_DISCOUNT_OPTED_INDICATOR'
  - 'PERCENTAGE_APPLIED'
  - 'RATING_FACTOR_VALUE'
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
