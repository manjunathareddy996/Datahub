{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL ma_sat() for SAT_COMMON_CONTACT (parent HUB_PARTY), per data_5b
-- canonical childkey "Contact Point Type + Contact Priority Order".

{%- set yaml_metadata -%}
source_model:
  - 'stg2_common_contact_bjaz_trv_loader_data_0'
  - 'stg2_common_contact_bjaz_trv_loader_data_1'
  - 'stg2_common_contact_bjaz_trv_loader_data_2'
  - 'stg2_common_contact_bjaz_trv_loader_data_3'
  - 'stg2_common_contact_bjaz_trv_loader_data_4'
  - 'stg2_common_contact_bjaz_trv_loader_log_table_5'
  - 'stg2_common_contact_bjaz_trv_loader_log_table_6'
  - 'stg2_common_contact_bjaz_trv_loader_log_table_7'
  - 'stg2_common_contact_bjaz_trv_loader_log_table_8'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'CONTACT_POINT_TYPE'
  - 'CONTACT_PRIORITY_ORDER'
src_payload:
  - 'EMAIL_ADDRESS'
  - 'FAX_NUMBER'
  - 'LANDLINE_NUMBER'
  - 'MOBILE_NUMBER'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_common_contact_bjaz_trv_loader_data_0: 'OPUS'
  stg2_common_contact_bjaz_trv_loader_data_1: 'OPUS'
  stg2_common_contact_bjaz_trv_loader_data_2: 'OPUS'
  stg2_common_contact_bjaz_trv_loader_data_3: 'OPUS'
  stg2_common_contact_bjaz_trv_loader_data_4: 'OPUS'
  stg2_common_contact_bjaz_trv_loader_log_table_5: 'OPUS'
  stg2_common_contact_bjaz_trv_loader_log_table_6: 'OPUS'
  stg2_common_contact_bjaz_trv_loader_log_table_7: 'OPUS'
  stg2_common_contact_bjaz_trv_loader_log_table_8: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_record_source_map=metadata_dict['src_record_source_map']) }}
