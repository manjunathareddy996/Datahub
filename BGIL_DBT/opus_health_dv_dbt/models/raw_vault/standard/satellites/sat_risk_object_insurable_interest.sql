-- Standard ma_sat() for SAT_RISK_OBJECT_INSURABLE_INTEREST (parent HUB_RISK_OBJECT, history Multi-Active SCD2), fed whole from central view stitch_v31_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_risk_object_insurable_interest'
src_pk: 'RISK_OBJECT_HKEY'
src_cdk:
  - 'INTEREST_TYPE_CK'
  - 'INTEREST_HOLDER_REFERENCE_CK'
src_payload:
  - 'FINANCIER_NAME'
  - 'LOAN_AMOUNT'
  - 'LOAN_TYPE'
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
