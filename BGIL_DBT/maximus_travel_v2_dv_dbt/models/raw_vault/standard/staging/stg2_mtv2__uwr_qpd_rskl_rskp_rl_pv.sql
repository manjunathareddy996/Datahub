{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
-- Covers this view's 6 key slot(s) and its 13 1:1 satellite target(s) in one pass,
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
--   COVERAGE_HKEY                      HUB_COVERAGE  (10 row(s) in the map)
--   PARTY_HKEY__POLICYHOLDER           HUB_PARTY / policyholder  (1 row(s) in the map)
--   PRODUCT_HKEY                       HUB_PRODUCT  (7 row(s) in the map)
--   QUOTE_HKEY                         HUB_QUOTE  (45 row(s) in the map)
--   RISK_OBJECT_HKEY                   HUB_RISK_OBJECT  (25 row(s) in the map)
--   RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK HUB_RISK_OBJECT / quoted-traveller-risk  (21 row(s) in the map)
--   HASHDIFF_COVERAGE_CONDITIONS       SAT_COVERAGE_CONDITIONS payload 1 of 1 live here
--   HASHDIFF_COVERAGE_DEFINITION       SAT_COVERAGE_DEFINITION payload 2 of 3 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 1 of 15 live here
--   HASHDIFF_PRODUCT_DEFINITION        SAT_PRODUCT_DEFINITION payload 2 of 4 live here
--   HASHDIFF_PRODUCT_RATING_STRUCTURE  SAT_PRODUCT_RATING_STRUCTURE payload 2 of 2 live here
--   HASHDIFF_PRODUCT_TERMS             SAT_PRODUCT_TERMS payload 1 of 1 live here
--   HASHDIFF_QUOTE_HEADER              SAT_QUOTE_HEADER payload 3 of 8 live here
--   HASHDIFF_QUOTE_RATING              SAT_QUOTE_RATING payload 1 of 6 live here
--   HASHDIFF_QUOTE_RATING_INPUT        SAT_QUOTE_RATING_INPUT payload 3 of 3 live here
--   HASHDIFF_RISK_OBJECT_CORE          SAT_RISK_OBJECT_CORE payload 4 of 6 live here
--   HASHDIFF_RISK_OBJECT_VALUATION     SAT_RISK_OBJECT_VALUATION payload 3 of 3 live here
--   HASHDIFF_RISK_PERSON_INSURED       SAT_RISK_PERSON_INSURED payload 5 of 5 live here
--   HASHDIFF_RISK_PERSON_TRAVEL        SAT_RISK_PERSON_TRAVEL payload 3 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_rskl_rskp_rl_pv'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  PARTY_HKEY__POLICYHOLDER: 'PARTY_NK__POLICYHOLDER'
  PRODUCT_HKEY: 'PRODUCT_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK: 'RISK_OBJECT_NK__QUOTED_TRAVELLER_RISK'
  HASHDIFF_COVERAGE_CONDITIONS:
    is_hashdiff: true
    columns:
      - 'CONDITION_DESCRIPTION'
  HASHDIFF_COVERAGE_DEFINITION:
    is_hashdiff: true
    columns:
      - 'COVERAGE_DESCRIPTION'
      - 'COVERAGE_NAME'
      - 'PERIL_COVERED'
  HASHDIFF_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'COUNTRY_OF_BIRTH'
      - 'COUNTRY_OF_RESIDENCE'
      - 'DATE_OF_BIRTH'
      - 'FIRST_NAME'
      - 'GENDER_CODE'
      - 'LAST_NAME'
      - 'MIDDLE_NAME'
      - 'NATIONALITY'
      - 'PARTY_FULL_NAME'
      - 'PARTY_LEGAL_NAME'
      - 'PARTY_STATUS'
      - 'PARTY_SUB_TYPE_CODE'
      - 'PARTY_TYPE_CODE'
      - 'SALUTATION'
  HASHDIFF_PRODUCT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'LINE_OF_BUSINESS'
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_NAME'
      - 'UIN'
  HASHDIFF_PRODUCT_RATING_STRUCTURE:
    is_hashdiff: true
    columns:
      - 'DEPOSIT_PREMIUM_INDICATOR'
      - 'RATE_BASIS'
  HASHDIFF_PRODUCT_TERMS:
    is_hashdiff: true
    columns:
      - 'FREE_LOOK_PERIOD'
  HASHDIFF_QUOTE_HEADER:
    is_hashdiff: true
    columns:
      - 'LEAD_REFERENCE'
      - 'PROSPECT_REFERENCE'
      - 'QUOTE_REMARKS'
      - 'QUOTE_SOURCE'
      - 'QUOTE_STATUS'
      - 'REQUESTED_COVER_START_DATE'
      - 'REQUESTED_POLICY_TERM'
      - 'REQUESTED_SUM_INSURED'
  HASHDIFF_QUOTE_RATING:
    is_hashdiff: true
    columns:
      - 'BASE_PREMIUM'
      - 'DISCOUNT_AMOUNT'
      - 'GROSS_PREMIUM'
      - 'LOADING_AMOUNT'
      - 'NET_PREMIUM'
      - 'PREMIUM_FREQUENCY'
  HASHDIFF_QUOTE_RATING_INPUT:
    is_hashdiff: true
    columns:
      - 'FACTOR_CODE'
      - 'FACTOR_VALUE'
      - 'PREMIUM_IMPACT'
      - 'RELATIVITY_APPLIED'
  HASHDIFF_RISK_OBJECT_CORE:
    is_hashdiff: true
    columns:
      - 'EXPOSURE_QUANTITY'
      - 'EXPOSURE_UNIT'
      - 'RISK_CLASS_CODE'
      - 'RISK_OBJECT_DESCRIPTION'
      - 'RISK_OBJECT_REFERENCE_NUMBER'
      - 'RISK_OBJECT_TYPE'
  HASHDIFF_RISK_OBJECT_VALUATION:
    is_hashdiff: true
    columns:
      - 'INSURED_VALUE'
      - 'INSURED_VALUE_IN_SUM_INSURED_CURRENCY'
      - 'INSURED_VALUE_IN_TRANSACTION_CURRENCY'
  HASHDIFF_RISK_PERSON_INSURED:
    is_hashdiff: true
    columns:
      - 'INSURED_MEMBER_NAME'
      - 'MEMBER_TYPE'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'PRE_EXISTING_DISEASE_INDICATOR'
      - 'SMOKER_INDICATOR'
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
  COVERAGE_BK: "nullif(trim(case when coalesce(nullif(trim(cover_code),'')) is not null then 'COV:' || nullif(trim(cover_code), '') end),'')"
  COVERAGE_NK: "'HUB_COVERAGE|' || (nullif(trim(case when coalesce(nullif(trim(cover_code),'')) is not null then 'COV:' || nullif(trim(cover_code), '') end),''))"
  PARTY_BK__POLICYHOLDER: "nullif(trim(case when coalesce(nullif(trim(w2_policy_holder_code),'')) is not null then nullif(trim(w2_policy_holder_code), '') end),'')"
  PARTY_NK__POLICYHOLDER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w2_policy_holder_code),'')) is not null then nullif(trim(w2_policy_holder_code), '') end),''))"
  PRODUCT_BK: "nullif(trim(case when coalesce(nullif(trim(w3_product_code),'')) is not null then 'PROD:' || nullif(trim(w3_product_code), '') end),'')"
  PRODUCT_NK: "'HUB_PRODUCT|' || (nullif(trim(case when coalesce(nullif(trim(w3_product_code),'')) is not null then 'PROD:' || nullif(trim(w3_product_code), '') end),''))"
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK__QUOTED_TRAVELLER_RISK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  AGE: 'cast(null as varchar)'
  BASE_PREMIUM: 'premium'
  CONDITION_DESCRIPTION: 'sub_condition1'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  COVERAGE_DESCRIPTION: 'cast(null as varchar)'
  COVERAGE_NAME: 'cover_name'
  DATE_OF_BIRTH: 'cast(null as varchar)'
  DEPOSIT_PREMIUM_INDICATOR: 'minimum_deposit_premium_applicable'
  DESTINATION_COUNTRY: 'place_of_destination'
  DISCOUNT_AMOUNT: 'cast(null as varchar)'
  EXPOSURE_QUANTITY: 'number_of_mandays'
  EXPOSURE_UNIT: 'unit'
  FACTOR_CODE: "coalesce(nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || 'RATE_PERCENTAGE'), '#RATE_PERCENTAGE'),'')"
  FACTOR_VALUE: 'coalesce(rate_percentage, is_consumer_loading_applicable, plan_discount_percentage)'
  FIRST_NAME: 'cast(null as varchar)'
  FREE_LOOK_PERIOD: 'free_cancellation_period'
  GENDER_CODE: 'cast(null as varchar)'
  GEOGRAPHICAL_ZONE: 'cast(null as varchar)'
  GROSS_PREMIUM: 'cast(null as varchar)'
  INSURED_MEMBER_NAME: 'coalesce(insured_name, insured_person_name)'
  INSURED_VALUE: 'risk_sum_insured_in_base_currency'
  LAST_NAME: 'cast(null as varchar)'
  LEAD_REFERENCE: 'cast(null as varchar)'
  LINE_OF_BUSINESS: 'cast(null as varchar)'
  LOADING_AMOUNT: 'cast(null as varchar)'
  MEMBER_TYPE: 'member_type'
  MIDDLE_NAME: 'cast(null as varchar)'
  NATIONALITY: 'cast(null as varchar)'
  NET_PREMIUM: 'cast(null as varchar)'
  PARTY_FULL_NAME: 'cast(null as varchar)'
  PARTY_LEGAL_NAME: 'cast(null as varchar)'
  PARTY_STATUS: 'cast(null as varchar)'
  PARTY_SUB_TYPE_CODE: 'cast(null as varchar)'
  PARTY_TYPE_CODE: 'type_of_client'
  PERIL_COVERED: 'nature_of_loss'
  PREMIUM_FREQUENCY: 'cast(null as varchar)'
  PREMIUM_IMPACT: 'coalesce(auto_adjusted_amount, other_discount)'
  PRE_EXISTING_DISEASE_DESCRIPTION: 'ped_details'
  PRE_EXISTING_DISEASE_INDICATOR: 'ped'
  PRODUCT_CATEGORY: 'category_name'
  PRODUCT_NAME: 'master_plan_name'
  PROSPECT_REFERENCE: 'cast(null as varchar)'
  QUOTE_REMARKS: 'cast(null as varchar)'
  QUOTE_SOURCE: 'data_source'
  QUOTE_STATUS: 'cast(null as varchar)'
  RATE_BASIS: 'mode_of_premium_calculation'
  RELATIVITY_APPLIED: 'journey_type_relativity'
  REQUESTED_COVER_START_DATE: 'policy_inception_date'
  REQUESTED_POLICY_TERM: 'policy_duration'
  REQUESTED_SUM_INSURED: 'cast(null as varchar)'
  RISK_CLASS_CODE: 'cast(null as varchar)'
  RISK_OBJECT_DESCRIPTION: 'coalesce(insuredinterest, insured_interest)'
  RISK_OBJECT_REFERENCE_NUMBER: 'cast(null as varchar)'
  RISK_OBJECT_TYPE: 'risk_type'
  SALUTATION: 'cast(null as varchar)'
  SMOKER_INDICATOR: 'do_you_smoke_or_consume_tobacco'
  TRIP_DURATION: 'total_trip_duration_in_days'
  TRIP_END_DATE: 'cast(null as varchar)'
  TRIP_START_DATE: 'cast(null as varchar)'
  TRIP_TYPE: 'coalesce(trip_typeace, journey_typeace)'
  UIN: 'cast(null as varchar)'
  INSURED_VALUE_IN_SUM_INSURED_CURRENCY: 'sum_insured_in_si_currency'
  INSURED_VALUE_IN_TRANSACTION_CURRENCY: 'risk_sum_insured_in_transaction_currency'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
