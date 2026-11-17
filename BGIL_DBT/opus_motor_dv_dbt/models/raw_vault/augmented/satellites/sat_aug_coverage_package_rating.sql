-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_COVERAGE_PACKAGE_RATING (parent HUB_COVERAGE, history SCD2), fed whole from central view stitch_motor__v04_coverage.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__coverage_package_rating'
src_pk: 'COVERAGE_HKEY'
src_cdk:
  - 'ADD_ON_PACKAGE_CODE_CK'
  - 'PACKAGE_REFERENCE_CK'
src_payload:
  - 'ADD_ON_PACKAGE_CODE'
  - 'ADD_ON_PACKAGE_NAME'
  - 'ADD_ON_PACKAGE_TYPE'
  - 'MAXIMUM_BENEFIT_DAYS'
  - 'PACKAGE_DISCOUNT_ENABLED_INDICATOR'
  - 'PACKAGE_DISCOUNT_RATE'
  - 'PACKAGE_ENTRY_FLAG'
  - 'PACKAGE_LOADING_RATE'
  - 'PACKAGE_SELECTED_INDICATOR'
  - 'PACKAGE_SELECTION_STATUS'
  - 'PACKAGE_SUM_INSURED'
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
