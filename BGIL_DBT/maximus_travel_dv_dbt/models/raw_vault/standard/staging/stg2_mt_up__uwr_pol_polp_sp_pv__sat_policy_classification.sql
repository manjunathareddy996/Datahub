{{ config(materialized='view') }}

-- UNPIVOT STAGE for SAT_POLICY_CLASSIFICATION from uwr_pol_polp_sp_pv.
-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every
-- column is listed explicitly: a stage that passes its source's columns through makes
-- the satellite's real feeder columns invisible to anything reading the YAML, which is
-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).

{%- set yaml_metadata -%}
source_model: 'up_mt__uwr_pol_polp_sp_pv__sat_policy_classification'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_CLASSIFICATION:
    is_hashdiff: true
    columns:
      - 'CLASSIFICATION_TYPE'
      - 'CLASSIFICATION_VALUE'
derived_columns:
  POLICY_NK: "'HUB_POLICY|' || (POLICY_BK)"
  POLICY_BK: 'POLICY_BK'
  CLASSIFICATION_TYPE: 'CLASSIFICATION_TYPE'
  CLASSIFICATION_VALUE: 'CLASSIFICATION_VALUE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
