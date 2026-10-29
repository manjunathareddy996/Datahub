{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_QUOTE_PREMIUM_HEAD from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mt__uwr_qpd_polp_msp_imsd_inp_pv__aug_sat_aug_quote_premium_head: 5 instance(s) on this view.
--
-- 2 payload column(s); the child key is PREMIUM_HEAD_CODE.

{%- set yaml_metadata -%}
source_model: 'up_mt__uwr_qpd_polp_msp_imsd_inp_pv__aug_sat_aug_quote_premium_head'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_PREMIUM_HEAD:
    is_hashdiff: true
    columns:
      - 'BASE_AMOUNT'
      - 'NET_HEAD_PREMIUM'
      - 'PREMIUM_HEAD_CODE'
derived_columns:
  QUOTE_NK: "'HUB_QUOTE|' || (QUOTE_BK)"
  QUOTE_BK: 'QUOTE_BK'
  PREMIUM_HEAD_CODE: 'PREMIUM_HEAD_CODE'
  BASE_AMOUNT: 'BASE_AMOUNT'
  NET_HEAD_PREMIUM: 'NET_HEAD_PREMIUM'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
