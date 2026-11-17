-- Standard ma_sat() for SAT_QUOTE_COMPARISON (parent HUB_QUOTE, history Multi-Active SCD2), fed whole from central view stitch_motor__v11_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__quote_comparison'
src_pk: 'QUOTE_HKEY'
src_cdk:
  - 'OPTION_CODE_CK'
src_payload:
  - 'PREMIUM_OPTION'
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
