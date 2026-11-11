-- Standard sat() for SAT_QUOTE_RATING (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_v31_product.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_quote_rating'
src_pk: 'QUOTE_HKEY'
src_payload:
  - 'DISCOUNT_AMOUNT'
  - 'GROSS_PREMIUM'
  - 'TOTAL_ANNUAL_PREMIUM'
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
