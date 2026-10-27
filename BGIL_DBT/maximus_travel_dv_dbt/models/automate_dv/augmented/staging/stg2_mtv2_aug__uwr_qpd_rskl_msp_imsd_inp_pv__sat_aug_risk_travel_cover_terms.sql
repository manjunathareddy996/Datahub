{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_RISK_TRAVEL_COVER_TERMS from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv__aug_sat_aug_risk_travel_cover_terms: 6 instance(s) on this view.
--
-- 3 payload column(s); the child key is SUB_COVER_CODE.

{%- set yaml_metadata -%}
source_model: 'up_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv__aug_sat_aug_risk_travel_cover_terms'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF_RISK_TRAVEL_COVER_TERMS:
    is_hashdiff: true
    columns:
      - 'ACE_COVER_DURATION'
      - 'ACE_SUM_INSURED'
      - 'SUB_COVER_CODE'
      - 'SUB_COVER_SUM_INSURED'
derived_columns:
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (RISK_OBJECT_BK)"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  SUB_COVER_CODE: 'SUB_COVER_CODE'
  ACE_COVER_DURATION: 'ACE_COVER_DURATION'
  ACE_SUM_INSURED: 'ACE_SUM_INSURED'
  SUB_COVER_SUM_INSURED: 'SUB_COVER_SUM_INSURED'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
