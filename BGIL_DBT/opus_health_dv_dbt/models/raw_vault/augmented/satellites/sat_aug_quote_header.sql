-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_QUOTE_HEADER (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_v33_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_quote_header'
src_pk: 'QUOTE_HKEY'
src_payload:
  - 'LAST_QUOTE_SUBMISSION_DATE'
  - 'QUOTE_BUSINESS_TYPE'
  - 'QUOTE_COPY_REFERENCE'
  - 'QUOTE_DATA_INFORMATION'
  - 'QUOTE_DESCRIPTION'
  - 'QUOTE_PRIORITY'
  - 'QUOTE_RESOLUTION_DATE'
  - 'QUOTE_SUBJECT'
  - 'QUOTE_SUB_STATUS'
  - 'QUOTE_SUB_STATUS_DESCRIPTION'
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
