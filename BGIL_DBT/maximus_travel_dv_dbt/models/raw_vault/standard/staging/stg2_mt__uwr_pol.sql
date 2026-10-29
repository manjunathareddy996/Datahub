{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS
-- Covers this view's 6 key slot(s) and its 7 1:1 satellite target(s) in one pass,
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
--   ORG_UNIT_HKEY                      HUB_ORG_UNIT  (1 row(s) in the map)
--   PARTY_HKEY__AGENT                  HUB_PARTY / agent  (1 row(s) in the map)
--   PARTY_HKEY__POLICYHOLDER           HUB_PARTY / policyholder  (1 row(s) in the map)
--   POLICY_HKEY                        HUB_POLICY  (15 row(s) in the map)
--   PRODUCT_HKEY                       HUB_PRODUCT  (2 row(s) in the map)
--   QUOTE_HKEY                         HUB_QUOTE  (1 row(s) in the map)
--   HASHDIFF_ORG_UNIT_DEFINITION       SAT_ORG_UNIT_DEFINITION payload 1 of 2 live here
--   HASHDIFF_POLICY_HEADER             SAT_POLICY_HEADER payload 5 of 19 live here
--   HASHDIFF_POLICY_INTERMEDIARY_SPLIT SAT_POLICY_INTERMEDIARY_SPLIT payload 1 of 2 live here
--   HASHDIFF_POLICY_PREMIUM_SUMMARY    SAT_POLICY_PREMIUM_SUMMARY payload 2 of 7 live here
--   HASHDIFF_POLICY_TAX_BREAKUP        SAT_POLICY_TAX_BREAKUP payload 1 of 10 live here
--   HASHDIFF_POLICY_TAX_HEAD           SAT_POLICY_TAX_HEAD payload 1 of 1 live here
--   HASHDIFF_PRODUCT_DEFINITION        SAT_PRODUCT_DEFINITION payload 1 of 4 live here

{%- set yaml_metadata -%}
source_model: 'stg_mt__uwr_pol'
hashed_columns:
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY__AGENT: 'PARTY_NK__AGENT'
  PARTY_HKEY__POLICYHOLDER: 'PARTY_NK__POLICYHOLDER'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_ORG_UNIT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'COST_CENTRE_CODE'
      - 'ORG_UNIT_NAME'
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
  HASHDIFF_POLICY_INTERMEDIARY_SPLIT:
    is_hashdiff: true
    columns:
      - 'COMMISSION_AMOUNT'
      - 'INTERMEDIARY_REFERENCE'
      - 'SUB_IMD_CODE'
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
  HASHDIFF_POLICY_TAX_BREAKUP:
    is_hashdiff: true
    columns:
      - 'CESS_AMOUNT'
      - 'CGST_AMOUNT'
      - 'GST_BIFURCATION'
      - 'GST_TDS_AMOUNT'
      - 'GST_TYPE'
      - 'IGST_AMOUNT'
      - 'SGST_AMOUNT'
      - 'STAMP_DUTY_AMOUNT'
      - 'STAMP_DUTY_RECEIPT_NUMBER'
      - 'TOTAL_TAX_AMOUNT'
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
derived_columns:
  ORG_UNIT_BK: "nullif(trim(case when nullif(trim(policy_branch_name),'') is not null then 'ORGUNIT:' || md5(upper(trim(nullif(trim(policy_branch_name), '')))) end),'')"
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || (nullif(trim(case when nullif(trim(policy_branch_name),'') is not null then 'ORGUNIT:' || md5(upper(trim(nullif(trim(policy_branch_name), '')))) end),''))"
  PARTY_BK__AGENT: "nullif(trim(case when nullif(trim(agent_code),'') is not null then 'AGENT:' || nullif(trim(agent_code), '') end),'')"
  PARTY_NK__AGENT: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(agent_code),'') is not null then 'AGENT:' || nullif(trim(agent_code), '') end),''))"
  PARTY_BK__POLICYHOLDER: "nullif(trim(case when nullif(trim(policy_holder_code),'') is not null then nullif(trim(policy_holder_code), '') end),'')"
  PARTY_NK__POLICYHOLDER: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(policy_holder_code),'') is not null then nullif(trim(policy_holder_code), '') end),''))"
  POLICY_BK: "nullif(trim(case when nullif(trim(policy_number),'') is not null then nullif(trim(policy_number), '') end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when nullif(trim(policy_number),'') is not null then nullif(trim(policy_number), '') end),''))"
  PRODUCT_BK: "nullif(trim(case when nullif(trim(product_code),'') is not null then 'PROD:' || nullif(trim(product_code), '') end),'')"
  PRODUCT_NK: "'HUB_PRODUCT|' || (nullif(trim(case when nullif(trim(product_code),'') is not null then 'PROD:' || nullif(trim(product_code), '') end),''))"
  QUOTE_BK: "nullif(trim(case when nullif(trim(quotation_number),'') is not null then nullif(trim(quotation_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when nullif(trim(quotation_number),'') is not null then nullif(trim(quotation_number), '') end),''))"
  BASE_PREMIUM: 'cast(null as varchar)'
  CESS_AMOUNT: 'cast(null as varchar)'
  CGST_AMOUNT: 'cast(null as varchar)'
  COMMISSION_AMOUNT: 'commision'
  COST_CENTRE_CODE: 'cast(null as varchar)'
  CO_INSURANCE_INDICATOR: 'cast(null as varchar)'
  CURRENCY_CODE: 'cast(null as varchar)'
  FIRST_YEAR_INDICATOR: 'cast(null as varchar)'
  GROSS_PREMIUM: 'total_premium'
  IGST_AMOUNT: 'cast(null as varchar)'
  INTERMEDIARY_REFERENCE: "coalesce('AGENT:' || nullif(trim(agent_code), ''),'')"
  LINE_OF_BUSINESS: 'cast(null as varchar)'
  LOADING_AMOUNT: 'cast(null as varchar)'
  NET_PREMIUM: 'net_premium'
  ORG_UNIT_NAME: 'policy_branch_name'
  POLICYHOLDER_REFERENCE: 'cast(null as varchar)'
  POLICY_CHANNEL_TYPE: 'cast(null as varchar)'
  POLICY_REFERENCE_NUMBER: 'cast(null as varchar)'
  POLICY_REMARKS: 'cast(null as varchar)'
  POLICY_STATUS: 'policy_status'
  POLICY_SUB_STATUS: 'cast(null as varchar)'
  POLICY_TERM: 'policy_duration'
  POLICY_TYPE: 'cast(null as varchar)'
  PREMIUM_FREQUENCY: 'payment_frequency'
  PREMIUM_OUTSTANDING: 'cast(null as varchar)'
  PREMIUM_PAYER_REFERENCE: 'cast(null as varchar)'
  PRODUCT_CATEGORY: 'cast(null as varchar)'
  PRODUCT_NAME: 'product_name'
  PRODUCT_REFERENCE: 'cast(null as varchar)'
  REFUND_AMOUNT: 'cast(null as varchar)'
  RISK_END_TIME: 'cast(null as varchar)'
  RISK_EXPIRY_DATE: 'policy_expiry_date'
  RISK_INCEPTION_DATE: 'policy_inception_date'
  RISK_START_TIME: 'cast(null as varchar)'
  SGST_AMOUNT: 'cast(null as varchar)'
  STAMP_DUTY_AMOUNT: 'stamp_duty'
  SUB_IMD_CODE: 'cast(null as varchar)'
  SUM_INSURED_TOTAL: 'cast(null as varchar)'
  TAX_AMOUNT: 'gst'
  TAX_HEAD_CODE: "'GST'"
  TOTAL_PREMIUM_COLLECTED: 'cast(null as varchar)'
  UIN: 'cast(null as varchar)'
  GST_BIFURCATION: 'cast(null as varchar)'
  GST_TDS_AMOUNT: 'cast(null as varchar)'
  GST_TYPE: 'cast(null as varchar)'
  STAMP_DUTY_RECEIPT_NUMBER: 'cast(null as varchar)'
  TOTAL_TAX_AMOUNT: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
