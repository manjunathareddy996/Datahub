-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_QUOTE_PREMIUM_RATE_SLAB (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_v33_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_quote_premium_rate_slab'
src_pk: 'QUOTE_HKEY'
src_cdk:
  - 'PREMIUM_TYPE_CK'
  - 'SUM_INSURED_SLAB_CK'
src_payload:
  - 'PREMIUM_RATING_BASIS'
  - 'RATE_APPLICABILITY_STAGE'
  - 'RATE_RECORD_DATE'
  - 'RATE_SOURCE_NAME'
  - 'SUM_INSURED_SLAB_AMOUNT'
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
