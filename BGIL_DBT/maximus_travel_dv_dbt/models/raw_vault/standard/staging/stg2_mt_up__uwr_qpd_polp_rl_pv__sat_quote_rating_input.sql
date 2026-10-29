{{ config(materialized='view') }}

-- UNPIVOT STAGE for SAT_QUOTE_RATING_INPUT from uwr_qpd_polp_rl_pv.
-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every
-- column is listed explicitly: a stage that passes its source's columns through makes
-- the satellite's real feeder columns invisible to anything reading the YAML, which is
-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).

{%- set yaml_metadata -%}
source_model: 'up_mt__uwr_qpd_polp_rl_pv__sat_quote_rating_input'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_RATING_INPUT:
    is_hashdiff: true
    columns:
      - 'FACTOR_CODE'
      - 'FACTOR_VALUE'
      - 'PREMIUM_IMPACT'
      - 'RELATIVITY_APPLIED'
derived_columns:
  QUOTE_NK: "'HUB_QUOTE|' || (QUOTE_BK)"
  QUOTE_BK: 'QUOTE_BK'
  FACTOR_CODE: 'FACTOR_CODE'
  FACTOR_VALUE: 'FACTOR_VALUE'
  PREMIUM_IMPACT: 'PREMIUM_IMPACT'
  RELATIVITY_APPLIED: 'RELATIVITY_APPLIED'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
