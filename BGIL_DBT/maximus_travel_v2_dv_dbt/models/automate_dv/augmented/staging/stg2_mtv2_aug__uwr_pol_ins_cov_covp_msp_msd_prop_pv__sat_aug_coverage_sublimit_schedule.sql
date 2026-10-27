{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_COVERAGE_SUBLIMIT_SCHEDULE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 17 payload column(s); the child key is ACTIVE_SEQUENCE_NUMBER.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_cov_covp_msp_msd_prop_pv'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF_COVERAGE_SUBLIMIT_SCHEDULE:
    is_hashdiff: true
    columns:
      - 'ACTIVE_SEQUENCE_NUMBER'
      - 'BENEFIT_AMOUNT'
      - 'DELAY_THRESHOLD_EXCEEDED'
      - 'DELAY_THRESHOLD_EXCEEDED_ACE_VARIANT'
      - 'LIMIT_SUM_INSURED_AMOUNT'
      - 'LOADING_ACE_VARIANT'
      - 'MAIN_SUB_COVER_LOADING_ACE_VARIANT'
      - 'MAIN_SUB_COVER_RATE_PER_TRIP_PER_MILLE'
      - 'MAIN_SUB_COVER_SUM_INSURED_ACE_VARIANT'
      - 'OFFICE_PREMIUM_RATE_PER_MILLE_PER_ANNUM'
      - 'OFFICE_PREMIUM_RATE_PER_MILLE_PER_TRIP'
      - 'RATE_PER_TRIP_PER_MILLE'
      - 'RATING_SLAB_BAND'
      - 'SUB_LIMIT_DEDUCTIBLE_AMOUNT'
      - 'SUB_LIMIT_PERIOD'
      - 'SUM_INSURED_ACE_VARIANT'
      - 'TRIP_TYPE_FOR_INCONVENIENCE_COVER'
      - 'TRIP_TYPE_FOR_TRIP_CALCULATION'
derived_columns:
  COVERAGE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_cover_code),'')) is not null then 'COV:' || nullif(trim(w0_cover_code), '') end),'')"
  COVERAGE_NK: "'HUB_COVERAGE|' || (nullif(trim(case when coalesce(nullif(trim(w0_cover_code),'')) is not null then 'COV:' || nullif(trim(w0_cover_code), '') end),''))"
  ACTIVE_SEQUENCE_NUMBER: "coalesce(nullif(trim(sublimit_name), ''),'')"
  BENEFIT_AMOUNT: 'benefit_amount'
  DELAY_THRESHOLD_EXCEEDED: 'delay_exceeding'
  DELAY_THRESHOLD_EXCEEDED_ACE_VARIANT: 'delay_exceeding_ace'
  LIMIT_SUM_INSURED_AMOUNT: 'limit_sum_insured'
  LOADING_ACE_VARIANT: 'loading_ace'
  MAIN_SUB_COVER_LOADING_ACE_VARIANT: 'loading_ace_for_main_sub_cover'
  MAIN_SUB_COVER_RATE_PER_TRIP_PER_MILLE: 'rate_per_trip_per_mille_for_main_sub_cover'
  MAIN_SUB_COVER_SUM_INSURED_ACE_VARIANT: 'sum_insured_ace_for_main_sub_cover'
  OFFICE_PREMIUM_RATE_PER_MILLE_PER_ANNUM: 'office_premium_per_mille_pa'
  OFFICE_PREMIUM_RATE_PER_MILLE_PER_TRIP: 'office_premium_per_mille_per_trip'
  RATE_PER_TRIP_PER_MILLE: 'rate_per_trip_per_mille'
  RATING_SLAB_BAND: 'slab_'
  SUB_LIMIT_DEDUCTIBLE_AMOUNT: 'deductible_value_sublimit'
  SUB_LIMIT_PERIOD: 'period'
  SUM_INSURED_ACE_VARIANT: 'coalesce(sum_insuredace, sum_insured_ace)'
  TRIP_TYPE_FOR_INCONVENIENCE_COVER: 'trip_type_incov'
  TRIP_TYPE_FOR_TRIP_CALCULATION: 'trip_type_tripcal'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
