-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_PARTY_INTERACTION_EVENT (parent HUB_PARTY, history SCD2), fed whole from central view stitch_motor__v11_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__party_interaction_event'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'INTERACTION_SEQUENCE_CK'
  - 'INTERACTION_REFERENCE_CK'
src_payload:
  - 'FOLLOW_UP_TIME'
  - 'INTERACTION_REFERENCE'
  - 'INTERACTION_TIME'
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
