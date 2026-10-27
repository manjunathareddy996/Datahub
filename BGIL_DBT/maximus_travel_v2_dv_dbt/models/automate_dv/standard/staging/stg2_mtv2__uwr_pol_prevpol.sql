{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PREVIOUS_POLICY_DETAILS
-- Covers this view's 2 key slot(s) and its 3 1:1 satellite target(s) in one pass,
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
--   POLICY_HKEY__PREVIOUS_POLICY       HUB_POLICY / previous-policy  (6 row(s) in the map)
--   PRODUCT_HKEY                       HUB_PRODUCT  (1 row(s) in the map)
--   HASHDIFF_POLICY_HEADER             SAT_POLICY_HEADER payload 4 of 19 live here
--   HASHDIFF_POLICY_PREMIUM_SUMMARY    SAT_POLICY_PREMIUM_SUMMARY payload 1 of 7 live here
--   HASHDIFF_PRODUCT_DEFINITION        SAT_PRODUCT_DEFINITION payload 1 of 4 live here

{%- set yaml_metadata -%}
source_model: 'stg_mtv2__uwr_pol_prevpol'
hashed_columns:
  POLICY_HKEY__PREVIOUS_POLICY: 'POLICY_NK__PREVIOUS_POLICY'
  PRODUCT_HKEY: 'PRODUCT_NK'
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
  HASHDIFF_PRODUCT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'LINE_OF_BUSINESS'
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_NAME'
      - 'UIN'
derived_columns:
  POLICY_BK__PREVIOUS_POLICY: "nullif(trim(case when coalesce(nullif(trim(policy_number),'')) is not null then nullif(trim(policy_number), '') end),'')"
  POLICY_NK__PREVIOUS_POLICY: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(policy_number),'')) is not null then nullif(trim(policy_number), '') end),''))"
  PRODUCT_BK: "nullif(trim(case when coalesce(nullif(trim(product_code),'')) is not null then 'PROD:' || nullif(trim(product_code), '') end),'')"
  PRODUCT_NK: "'HUB_PRODUCT|' || (nullif(trim(case when coalesce(nullif(trim(product_code),'')) is not null then 'PROD:' || nullif(trim(product_code), '') end),''))"
  BASE_PREMIUM: 'cast(null as varchar)'
  CO_INSURANCE_INDICATOR: 'cast(null as varchar)'
  CURRENCY_CODE: 'cast(null as varchar)'
  FIRST_YEAR_INDICATOR: 'cast(null as varchar)'
  GROSS_PREMIUM: 'total_premium'
  LINE_OF_BUSINESS: 'cast(null as varchar)'
  LOADING_AMOUNT: 'cast(null as varchar)'
  NET_PREMIUM: 'cast(null as varchar)'
  POLICYHOLDER_REFERENCE: 'cast(null as varchar)'
  POLICY_CHANNEL_TYPE: 'cast(null as varchar)'
  POLICY_REFERENCE_NUMBER: 'cast(null as varchar)'
  POLICY_REMARKS: 'cast(null as varchar)'
  POLICY_STATUS: 'cast(null as varchar)'
  POLICY_SUB_STATUS: 'cast(null as varchar)'
  POLICY_TERM: 'cast(null as varchar)'
  POLICY_TYPE: 'cast(null as varchar)'
  PREMIUM_FREQUENCY: 'cast(null as varchar)'
  PREMIUM_OUTSTANDING: 'cast(null as varchar)'
  PREMIUM_PAYER_REFERENCE: 'cast(null as varchar)'
  PRODUCT_CATEGORY: 'cast(null as varchar)'
  PRODUCT_NAME: 'product_name'
  PRODUCT_REFERENCE: 'product_code'
  REFUND_AMOUNT: 'cast(null as varchar)'
  RISK_END_TIME: 'cast(null as varchar)'
  RISK_EXPIRY_DATE: 'policy_expiry_date'
  RISK_INCEPTION_DATE: 'policy_inception_date'
  RISK_START_TIME: 'cast(null as varchar)'
  SUM_INSURED_TOTAL: 'sum_insured'
  TOTAL_PREMIUM_COLLECTED: 'cast(null as varchar)'
  UIN: 'cast(null as varchar)'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PREVIOUS_POLICY_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
