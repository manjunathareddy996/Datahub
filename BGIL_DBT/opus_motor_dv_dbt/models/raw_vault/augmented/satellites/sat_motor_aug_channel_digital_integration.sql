-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CHANNEL_DIGITAL_INTEGRATION (parent HUB_DISTRIBUTION_CHANNEL, history SCD2), fed whole from central view stitch_motor__v11_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__channel_digital_integration'
src_pk:
  - 'DISTRIBUTION_CHANNEL_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'PARTNER_REQUEST_REFERENCE'
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
