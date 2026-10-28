{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- Covers this view's 2 key slot(s) and its 4 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mtv2_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   POLICY_HKEY                        HUB_POLICY  (71 row(s) in the map)
--   RISK_OBJECT_HKEY                   HUB_RISK_OBJECT  (12 row(s) in the map)
--   HASHDIFF_POLICY_COVERAGE_SCHEDULE  SAT_POLICY_COVERAGE_SCHEDULE payload 1 of 8 live here
--   HASHDIFF_POLICY_DISCOUNT_LOADING_APPLIED SAT_POLICY_DISCOUNT_LOADING_APPLIED payload 1 of 3 live here
--   HASHDIFF_POLICY_SUM_INSURED_BREAKUP SAT_POLICY_SUM_INSURED_BREAKUP payload 1 of 1 live here
--   HASHDIFF_RISK_PERSON_TRAVEL        SAT_RISK_PERSON_TRAVEL payload 3 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_polp_msp_msd_prop_pv'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF_POLICY_COVERAGE_SCHEDULE:
    is_hashdiff: true
    columns:
      - 'COVERAGE_END_DATE'
      - 'COVERAGE_OPTED_INDICATOR'
      - 'COVERAGE_REFERENCE'
      - 'COVERAGE_SEQUENCE'
      - 'COVERAGE_START_DATE'
      - 'CO_PAYMENT_PERCENTAGE'
      - 'DEDUCTIBLE_AMOUNT'
      - 'LIMIT_AMOUNT'
      - 'PREMIUM_FOR_COVERAGE'
      - 'SUM_INSURED'
  HASHDIFF_POLICY_DISCOUNT_LOADING_APPLIED:
    is_hashdiff: true
    columns:
      - 'AMOUNT_APPLIED'
      - 'ITEM_CODE'
      - 'ITEM_TYPE'
      - 'PERCENTAGE_APPLIED'
  HASHDIFF_POLICY_SUM_INSURED_BREAKUP:
    is_hashdiff: true
    columns:
      - 'SUM_INSURED_AMOUNT'
      - 'SUM_INSURED_HEAD'
  HASHDIFF_RISK_PERSON_TRAVEL:
    is_hashdiff: true
    columns:
      - 'DESTINATION_COUNTRY'
      - 'GEOGRAPHICAL_ZONE'
      - 'TRIP_DURATION'
      - 'TRIP_END_DATE'
      - 'TRIP_START_DATE'
      - 'TRIP_TYPE'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(pnr),''), nullif(trim(trip_no),'')) is not null then 'TRIP:' || coalesce(nullif(trim(pnr), ''), nullif(trim(trip_no), '')) end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(pnr),''), nullif(trim(trip_no),'')) is not null then 'TRIP:' || coalesce(nullif(trim(pnr), ''), nullif(trim(trip_no), '')) end),''))"
  AMOUNT_APPLIED: 'coalesce(loading_ace, loading_ace_for_main_sub_cover)'
  COVERAGE_END_DATE: 'cast(null as varchar)'
  COVERAGE_OPTED_INDICATOR: 'cast(null as varchar)'
  COVERAGE_REFERENCE: "coalesce(nullif(trim(sublimit_name), ''),'')"
  COVERAGE_SEQUENCE: "'1'"
  COVERAGE_START_DATE: 'cast(null as varchar)'
  CO_PAYMENT_PERCENTAGE: 'cast(null as varchar)'
  DEDUCTIBLE_AMOUNT: 'deductible_value_sublimit'
  DESTINATION_COUNTRY: 'destination_country'
  GEOGRAPHICAL_ZONE: 'geographical_coverage'
  ITEM_CODE: "coalesce(nullif(trim(coalesce(nullif(trim(sublimit_name), ''), '') || '#' || 'LOADING_ACE'), '#LOADING_ACE'),'')"
  ITEM_TYPE: 'cast(null as varchar)'
  LIMIT_AMOUNT: 'cast(null as varchar)'
  PERCENTAGE_APPLIED: 'cast(null as varchar)'
  PREMIUM_FOR_COVERAGE: 'cast(null as varchar)'
  SUM_INSURED: 'cast(null as varchar)'
  SUM_INSURED_AMOUNT: 'coalesce(benefit_amount, limit_sum_insured, sum_insured, sum_insured_ace, sum_insured_ace_for_main_sub_cover, sum_insuredace)'
  SUM_INSURED_HEAD: "coalesce(nullif(trim(coalesce(nullif(trim(sublimit_name), ''), '') || '#' || 'BENEFIT_AMOUNT'), '#BENEFIT_AMOUNT'),'')"
  TRIP_DURATION: 'cast(null as varchar)'
  TRIP_END_DATE: 'cast(null as varchar)'
  TRIP_START_DATE: 'departure_date'
  TRIP_TYPE: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
