-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_PRODUCT_TAX_APPLICABILITY (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_motor__v20_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__product_tax_applicability'
src_pk: 'PRODUCT_HKEY'
src_cdk:
  - 'VEHICLE_CATEGORY_CODE_CK'
  - 'EFFECTIVE_DATE_CK'
src_payload:
  - 'EFFECTIVE_DATE'
  - 'THIRD_PARTY_GST_APPLICABLE_INDICATOR'
  - 'VEHICLE_CATEGORY_CODE'
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
