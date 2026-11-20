-- Standard ma_sat() for SAT_CLAIM_RESERVE_HEAD (parent HUB_CLAIM, history Multi-Active SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__claim_reserve_head'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'RESERVE_HEAD_CODE_CK'
src_payload:
  - 'HEAD_DESCRIPTION'
  - 'OPENING_RESERVE'
  - 'OUTSTANDING_AGAINST_HEAD'
  - 'PAID_AGAINST_HEAD'
  - 'RESERVE_HEAD_CODE'
  - 'REVISED_RESERVE'
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
