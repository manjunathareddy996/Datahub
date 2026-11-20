-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_PARTY_DIGITAL_IDENTITY (parent HUB_PARTY, history SCD2), fed whole from central view stitch_motor__v11_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__party_digital_identity'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'ACTIVE_SEQUENCE_NUMBER_CK'
  - 'ACCESS_CHANNEL_CK'
src_payload:
  - 'BROWSER_NAME'
  - 'CLIENT_IP_ADDRESS'
  - 'CONNECTION_BANDWIDTH'
  - 'FORWARDED_IP_ADDRESS'
  - 'MACHINE_IP_ADDRESS'
  - 'PROXY_IP_ADDRESS'
  - 'THIRD_IP_ADDRESS'
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
