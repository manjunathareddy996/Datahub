{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_PROVIDER_TARIFF (HUB_PARTY grain) -- union of 2 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_hm_hospital_master_extn__provider_tariff'
  - 'stg2_sat_bjaz_hm_hosp_master_extn1__provider_tariff'
src_pk: 'PARTY_HK'
src_cdk:
  - 'SERVICE_CODE_CK'
src_payload:
  - 'DISCOUNT_PERCENTAGE'
  - 'EFFECTIVE_DATE'
  - 'EXPIRY_DATE'
  - 'PACKAGE_RATE'
  - 'ROOM_RENT_CAP'
  - 'SERVICE_DESCRIPTION'
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
