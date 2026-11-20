-- Standard sat() for SAT_CHANNEL_DEFINITION (parent HUB_DISTRIBUTION_CHANNEL, history SCD2), fed whole from central view stitch_mxm__v10_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__channel_definition'
src_pk:
  - 'DISTRIBUTION_CHANNEL_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'CHANNEL_TYPE'
  - 'SUB_CHANNEL_CODE'
  - 'SUB_CHANNEL_EFFECTIVE_DATE'
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
