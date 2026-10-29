{{ config(materialized='view') }}

-- UNPIVOT STAGE for SAT_POLICY_PREMIUM_HEAD from uwr_pol_polp_msp_msd_prop_pv.
-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every
-- column is listed explicitly: a stage that passes its source's columns through makes
-- the satellite's real feeder columns invisible to anything reading the YAML, which is
-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).

{%- set yaml_metadata -%}
source_model: 'up_mt__uwr_pol_polp_msp_msd_prop_pv__sat_policy_premium_head'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_PREMIUM_HEAD:
    is_hashdiff: true
    columns:
      - 'ADJUSTED_INDICATOR'
      - 'COVERAGE_REFERENCE'
      - 'PREMIUM_HEAD_CODE'
      - 'SECTION'
      - 'BASE_AMOUNT'
      - 'LOADING_AMOUNT'
      - 'NET_HEAD_PREMIUM'
      - 'PREMIUM_BASIS'
derived_columns:
  POLICY_NK: "'HUB_POLICY|' || (POLICY_BK)"
  POLICY_BK: 'POLICY_BK'
  ADJUSTED_INDICATOR: 'ADJUSTED_INDICATOR'
  COVERAGE_REFERENCE: 'COVERAGE_REFERENCE'
  PREMIUM_HEAD_CODE: 'PREMIUM_HEAD_CODE'
  SECTION: 'SECTION'
  BASE_AMOUNT: 'BASE_AMOUNT'
  LOADING_AMOUNT: 'LOADING_AMOUNT'
  NET_HEAD_PREMIUM: 'NET_HEAD_PREMIUM'
  PREMIUM_BASIS: 'PREMIUM_BASIS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
