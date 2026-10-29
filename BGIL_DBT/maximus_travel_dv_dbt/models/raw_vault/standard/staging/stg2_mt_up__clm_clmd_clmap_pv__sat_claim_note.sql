{{ config(materialized='view') }}

-- UNPIVOT STAGE for SAT_CLAIM_NOTE from clm_clmd_clmap_pv.
-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every
-- column is listed explicitly: a stage that passes its source's columns through makes
-- the satellite's real feeder columns invisible to anything reading the YAML, which is
-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).

{%- set yaml_metadata -%}
source_model: 'up_mt__clm_clmd_clmap_pv__sat_claim_note'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_NOTE:
    is_hashdiff: true
    columns:
      - 'NOTE_SEQUENCE'
      - 'ACTION_TAKEN'
      - 'NOTE_TEXT'
derived_columns:
  CLAIM_NK: "'HUB_CLAIM|' || (CLAIM_BK)"
  CLAIM_BK: 'CLAIM_BK'
  NOTE_SEQUENCE: 'NOTE_SEQUENCE'
  ACTION_TAKEN: 'ACTION_TAKEN'
  NOTE_TEXT: 'NOTE_TEXT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
