{{ config(materialized='view') }}

-- UNPIVOT STAGE for SAT_POLICY_DISCOUNT_LOADING_APPLIED from uwr_pol_polp_sp_pv.
-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every
-- column is listed explicitly: a stage that passes its source's columns through makes
-- the satellite's real feeder columns invisible to anything reading the YAML, which is
-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).

{%- set yaml_metadata -%}
source_model: 'up_mtv2__uwr_pol_polp_sp_pv__sat_policy_discount_loading_applied'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_DISCOUNT_LOADING_APPLIED:
    is_hashdiff: true
    columns:
      - 'ITEM_CODE'
      - 'AMOUNT_APPLIED'
      - 'ITEM_TYPE'
      - 'PERCENTAGE_APPLIED'
derived_columns:
  POLICY_NK: "'HUB_POLICY|' || (POLICY_BK)"
  POLICY_BK: 'POLICY_BK'
  ITEM_CODE: 'ITEM_CODE'
  AMOUNT_APPLIED: 'AMOUNT_APPLIED'
  ITEM_TYPE: 'ITEM_TYPE'
  PERCENTAGE_APPLIED: 'PERCENTAGE_APPLIED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
