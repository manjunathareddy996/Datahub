{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat_multi_source() for SAT_PARTY_IDENTIFICATION (HUB_PARTY grain) -- 6 source stage(s).
-- Same pattern as maximus_partner / opus_partner / maximus_travel: one row per PARTY_HKEY and source
-- group, with AADHAARNUMBER / GSTIN / PASSPORTNUMBER folded into OBJECTs keyed by source table.
-- Change detection and the watermark are per RECORD_SOURCE group (OPUS_TRAVEL), so other projects'
-- rows are never touched.
-- PASSPORTNUMBER comes from three different source tables (BA_TRV_DATA_POLICY_DTLS, BJAZ_TRV_LOADER_DATA,
-- BJAZ_TRV_LOADER_LOG_TABLE), so the object keeps all three. EIANUMBER is a plain column with one source.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_party_identification_ba_trv_data_policy_dtls_0'
  - 'stg2_party_identification_bjaz_trv_loader_data_1'
  - 'stg2_party_identification_bjaz_trv_loader_data_2'
  - 'stg2_party_identification_bjaz_trv_loader_data_3'
  - 'stg2_party_identification_bjaz_trv_loader_data_4'
  - 'stg2_party_identification_bjaz_trv_loader_log_table_5'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AADHAARNUMBER'
  - 'EIANUMBER'
  - 'GSTIN'
  - 'PASSPORTNUMBER'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_party_identification_ba_trv_data_policy_dtls_0: 'OPUS_TRAVEL'
  stg2_party_identification_bjaz_trv_loader_data_1: 'OPUS_TRAVEL'
  stg2_party_identification_bjaz_trv_loader_data_2: 'OPUS_TRAVEL'
  stg2_party_identification_bjaz_trv_loader_data_3: 'OPUS_TRAVEL'
  stg2_party_identification_bjaz_trv_loader_data_4: 'OPUS_TRAVEL'
  stg2_party_identification_bjaz_trv_loader_log_table_5: 'OPUS_TRAVEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_object_columns=['AADHAARNUMBER', 'GSTIN', 'PASSPORTNUMBER'],
                    src_column_map={
                        'stg2_party_identification_ba_trv_data_policy_dtls_0': ['PASSPORTNUMBER'],
                        'stg2_party_identification_bjaz_trv_loader_data_1': ['AADHAARNUMBER'],
                        'stg2_party_identification_bjaz_trv_loader_data_2': ['EIANUMBER'],
                        'stg2_party_identification_bjaz_trv_loader_data_3': ['GSTIN'],
                        'stg2_party_identification_bjaz_trv_loader_data_4': ['PASSPORTNUMBER'],
                        'stg2_party_identification_bjaz_trv_loader_log_table_5': ['PASSPORTNUMBER']
                    }) }}
