-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_PRODUCT_COMMISSION_GRID (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_motor__v20_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__product_commission_grid'
src_pk: 'PRODUCT_HKEY'
src_cdk:
  - 'ACTIVE_SEQUENCE_NUMBER_CK'
  - 'INTERMEDIARY_CODE_CK'
  - 'SUB_INTERMEDIARY_CODE_CK'
  - 'VEHICLE_TYPE_CODE_CK'
  - 'VEHICLE_MAKE_CODE_CK'
  - 'BUSINESS_TYPE_CODE_CK'
  - 'BAND_LOWER_BOUND_CK'
  - 'BAND_UPPER_BOUND_CK'
  - 'GRID_EFFECTIVE_DATE_CK'
src_payload:
  - 'APPLICABLE_BUSINESS_TYPE'
  - 'APPLICABLE_VEHICLE_MAKE_CODE'
  - 'APPLICABLE_VEHICLE_TYPE_CODE'
  - 'BENEFIT_PAYOUT_CAP_PERCENTAGE'
  - 'RELAXATION_CAP_PERCENTAGE'
  - 'RULE_STATUS'
  - 'VALUE_BAND_FROM'
  - 'VALUE_BAND_TO'
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
