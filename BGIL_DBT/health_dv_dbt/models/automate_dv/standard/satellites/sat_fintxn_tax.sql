{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_FINTXN_TAX (HUB_FINANCIAL_TRANSACTION grain) -- union of 3 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_health_webservice_info__fintxn_tax'
  - 'stg2_sat_bjaz_hm_hcm_extract__fintxn_tax'
  - 'stg2_sat_bjaz_tpa_claim_details_ws__fintxn_tax'
src_pk: 'FINANCIAL_TRANSACTION_HK'
src_cdk:
  - 'TAX_TYPE_CK'
src_payload:
  - 'CGST_AMOUNT'
  - 'IGST_AMOUNT'
  - 'SERVICE_TAX_AMOUNT'
  - 'SERVICE_TAX_RATE'
  - 'SERVICE_TAX_REGISTRATION_NUMBER'
  - 'SGST_AMOUNT'
  - 'TDS_RATE'
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
