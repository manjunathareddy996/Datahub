{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_RISK_PERSON_TRAVEL (parent HUB_RISK_OBJECT).
-- Round 3: member1..5 stages extended with (a) BJAZ_TRV_LOADER_DATA's own trip columns
-- that were silently unbuilt before (self-caught gap, no MemberN prefix -- see
-- stitch_risk_person_travel_trip_attrs.sql header) and (b) BA_TRV_DATA_POLICY_DTLS's trip
-- attributes, fanned out via that stitch join (mapper-confirmed shared POLICY_REF).
-- GEOGRAPHICAL_ZONE/TRIP_DURATION/DESTINATION_COUNTRY are COALESCE'd between the two
-- sources at the per-member stage() layer -- data_5b has one slot for each, not separate
-- per-source or code/name variants.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_member1'
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_member2'
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_member3'
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_member4'
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_member5'
  - 'stg2_risk_person_travel_bjaz_trv_loader_log_table'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'DESTINATION_COUNTRY'
  - 'GEOGRAPHICAL_ZONE'
  - 'PASSPORT_NUMBER'
  - 'TRIP_DURATION'
  - 'TRIP_END_DATE'
  - 'TRIP_START_DATE'
  - 'TRIP_TYPE'
  - 'VISA_TYPE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_risk_person_travel_bjaz_trv_loader_data_member1: 'OPUS'
  stg2_risk_person_travel_bjaz_trv_loader_data_member2: 'OPUS'
  stg2_risk_person_travel_bjaz_trv_loader_data_member3: 'OPUS'
  stg2_risk_person_travel_bjaz_trv_loader_data_member4: 'OPUS'
  stg2_risk_person_travel_bjaz_trv_loader_data_member5: 'OPUS'
  stg2_risk_person_travel_bjaz_trv_loader_log_table: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map']) }}
