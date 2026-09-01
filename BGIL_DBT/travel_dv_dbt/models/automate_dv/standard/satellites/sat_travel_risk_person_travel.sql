{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_RISK_PERSON_TRAVEL (parent HUB_RISK_OBJECT).
-- Round 3: member1..5 stages extended with (a) BJAZ_TRV_LOADER_DATA_MV's own trip columns
-- that were silently unbuilt before (self-caught gap, no MemberN prefix -- see
-- stitch_risk_person_travel_trip_attrs.sql header) and (b) BA_TRV_DATA_POLICY_DTLS_MV's trip
-- attributes, fanned out via that stitch join (mapper-confirmed shared POLICY_REF).
-- GEOGRAPHICAL_ZONE/TRIP_DURATION/DESTINATION_COUNTRY are COALESCE'd between the two
-- sources at the per-member stage() layer -- data_5b has one slot for each, not separate
-- per-source or code/name variants.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_mv_member1'
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_mv_member2'
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_mv_member3'
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_mv_member4'
  - 'stg2_risk_person_travel_bjaz_trv_loader_data_mv_member5'
  - 'stg2_risk_person_travel_bjaz_trv_loader_log_table_mv'
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
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
