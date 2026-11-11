-- Standard sat() for SAT_QUOTE_HEADER (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_v02_assessment.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_quote_header'
src_pk: 'QUOTE_HKEY'
src_payload:
  - 'QUOTE_DATE'
  - 'QUOTE_REMARKS'
  - 'QUOTE_STATUS'
  - 'QUOTE_VERSION'
  - 'REQUESTED_COVER_START_DATE'
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
