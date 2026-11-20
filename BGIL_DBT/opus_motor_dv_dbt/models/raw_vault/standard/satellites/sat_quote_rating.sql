-- Standard sat() for SAT_QUOTE_RATING (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_motor__v23_quote.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__quote_rating'
src_pk:
  - 'QUOTE_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'DISCOUNT_AMOUNT'
  - 'GROSS_PREMIUM'
  - 'INDICATIVE_DEDUCTIBLE'
  - 'LOADING_AMOUNT'
  - 'NET_PREMIUM'
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
