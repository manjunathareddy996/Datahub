-- Standard ma_sat() for SAT_RISK_TRAILER (parent HUB_RISK_OBJECT, history Multi-Active SCD2), fed whole from central view stitch_motor__v10_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_trailer'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'TRAILER_SEQUENCE_CK'
src_payload:
  - 'ATTACHED_INDICATOR'
  - 'TRAILER_IDV'
  - 'TRAILER_REGISTRATION_NUMBER'
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
