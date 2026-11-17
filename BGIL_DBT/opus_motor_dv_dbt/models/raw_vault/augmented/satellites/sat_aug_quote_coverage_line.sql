-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_QUOTE_COVERAGE_LINE (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_motor__v22_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__quote_coverage_line'
src_pk: 'QUOTE_HKEY'
src_cdk:
  - 'COVERAGE_REFERENCE_CK'
src_payload:
  - 'CGST_AMOUNT'
  - 'COVERAGE_RATE'
  - 'COVERAGE_SEQUENCE'
  - 'DISCOUNT_AMOUNT'
  - 'DISCOUNT_ENABLED_INDICATOR'
  - 'EXCESS_AMOUNT'
  - 'IGST_AMOUNT'
  - 'LOADING_AMOUNT'
  - 'PERSONS_COVERED_COUNT'
  - 'PREMIUM_FOR_COVERAGE'
  - 'SGST_AMOUNT'
  - 'SUM_INSURED'
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
