-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CASE_LITIGATION (parent HUB_CASE, history SCD2), fed whole from central view stitch_motor__v02_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__case_litigation'
src_pk:
  - 'CASE_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'COURT_CASE_NUMBER'
  - 'COURT_RELEASE_ORDER_OBTAINED_INDICATOR'
  - 'COURT_RELEASE_ORDER_RECEIVED_DATE'
  - 'COURT_SALE_ORDER_OBTAINED_INDICATOR'
  - 'COURT_SALE_ORDER_RECEIVED_DATE'
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
