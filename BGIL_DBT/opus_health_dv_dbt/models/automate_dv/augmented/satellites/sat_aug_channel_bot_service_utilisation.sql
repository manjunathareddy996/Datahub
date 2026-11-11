-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CHANNEL_BOT_SERVICE_UTILISATION (parent HUB_DISTRIBUTION_CHANNEL, history SCD2), fed whole from central view stitch_v13_financial_account.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_channel_bot_service_utilisation'
src_pk: 'DISTRIBUTION_CHANNEL_HKEY'
src_payload:
  - 'BOT_SERVICE_NAME'
  - 'PREVIOUS_SESSION_BUSINESS_REFERENCE'
  - 'REQUEST_TYPE'
  - 'SERVICE_INVOCATION_COUNT'
  - 'SESSION_BUSINESS_REFERENCE'
  - 'UTILISATION_RECORD_DATE'
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
