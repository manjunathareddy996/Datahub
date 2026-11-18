-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_RISK_OBJECT_VALUATION (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v24_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_object_valuation'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'CUBIC_METRE_DECLARED_VALUE'
  - 'EXPECTED_RESALE_VALUE_FROM'
  - 'EXPECTED_RESALE_VALUE_TO'
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
