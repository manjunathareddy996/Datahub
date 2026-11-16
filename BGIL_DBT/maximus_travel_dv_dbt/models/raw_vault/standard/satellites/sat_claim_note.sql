{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat_multi_source() for SAT_CLAIM_NOTE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- Contract (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, multi-active on NOTE_SEQUENCE.
--
-- Two feeders arrive through satfeed_mt_sat_claim_note:
--   ..._CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW           (clmap)
--   ..._CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW (rska)
-- ma_sat_multi_source compares each (CLAIM_HKEY, RECORD_SOURCE) group on its own, so
-- an incremental run that carries only one feeder never drops the other feeder's
-- notes from the latest version. Both feeders share GENERAL_COMMENTS and
-- TEAM_TRACKING_COMMENTS as NOTE_SEQUENCE; grouping by RECORD_SOURCE keeps them apart.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mt_sat_claim_note'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'NOTE_SEQUENCE'
src_payload:
  - 'ACTION_TAKEN'
  - 'NOTE_TEXT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mt_sat_claim_note: 'MAXIMUS_TRAVEL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_record_source_map=metadata_dict['src_record_source_map'],
                       src_column_map={
                        'satfeed_mt_sat_claim_note': ['ACTION_TAKEN', 'NOTE_TEXT']
                       }) }}
