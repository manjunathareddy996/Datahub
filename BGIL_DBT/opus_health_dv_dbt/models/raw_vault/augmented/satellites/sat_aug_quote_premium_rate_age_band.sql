-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_QUOTE_PREMIUM_RATE_AGE_BAND (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_v33_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_quote_premium_rate_age_band'
src_pk: 'QUOTE_HKEY'
src_cdk:
  - 'PREMIUM_TYPE_CK'
  - 'SUM_INSURED_SLAB_CK'
  - 'AGE_BAND_CODE_CK'
src_payload:
  - 'AGE_BAND_PREMIUM_RATE'
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
