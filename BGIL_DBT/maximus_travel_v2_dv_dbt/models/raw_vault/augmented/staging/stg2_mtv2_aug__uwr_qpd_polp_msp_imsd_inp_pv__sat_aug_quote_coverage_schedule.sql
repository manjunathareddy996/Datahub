{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_QUOTE_COVERAGE_SCHEDULE from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mtv2__uwr_qpd_polp_msp_imsd_inp_pv__aug_sat_aug_quote_coverage_schedule: 8 instance(s) on this view.
--
-- 9 payload column(s); the child key is COVERAGE_REFERENCE.

{%- set yaml_metadata -%}
source_model: 'up_mtv2__uwr_qpd_polp_msp_imsd_inp_pv__aug_sat_aug_quote_coverage_schedule'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_COVERAGE_SCHEDULE:
    is_hashdiff: true
    columns:
      - 'COVERAGE_DURATION'
      - 'COVERAGE_REFERENCE'
      - 'DEDUCTIBLE_AMOUNT'
      - 'DELAY_TRIGGER_THRESHOLD'
      - 'EXCLUDED_COUNTRIES'
      - 'EXCLUDED_EVENTS'
      - 'ITEMS_COVERED'
      - 'PREMIUM_BASIS'
      - 'SUB_COVER_SELECTION'
      - 'SUM_INSURED_AMOUNT'
derived_columns:
  QUOTE_NK: "'HUB_QUOTE|' || (QUOTE_BK)"
  QUOTE_BK: 'QUOTE_BK'
  COVERAGE_REFERENCE: 'COVERAGE_REFERENCE'
  COVERAGE_DURATION: 'COVERAGE_DURATION'
  DEDUCTIBLE_AMOUNT: 'DEDUCTIBLE_AMOUNT'
  DELAY_TRIGGER_THRESHOLD: 'DELAY_TRIGGER_THRESHOLD'
  EXCLUDED_COUNTRIES: 'EXCLUDED_COUNTRIES'
  EXCLUDED_EVENTS: 'EXCLUDED_EVENTS'
  ITEMS_COVERED: 'ITEMS_COVERED'
  PREMIUM_BASIS: 'PREMIUM_BASIS'
  SUB_COVER_SELECTION: 'SUB_COVER_SELECTION'
  SUM_INSURED_AMOUNT: 'SUM_INSURED_AMOUNT'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
