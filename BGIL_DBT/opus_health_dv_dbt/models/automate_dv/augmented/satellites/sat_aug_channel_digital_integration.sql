-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CHANNEL_DIGITAL_INTEGRATION (parent HUB_DISTRIBUTION_CHANNEL, history SCD2), fed whole from central view stitch_v34_risk_object.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_channel_digital_integration'
src_pk: 'DISTRIBUTION_CHANNEL_HKEY'
src_payload:
  - 'SUBMITTING_USER_LOGIN_IDENTIFIER'
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
