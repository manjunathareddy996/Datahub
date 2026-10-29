{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- Covers this view's 6 key slot(s) and its 17 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   COVERAGE_HKEY                      HUB_COVERAGE  (10 row(s) in the map)
--   PARTY_HKEY__POLICYHOLDER           HUB_PARTY / policyholder  (1 row(s) in the map)
--   POLICY_HKEY                        HUB_POLICY  (46 row(s) in the map)
--   PRODUCT_HKEY                       HUB_PRODUCT  (7 row(s) in the map)
--   RISK_OBJECT_HKEY                   HUB_RISK_OBJECT  (25 row(s) in the map)
--   RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK HUB_RISK_OBJECT / insured-traveller-risk  (21 row(s) in the map)
--   HASHDIFF_COMMON_BUSINESS_AUDIT     SAT_COMMON_BUSINESS_AUDIT payload 1 of 3 live here
--   HASHDIFF_COVERAGE_CONDITIONS       SAT_COVERAGE_CONDITIONS payload 1 of 1 live here
--   HASHDIFF_COVERAGE_DEFINITION       SAT_COVERAGE_DEFINITION payload 2 of 3 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 1 of 15 live here
--   HASHDIFF_POLICY_COVERAGE_SCHEDULE  SAT_POLICY_COVERAGE_SCHEDULE payload 4 of 8 live here
--   HASHDIFF_POLICY_DISCOUNT_LOADING_APPLIED SAT_POLICY_DISCOUNT_LOADING_APPLIED payload 6 of 7 live here
--   HASHDIFF_POLICY_HEADER             SAT_POLICY_HEADER payload 8 of 19 live here
--   HASHDIFF_POLICY_PREMIUM_SUMMARY    SAT_POLICY_PREMIUM_SUMMARY payload 2 of 7 live here
--   HASHDIFF_POLICY_SUM_INSURED_BREAKUP SAT_POLICY_SUM_INSURED_BREAKUP payload 1 of 3 live here
--   HASHDIFF_POLICY_TAX_HEAD           SAT_POLICY_TAX_HEAD payload 1 of 1 live here
--   HASHDIFF_PRODUCT_DEFINITION        SAT_PRODUCT_DEFINITION payload 2 of 4 live here
--   HASHDIFF_PRODUCT_RATING_STRUCTURE  SAT_PRODUCT_RATING_STRUCTURE payload 2 of 2 live here
--   HASHDIFF_PRODUCT_TERMS             SAT_PRODUCT_TERMS payload 1 of 1 live here
--   HASHDIFF_RISK_OBJECT_CORE          SAT_RISK_OBJECT_CORE payload 4 of 6 live here
--   HASHDIFF_RISK_OBJECT_VALUATION     SAT_RISK_OBJECT_VALUATION payload 3 of 3 live here
--   HASHDIFF_RISK_PERSON_INSURED       SAT_RISK_PERSON_INSURED payload 5 of 5 live here
--   HASHDIFF_RISK_PERSON_TRAVEL        SAT_RISK_PERSON_TRAVEL payload 3 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_ins_rskp_sp_pv'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  PARTY_HKEY__POLICYHOLDER: 'PARTY_NK__POLICYHOLDER'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK: 'RISK_OBJECT_NK__INSURED_TRAVELLER_RISK'
  HASHDIFF_COMMON_BUSINESS_AUDIT:
    is_hashdiff: true
    columns:
      - 'CREATED_BY_USER_REFERENCE'
      - 'CREATED_DATE'
      - 'SOURCE_APPLICATION_NAME'
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
      - 'APPLICABILITY_INDICATOR'
      - 'ITEM_CODE'
      - 'ITEM_TYPE'
      - 'PERCENTAGE_APPLIED'
      - 'RELATIVITY_APPLIED'
      - 'RISK_LOADING_TYPE'
  HASHDIFF_POLICY_HEADER:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_INDICATOR'
      - 'CURRENCY_CODE'
      - 'FIRST_YEAR_INDICATOR'
      - 'POLICYHOLDER_REFERENCE'
      - 'POLICY_CHANNEL_TYPE'
      - 'POLICY_REFERENCE_NUMBER'
      - 'POLICY_REMARKS'
      - 'POLICY_STATUS'
      - 'POLICY_SUB_STATUS'
      - 'POLICY_TERM'
      - 'POLICY_TYPE'
      - 'PREMIUM_FREQUENCY'
      - 'PREMIUM_PAYER_REFERENCE'
      - 'PRODUCT_REFERENCE'
      - 'RISK_END_TIME'
      - 'RISK_EXPIRY_DATE'
      - 'RISK_INCEPTION_DATE'
      - 'RISK_START_TIME'
      - 'SUM_INSURED_TOTAL'
  HASHDIFF_POLICY_PREMIUM_SUMMARY:
    is_hashdiff: true
    columns:
      - 'BASE_PREMIUM'
      - 'GROSS_PREMIUM'
      - 'LOADING_AMOUNT'
      - 'NET_PREMIUM'
      - 'PREMIUM_OUTSTANDING'
      - 'REFUND_AMOUNT'
      - 'TOTAL_PREMIUM_COLLECTED'
  HASHDIFF_POLICY_SUM_INSURED_BREAKUP:
    is_hashdiff: true
    columns:
      - 'SUM_INSURED_AMOUNT'
      - 'SUM_INSURED_BREAK_UP_DETAIL'
      - 'SUM_INSURED_HEAD'
  HASHDIFF_POLICY_TAX_HEAD:
    is_hashdiff: true
    columns:
      - 'TAX_AMOUNT'
      - 'TAX_HEAD_CODE'
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
  COVERAGE_BK: "nullif(trim(case when nullif(trim(cover_code),'') is not null then 'COV:' || nullif(trim(cover_code), '') end),'')"
  COVERAGE_NK: "'HUB_COVERAGE|' || (nullif(trim(case when nullif(trim(cover_code),'') is not null then 'COV:' || nullif(trim(cover_code), '') end),''))"
  PARTY_BK__POLICYHOLDER: "nullif(trim(case when nullif(trim(w2_policy_holder_code),'') is not null then nullif(trim(w2_policy_holder_code), '') end),'')"
  PARTY_NK__POLICYHOLDER: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(w2_policy_holder_code),'') is not null then nullif(trim(w2_policy_holder_code), '') end),''))"
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  PRODUCT_BK: "nullif(trim(case when nullif(trim(w3_product_code),'') is not null then 'PROD:' || nullif(trim(w3_product_code), '') end),'')"
  PRODUCT_NK: "'HUB_PRODUCT|' || (nullif(trim(case when nullif(trim(w3_product_code),'') is not null then 'PROD:' || nullif(trim(w3_product_code), '') end),''))"
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  RISK_OBJECT_BK__INSURED_TRAVELLER_RISK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK__INSURED_TRAVELLER_RISK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  AGE: 'cast(null as varchar)'
  AMOUNT_APPLIED: 'coalesce(premium_adjustment, travelling_companion_discount, auto_adjusted_amount, other_discount)'
  BASE_PREMIUM: 'cast(null as varchar)'
  CONDITION_DESCRIPTION: 'sub_condition1'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  COVERAGE_DESCRIPTION: 'cast(null as varchar)'
  COVERAGE_END_DATE: 'cover_expiry_date'
  COVERAGE_NAME: 'cover_name'
  COVERAGE_OPTED_INDICATOR: 'cast(null as varchar)'
  COVERAGE_REFERENCE: "coalesce(nullif(trim(cover_code), ''),'')"
  COVERAGE_SEQUENCE: "coalesce(nullif(trim(w1_pol_risk_id), ''),'')"
  COVERAGE_START_DATE: 'cover_inception_date'
  CO_INSURANCE_INDICATOR: 'cast(null as varchar)'
  CO_PAYMENT_PERCENTAGE: 'cast(null as varchar)'
  CREATED_BY_USER_REFERENCE: 'cast(null as varchar)'
  CREATED_DATE: 'cast(null as varchar)'
  CURRENCY_CODE: 'cast(null as varchar)'
  DATE_OF_BIRTH: 'cast(null as varchar)'
  DEDUCTIBLE_AMOUNT: 'cast(null as varchar)'
  DEPOSIT_PREMIUM_INDICATOR: 'minimum_deposit_premium_applicable'
  DESTINATION_COUNTRY: 'place_of_destination'
  EXPOSURE_QUANTITY: 'number_of_mandays'
  EXPOSURE_UNIT: 'unit'
  FIRST_NAME: 'cast(null as varchar)'
  FIRST_YEAR_INDICATOR: 'cast(null as varchar)'
  FREE_LOOK_PERIOD: 'free_cancellation_period'
  GENDER_CODE: 'cast(null as varchar)'
  GEOGRAPHICAL_ZONE: 'cast(null as varchar)'
  GROSS_PREMIUM: 'cast(null as varchar)'
  INSURED_MEMBER_NAME: 'coalesce(insured_name, insured_person_name)'
  INSURED_VALUE: 'risk_sum_insured_in_base_currency'
  ITEM_CODE: "nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || coalesce(nullif(trim(premium_adjustment_type), ''), '')), '#')"
  ITEM_TYPE: 'premium_adjustment_type'
  LAST_NAME: 'cast(null as varchar)'
  LIMIT_AMOUNT: 'limit'
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
  PERCENTAGE_APPLIED: 'plan_discount_percentage'
  PERIL_COVERED: 'nature_of_loss'
  POLICYHOLDER_REFERENCE: 'cast(null as varchar)'
  POLICY_CHANNEL_TYPE: 'source_of_business'
  POLICY_REFERENCE_NUMBER: 'policy_reference_number'
  POLICY_REMARKS: 'cast(null as varchar)'
  POLICY_STATUS: 'cast(null as varchar)'
  POLICY_SUB_STATUS: 'cast(null as varchar)'
  POLICY_TERM: 'policy_duration'
  POLICY_TYPE: 'coalesce(policy_type, typeofpolicy)'
  PREMIUM_FOR_COVERAGE: 'cover_premium_in_transaction_currency'
  PREMIUM_FREQUENCY: 'cast(null as varchar)'
  PREMIUM_OUTSTANDING: 'total_premium_due'
  PREMIUM_PAYER_REFERENCE: 'cast(null as varchar)'
  PRE_EXISTING_DISEASE_DESCRIPTION: 'ped_details'
  PRE_EXISTING_DISEASE_INDICATOR: 'ped'
  PRODUCT_CATEGORY: 'category_name'
  PRODUCT_NAME: 'master_plan_name'
  PRODUCT_REFERENCE: 'cast(null as varchar)'
  RATE_BASIS: 'mode_of_premium_calculation'
  REFUND_AMOUNT: 'cast(null as varchar)'
  RISK_CLASS_CODE: 'cast(null as varchar)'
  RISK_END_TIME: 'policy_expiry_time'
  RISK_EXPIRY_DATE: 'policy_expiry_date'
  RISK_INCEPTION_DATE: 'policy_inception_date'
  RISK_OBJECT_DESCRIPTION: 'coalesce(insuredinterest, insured_interest)'
  RISK_OBJECT_REFERENCE_NUMBER: 'cast(null as varchar)'
  RISK_OBJECT_TYPE: 'risk_type'
  RISK_START_TIME: 'policy_inception_time'
  SALUTATION: 'cast(null as varchar)'
  SMOKER_INDICATOR: 'do_you_smoke_or_consume_tobacco'
  SOURCE_APPLICATION_NAME: 'data_source'
  SUM_INSURED: 'cast(null as varchar)'
  SUM_INSURED_AMOUNT: 'cover_sum_insured_in_transaction_currency'
  SUM_INSURED_HEAD: "nullif(trim(w1_pol_risk_id), '') || '#' || nullif(trim(cover_code), '') || '#COVER_SI_TXN_CCY'"
  SUM_INSURED_TOTAL: 'cast(null as varchar)'
  TAX_AMOUNT: 'total_taxes'
  TAX_HEAD_CODE: "'TOTAL'"
  TOTAL_PREMIUM_COLLECTED: 'premium_collected'
  TRIP_DURATION: 'total_trip_duration_in_days'
  TRIP_END_DATE: 'cast(null as varchar)'
  TRIP_START_DATE: 'cast(null as varchar)'
  TRIP_TYPE: 'coalesce(trip_typeace, journey_typeace)'
  UIN: 'cast(null as varchar)'
  APPLICABILITY_INDICATOR: 'is_consumer_loading_applicable'
  RELATIVITY_APPLIED: 'journey_type_relativity'
  RISK_LOADING_TYPE: 'risk_load_type'
  SUM_INSURED_BREAK_UP_DETAIL: 'cast(null as varchar)'
  INSURED_VALUE_IN_SUM_INSURED_CURRENCY: 'sum_insured_in_si_currency'
  INSURED_VALUE_IN_TRANSACTION_CURRENCY: 'risk_sum_insured_in_transaction_currency'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
