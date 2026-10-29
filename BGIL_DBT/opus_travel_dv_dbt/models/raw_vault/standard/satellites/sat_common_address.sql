{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_COMMON_ADDRESS (parent HUB_LOCATION).
-- Round-2 fix: now sourced from BOTH loader tables (BJAZ_TRV_LOADER_DATA was previously
-- unbuildable -- no HUB_LOCATION key on that table at all -- and
-- BJAZ_TRV_LOADER_LOG_TABLE was wrongly keyed via TRANSITFROM). Both now use the
-- address-point content-hash key. COUNTRY_NAME only comes from the log table (the data
-- table's address block has no country column) -- null for proposer rows, real data for
-- insured rows, same as any other partially-populated union column.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_common_address_bjaz_trv_loader_data'
  - 'stg2_common_address_bjaz_trv_loader_log_table'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'BUILDING_NAME'
  - 'CITY'
  - 'COUNTRY_NAME'
  - 'POSTAL_CODE'
  - 'STATE_NAME'
  - 'STREET_NAME'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_common_address_bjaz_trv_loader_data: 'OPUS'
  stg2_common_address_bjaz_trv_loader_log_table: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map']) }}
