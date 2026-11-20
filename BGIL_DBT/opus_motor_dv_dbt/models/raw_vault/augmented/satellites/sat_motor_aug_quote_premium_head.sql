-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_QUOTE_PREMIUM_HEAD (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_motor__v22_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__quote_premium_head'
src_pk:
  - 'QUOTE_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'PREMIUM_HEAD_CODE_CK'
  - 'SECTION_CK'
src_payload:
  - 'NET_HEAD_PREMIUM'
  - 'PREMIUM_COMPONENT'
  - 'PREMIUM_HEAD_CODE'
  - 'PREMIUM_HEAD_NAME'
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
