{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat_multi_source() for SAT_COMMON_CONTACT (HUB_PARTY grain) -- 9 source stage(s).
-- Same pattern as maximus_partner / opus_partner / maximus_travel: one row per PARTY_HKEY and source
-- group, with MOBILENUMBER folded into an OBJECT keyed by source table. Change detection and the
-- watermark are per RECORD_SOURCE group (OPUS_TRAVEL), so other projects' rows are never touched.
-- Each source table (LOADER_DATA, LOADER_LOG_TABLE) has one mobile number, so the object keeps both.
-- EMAILADDRESS / FAXNUMBER / LANDLINENUMBER are plain columns, as in the partner sats: stages _0 and _1
-- both feed EMAILADDRESS from LOADER_DATA, so only the MAX() value of the two is kept.

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
src_payload:
  - 'EMAIL_ADDRESS'
  - 'FAX_NUMBER'
  - 'LANDLINE_NUMBER'
  - 'MOBILE_NUMBER'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_common_contact_bjaz_trv_loader_data_0: 'OPUS_TRAVEL'
  stg2_common_contact_bjaz_trv_loader_data_1: 'OPUS_TRAVEL'
  stg2_common_contact_bjaz_trv_loader_data_2: 'OPUS_TRAVEL'
  stg2_common_contact_bjaz_trv_loader_data_3: 'OPUS_TRAVEL'
  stg2_common_contact_bjaz_trv_loader_data_4: 'OPUS_TRAVEL'
  stg2_common_contact_bjaz_trv_loader_log_table_5: 'OPUS_TRAVEL'
  stg2_common_contact_bjaz_trv_loader_log_table_6: 'OPUS_TRAVEL'
  stg2_common_contact_bjaz_trv_loader_log_table_7: 'OPUS_TRAVEL'
  stg2_common_contact_bjaz_trv_loader_log_table_8: 'OPUS_TRAVEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_object_columns=['MOBILE_NUMBER'],
                    src_column_map={
                        'stg2_common_contact_bjaz_trv_loader_data_0': ['EMAIL_ADDRESS'],
                        'stg2_common_contact_bjaz_trv_loader_data_1': ['EMAIL_ADDRESS'],
                        'stg2_common_contact_bjaz_trv_loader_data_2': ['FAX_NUMBER'],
                        'stg2_common_contact_bjaz_trv_loader_data_3': ['MOBILE_NUMBER'],
                        'stg2_common_contact_bjaz_trv_loader_data_4': ['LANDLINE_NUMBER'],
                        'stg2_common_contact_bjaz_trv_loader_log_table_5': ['EMAIL_ADDRESS'],
                        'stg2_common_contact_bjaz_trv_loader_log_table_6': ['FAX_NUMBER'],
                        'stg2_common_contact_bjaz_trv_loader_log_table_7': ['MOBILE_NUMBER'],
                        'stg2_common_contact_bjaz_trv_loader_log_table_8': ['LANDLINE_NUMBER']
                    }) }}
