{{ config(materialized='view') }}

-- UNPIVOT STAGE for SAT_LNK_PARTY_ROLE_CORE from uwr_pol_prp_pp_sp_pv.
-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every
-- column is listed explicitly: a stage that passes its source's columns through makes
-- the satellite's real feeder columns invisible to anything reading the YAML, which is
-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).

{%- set yaml_metadata -%}
source_model: 'up_mtv2__uwr_pol_prp_pp_sp_pv__sat_lnk_party_role_core'
hashed_columns:
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
  HASHDIFF_LNK_PARTY_ROLE_CORE:
    is_hashdiff: true
    columns:
      - 'ROLE_CODE'
      - 'ROLE_SEQUENCE'
      - 'ROLE_TYPE'
derived_columns:
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (PARTY_BK__PROPOSER)"
  PARTY_BK__PROPOSER: 'PARTY_BK__PROPOSER'
  ROLE_CODE: 'ROLE_CODE'
  ROLE_SEQUENCE: 'ROLE_SEQUENCE'
  ROLE_TYPE: 'ROLE_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
