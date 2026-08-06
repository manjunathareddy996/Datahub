{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_CLAIM_BENEFIT_HEAD (HUB_CLAIM grain) -- union of 2 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_hat_ocr_fina_dtls_lst__claim_benefit_head'
  - 'stg2_sat_bjaz_hm_hcm_extract__claim_benefit_head'
src_pk: 'CLAIM_HK'
src_cdk:
  - 'BENEFIT_HEAD_CODE_CK'
src_payload:
  - 'CLAIMED_AMOUNT'
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
