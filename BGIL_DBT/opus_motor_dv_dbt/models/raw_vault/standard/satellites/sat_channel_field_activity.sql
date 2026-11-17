-- Standard ma_sat() for SAT_CHANNEL_FIELD_ACTIVITY (parent HUB_DISTRIBUTION_CHANNEL, history Multi-Active), fed whole from central view stitch_motor__v06_distribution_channel.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__channel_field_activity'
src_pk: 'DISTRIBUTION_CHANNEL_HKEY'
src_cdk:
  - 'ACTIVITY_REFERENCE_CK'
src_payload:
  - 'ACTIVITY_REFERENCE'
  - 'FOLLOW_UP_DATE'
  - 'LEAD_REFERENCE'
  - 'MEETING_PURPOSE'
  - 'OUTCOME_STATUS'
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
