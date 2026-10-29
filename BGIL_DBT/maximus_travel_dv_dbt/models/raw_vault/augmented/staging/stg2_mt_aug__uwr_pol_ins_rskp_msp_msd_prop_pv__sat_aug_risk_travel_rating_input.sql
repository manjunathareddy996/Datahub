{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_RISK_TRAVEL_RATING_INPUT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mt__uwr_pol_ins_rskp_msp_msd_prop_pv__aug_sat_aug_risk_travel_rating_input: 12 instance(s) on this view.
--
-- 3 payload column(s); the child key is RATING_INPUT_CODE.

{%- set yaml_metadata -%}
source_model: 'up_mt__uwr_pol_ins_rskp_msp_msd_prop_pv__aug_sat_aug_risk_travel_rating_input'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF_RISK_TRAVEL_RATING_INPUT:
    is_hashdiff: true
    columns:
      - 'PREMIUM_COMPONENT_AMOUNT'
      - 'PREMIUM_RATE_VALUE'
      - 'PREMIUM_TYPE'
      - 'RATING_INPUT_CODE'
derived_columns:
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (RISK_OBJECT_BK)"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RATING_INPUT_CODE: 'RATING_INPUT_CODE'
  PREMIUM_COMPONENT_AMOUNT: 'PREMIUM_COMPONENT_AMOUNT'
  PREMIUM_RATE_VALUE: 'PREMIUM_RATE_VALUE'
  PREMIUM_TYPE: 'PREMIUM_TYPE'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
