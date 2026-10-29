{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
-- Covers this view's 16 key slot(s) and its 14 1:1 satellite target(s) in one pass,
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
--   ASSESSMENT_HKEY                    HUB_ASSESSMENT  (1 row(s) in the map)
--   DISTRIBUTION_CHANNEL_HKEY          HUB_DISTRIBUTION_CHANNEL  (2 row(s) in the map)
--   DOCUMENT_HKEY                      HUB_DOCUMENT  (1 row(s) in the map)
--   DOCUMENT_HKEY__PREVIOUS_CERTIFICATE HUB_DOCUMENT / previous-certificate  (1 row(s) in the map)
--   FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM HUB_FINANCIAL_TRANSACTION / quote-premium  (7 row(s) in the map)
--   ORG_UNIT_HKEY                      HUB_ORG_UNIT  (2 row(s) in the map)
--   PARTY_HKEY__POLICYHOLDER           HUB_PARTY / policyholder  (2 row(s) in the map)
--   PARTY_HKEY__RELATIONSHIP_MANAGER   HUB_PARTY / relationship-manager  (1 row(s) in the map)
--   PARTY_HKEY__SUB_INTERMEDIARY       HUB_PARTY / sub-intermediary  (1 row(s) in the map)
--   PARTY_ROLE_HKEY__POLICYHOLDER      LNK_PARTY_ROLE / policyholder  LINK
--   PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER LNK_PARTY_ROLE / relationship-manager  LINK
--   POLICY_HKEY__MASTER_POLICY         HUB_POLICY / master-policy  (2 row(s) in the map)
--   POLICY_HKEY__PREVIOUS_POLICY       HUB_POLICY / previous-policy  (2 row(s) in the map)
--   POLICY_HKEY__PREVIOUS_POLICY_PORTABILITY HUB_POLICY / previous-policy-portability  (1 row(s) in the map)
--   PRODUCT_HKEY                       HUB_PRODUCT  (2 row(s) in the map)
--   QUOTE_HKEY                         HUB_QUOTE  (101 row(s) in the map)
--   HASHDIFF_CHANNEL_DEFINITION        SAT_CHANNEL_DEFINITION payload 1 of 5 live here
--   HASHDIFF_COMMON_COMMUNICATION_PREFERENCE SAT_COMMON_COMMUNICATION_PREFERENCE payload 1 of 4 live here
--   HASHDIFF_COMMON_MONETARY_CONTEXT   SAT_COMMON_MONETARY_CONTEXT payload 3 of 4 live here
--   HASHDIFF_DOCUMENT_DEFINITION       SAT_DOCUMENT_DEFINITION payload 1 of 13 live here
--   HASHDIFF_FINTXN_HEADER             SAT_FINTXN_HEADER payload 1 of 7 live here
--   HASHDIFF_FINTXN_PREMIUM            SAT_FINTXN_PREMIUM payload 1 of 1 live here
--   HASHDIFF_FIN_RECEIPT               SAT_FIN_RECEIPT payload 1 of 6 live here
--   HASHDIFF_LNK_ROLE_CUSTOMER         SAT_LNK_ROLE_CUSTOMER payload 1 of 3 live here
--   HASHDIFF_LNK_ROLE_EMPLOYEE         SAT_LNK_ROLE_EMPLOYEE payload 1 of 1 live here
--   HASHDIFF_ORG_UNIT_DEFINITION       SAT_ORG_UNIT_DEFINITION payload 1 of 2 live here
--   HASHDIFF_POLICY_HEADER             SAT_POLICY_HEADER payload 2 of 19 live here
--   HASHDIFF_PRODUCT_DEFINITION        SAT_PRODUCT_DEFINITION payload 2 of 4 live here
--   HASHDIFF_QUOTE_HEADER              SAT_QUOTE_HEADER payload 7 of 8 live here
--   HASHDIFF_QUOTE_RATING              SAT_QUOTE_RATING payload 5 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_qpd_polp_rl_pv'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  DOCUMENT_HKEY__PREVIOUS_CERTIFICATE: 'DOCUMENT_NK__PREVIOUS_CERTIFICATE'
  FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM: 'FINANCIAL_TRANSACTION_NK__QUOTE_PREMIUM'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY__POLICYHOLDER: 'PARTY_NK__POLICYHOLDER'
  PARTY_HKEY__RELATIONSHIP_MANAGER: 'PARTY_NK__RELATIONSHIP_MANAGER'
  PARTY_HKEY__SUB_INTERMEDIARY: 'PARTY_NK__SUB_INTERMEDIARY'
  PARTY_ROLE_HKEY__POLICYHOLDER: 'PARTY_ROLE_NK__POLICYHOLDER'
  PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER: 'PARTY_ROLE_NK__RELATIONSHIP_MANAGER'
  POLICY_HKEY__MASTER_POLICY: 'POLICY_NK__MASTER_POLICY'
  POLICY_HKEY__PREVIOUS_POLICY: 'POLICY_NK__PREVIOUS_POLICY'
  POLICY_HKEY__PREVIOUS_POLICY_PORTABILITY: 'POLICY_NK__PREVIOUS_POLICY_PORTABILITY'
  PRODUCT_HKEY: 'PRODUCT_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_CHANNEL_DEFINITION:
    is_hashdiff: true
    columns:
      - 'CHANNEL_NAME'
      - 'CHANNEL_REMARKS'
      - 'CHANNEL_TYPE'
      - 'SUB_CHANNEL_CODE'
      - 'SUB_CHANNEL_EFFECTIVE_DATE'
  HASHDIFF_COMMON_COMMUNICATION_PREFERENCE:
    is_hashdiff: true
    columns:
      - 'GO_GREEN_OPT_IN_INDICATOR'
      - 'PREFERRED_CHANNEL_CODE'
      - 'PREFERRED_LANGUAGE_CODE'
      - 'SMS_OPT_IN_INDICATOR'
  HASHDIFF_COMMON_MONETARY_CONTEXT:
    is_hashdiff: true
    columns:
      - 'BASE_CURRENCY_CODE'
      - 'BASE_CURRENCY_EXCHANGE_RATE'
      - 'CURRENCY_CODE'
      - 'EXCHANGE_RATE'
  HASHDIFF_DOCUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'COURIER_NAME'
      - 'DOCUMENT_DETAILS_TEXT'
      - 'DOCUMENT_NAME'
      - 'DOCUMENT_REFERENCE_NUMBER'
      - 'DOCUMENT_TYPE'
      - 'ISSUE_DATE'
      - 'PROOF_OF_DELIVERY_NUMBER'
      - 'RECEIVED_DATE'
      - 'RECORD_VALID_INDICATOR'
      - 'SENDER_NAME'
      - 'SOURCE_CHANNEL'
      - 'SPECIAL_ENCLOSURES_DETAILS'
      - 'SPECIAL_ENCLOSURES_INDICATOR'
  HASHDIFF_FINTXN_HEADER:
    is_hashdiff: true
    columns:
      - 'ORG_UNIT_CODE'
      - 'SOURCE_REFERENCE_NUMBER'
      - 'SOURCE_REFERENCE_TYPE'
      - 'TRANSACTION_CHANNEL'
      - 'TRANSACTION_DATE'
      - 'TRANSACTION_NUMBER'
      - 'TRANSACTION_TYPE'
  HASHDIFF_FINTXN_PREMIUM:
    is_hashdiff: true
    columns:
      - 'COLLECTION_MODE'
  HASHDIFF_FIN_RECEIPT:
    is_hashdiff: true
    columns:
      - 'AMOUNT_RECEIVED'
      - 'PAYMENT_GATEWAY_REFERENCE'
      - 'REALISATION_DATE'
      - 'RECEIPT_DATE'
      - 'RECEIPT_NUMBER'
      - 'RECEIPT_TYPE'
  HASHDIFF_LNK_ROLE_CUSTOMER:
    is_hashdiff: true
    columns:
      - 'CONSENT_FOR_DATA_SHARING_INDICATOR'
      - 'PREFERRED_CUSTOMER_INDICATOR'
      - 'VIP_INDICATOR'
  HASHDIFF_LNK_ROLE_EMPLOYEE:
    is_hashdiff: true
    columns:
      - 'EMPLOYEE_CODE'
  HASHDIFF_ORG_UNIT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'COST_CENTRE_CODE'
      - 'ORG_UNIT_NAME'
  HASHDIFF_POLICY_HEADER:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_INDICATOR'
      - 'CURRENCY_CODE__SAT_POLICY_HEADER'
      - 'FIRST_YEAR_INDICATOR'
      - 'POLICYHOLDER_REFERENCE'
      - 'POLICY_CHANNEL_TYPE'
      - 'POLICY_REFERENCE_NUMBER'
      - 'POLICY_REMARKS'
      - 'POLICY_STATUS'
      - 'POLICY_SUB_STATUS'
      - 'POLICY_TERM'
      - 'POLICY_TYPE'
      - 'PREMIUM_FREQUENCY__SAT_POLICY_HEADER'
      - 'PREMIUM_PAYER_REFERENCE'
      - 'PRODUCT_REFERENCE'
      - 'RISK_END_TIME'
      - 'RISK_EXPIRY_DATE'
      - 'RISK_INCEPTION_DATE'
      - 'RISK_START_TIME'
      - 'SUM_INSURED_TOTAL'
  HASHDIFF_PRODUCT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'LINE_OF_BUSINESS'
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_NAME'
      - 'UIN'
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
derived_columns:
  ASSESSMENT_BK: "nullif(trim(case when nullif(trim(bagic_scrutiny_number),'') is not null then 'SCRUTINY:' || nullif(trim(bagic_scrutiny_number), '') end),'')"
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || (nullif(trim(case when nullif(trim(bagic_scrutiny_number),'') is not null then 'SCRUTINY:' || nullif(trim(bagic_scrutiny_number), '') end),''))"
  DISTRIBUTION_CHANNEL_BK: "nullif(trim(case when nullif(trim(imd_code),'') is not null then nullif(trim(imd_code), '') end),'')"
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (nullif(trim(case when nullif(trim(imd_code),'') is not null then nullif(trim(imd_code), '') end),''))"
  DOCUMENT_BK: "nullif(trim(case when nullif(trim(coi_number),'') is not null then 'COI:' || nullif(trim(coi_number), '') end),'')"
  DOCUMENT_NK: "'HUB_DOCUMENT|' || (nullif(trim(case when nullif(trim(coi_number),'') is not null then 'COI:' || nullif(trim(coi_number), '') end),''))"
  DOCUMENT_BK__PREVIOUS_CERTIFICATE: "nullif(trim(case when nullif(trim(old_coi_number),'') is not null then 'COI:' || nullif(trim(old_coi_number), '') end),'')"
  DOCUMENT_NK__PREVIOUS_CERTIFICATE: "'HUB_DOCUMENT|' || (nullif(trim(case when nullif(trim(old_coi_number),'') is not null then 'COI:' || nullif(trim(old_coi_number), '') end),''))"
  FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM: "nullif(trim(case when nullif(trim(w0_policy_quote_number),'') is not null then 'QUOTEPREM:' || nullif(trim(w0_policy_quote_number), '') end),'')"
  FINANCIAL_TRANSACTION_NK__QUOTE_PREMIUM: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when nullif(trim(w0_policy_quote_number),'') is not null then 'QUOTEPREM:' || nullif(trim(w0_policy_quote_number), '') end),''))"
  ORG_UNIT_BK: "nullif(trim(case when nullif(trim(branch_code),'') is not null then nullif(trim(branch_code), '') end),'')"
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || (nullif(trim(case when nullif(trim(branch_code),'') is not null then nullif(trim(branch_code), '') end),''))"
  PARTY_BK__POLICYHOLDER: "nullif(trim(case when nullif(trim(w2_policy_holder_code),'') is not null then nullif(trim(w2_policy_holder_code), '') end),'')"
  PARTY_NK__POLICYHOLDER: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(w2_policy_holder_code),'') is not null then nullif(trim(w2_policy_holder_code), '') end),''))"
  PARTY_BK__RELATIONSHIP_MANAGER: "nullif(trim(case when nullif(trim(bagic_rm_ecode),'') is not null then 'EMP:' || nullif(trim(bagic_rm_ecode), '') end),'')"
  PARTY_NK__RELATIONSHIP_MANAGER: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(bagic_rm_ecode),'') is not null then 'EMP:' || nullif(trim(bagic_rm_ecode), '') end),''))"
  PARTY_BK__SUB_INTERMEDIARY: "nullif(trim(case when nullif(trim(sub_imd_code),'') is not null then 'IMD:' || nullif(trim(sub_imd_code), '') end),'')"
  PARTY_NK__SUB_INTERMEDIARY: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(sub_imd_code),'') is not null then 'IMD:' || nullif(trim(sub_imd_code), '') end),''))"
  PARTY_ROLE_BK__POLICYHOLDER: "coalesce(nullif(trim(case when nullif(trim(w2_policy_holder_code),'') is not null then nullif(trim(w2_policy_holder_code), '') end),''),'') || '|' || coalesce('CUSTOMER','')"
  PARTY_ROLE_NK__POLICYHOLDER: "'LNK_PARTY_ROLE|' || (coalesce(nullif(trim(case when nullif(trim(w2_policy_holder_code),'') is not null then nullif(trim(w2_policy_holder_code), '') end),''),'') || '|' || coalesce('CUSTOMER',''))"
  PARTY_ROLE_ROLE: "'CUSTOMER'"
  PARTY_ROLE_BK__RELATIONSHIP_MANAGER: "coalesce(nullif(trim(case when nullif(trim(bagic_rm_ecode),'') is not null then 'EMP:' || nullif(trim(bagic_rm_ecode), '') end),''),'')"
  PARTY_ROLE_NK__RELATIONSHIP_MANAGER: "'LNK_PARTY_ROLE|' || (coalesce(nullif(trim(case when nullif(trim(bagic_rm_ecode),'') is not null then 'EMP:' || nullif(trim(bagic_rm_ecode), '') end),''),''))"
  POLICY_BK__MASTER_POLICY: "nullif(trim(case when nullif(trim(master_policy_number),'') is not null then nullif(trim(master_policy_number), '') end),'')"
  POLICY_NK__MASTER_POLICY: "'HUB_POLICY|' || (nullif(trim(case when nullif(trim(master_policy_number),'') is not null then nullif(trim(master_policy_number), '') end),''))"
  POLICY_BK__PREVIOUS_POLICY: "nullif(trim(case when nullif(trim(expiring_policy_number),'') is not null then nullif(trim(expiring_policy_number), '') end),'')"
  POLICY_NK__PREVIOUS_POLICY: "'HUB_POLICY|' || (nullif(trim(case when nullif(trim(expiring_policy_number),'') is not null then nullif(trim(expiring_policy_number), '') end),''))"
  POLICY_BK__PREVIOUS_POLICY_PORTABILITY: "nullif(trim(case when nullif(trim(previous_policy_number),'') is not null then nullif(trim(previous_policy_number), '') end),'')"
  POLICY_NK__PREVIOUS_POLICY_PORTABILITY: "'HUB_POLICY|' || (nullif(trim(case when nullif(trim(previous_policy_number),'') is not null then nullif(trim(previous_policy_number), '') end),''))"
  PRODUCT_BK: "nullif(trim(case when nullif(trim(w1_product_code),'') is not null then 'PROD:' || nullif(trim(w1_product_code), '') end),'')"
  PRODUCT_NK: "'HUB_PRODUCT|' || (nullif(trim(case when nullif(trim(w1_product_code),'') is not null then 'PROD:' || nullif(trim(w1_product_code), '') end),''))"
  QUOTE_BK: "nullif(trim(case when nullif(trim(w0_policy_quote_number),'') is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when nullif(trim(w0_policy_quote_number),'') is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  AMOUNT_RECEIVED: 'cast(null as varchar)'
  BASE_CURRENCY_CODE: 'policy_level_base_currency'
  BASE_PREMIUM: 'base_premium'
  CHANNEL_NAME: 'partner_name'
  CHANNEL_REMARKS: 'cast(null as varchar)'
  CHANNEL_TYPE: 'cast(null as varchar)'
  COLLECTION_MODE: 'mode_of_payment'
  CONSENT_FOR_DATA_SHARING_INDICATOR: 'cast(null as varchar)'
  COST_CENTRE_CODE: 'cost_center'
  CO_INSURANCE_INDICATOR: 'cast(null as varchar)'
  CURRENCY_CODE: 'policy_level_transaction_currency'
  CURRENCY_CODE__SAT_POLICY_HEADER: 'cast(null as varchar)'
  DISCOUNT_AMOUNT: 'cast(null as varchar)'
  DOCUMENT_NAME: 'cast(null as varchar)'
  DOCUMENT_REFERENCE_NUMBER: 'coi_number'
  DOCUMENT_TYPE: 'cast(null as varchar)'
  EMPLOYEE_CODE: 'bagic_rm_ecode'
  EXCHANGE_RATE: 'forex_rate_at_policy_level'
  FIRST_YEAR_INDICATOR: 'cast(null as varchar)'
  GO_GREEN_OPT_IN_INDICATOR: 'cast(null as varchar)'
  GROSS_PREMIUM: 'gross_premium'
  ISSUE_DATE: 'cast(null as varchar)'
  LEAD_REFERENCE: 'crm_reference_number'
  LINE_OF_BUSINESS: 'cast(null as varchar)'
  LOADING_AMOUNT: 'loading'
  NET_PREMIUM: 'net_premium'
  ORG_UNIT_CODE: 'cast(null as varchar)'
  ORG_UNIT_NAME: 'cast(null as varchar)'
  PAYMENT_GATEWAY_REFERENCE: 'pgtransaction_id'
  POLICYHOLDER_REFERENCE: 'cast(null as varchar)'
  POLICY_CHANNEL_TYPE: 'cast(null as varchar)'
  POLICY_REFERENCE_NUMBER: 'cast(null as varchar)'
  POLICY_REMARKS: 'cast(null as varchar)'
  POLICY_STATUS: 'cast(null as varchar)'
  POLICY_SUB_STATUS: 'cast(null as varchar)'
  POLICY_TERM: 'cast(null as varchar)'
  POLICY_TYPE: 'master_policy_type'
  PREFERRED_CHANNEL_CODE: 'cast(null as varchar)'
  PREFERRED_CUSTOMER_INDICATOR: 'prive_flag'
  PREFERRED_LANGUAGE_CODE: 'cast(null as varchar)'
  PREMIUM_FREQUENCY: 'payment_frequency'
  PREMIUM_FREQUENCY__SAT_POLICY_HEADER: 'cast(null as varchar)'
  PREMIUM_PAYER_REFERENCE: 'cast(null as varchar)'
  PRODUCT_CATEGORY: 'plan_category'
  PRODUCT_NAME: 'cast(null as varchar)'
  PRODUCT_REFERENCE: 'cast(null as varchar)'
  PROSPECT_REFERENCE: 'policy_holder'
  QUOTE_REMARKS: 'remarks'
  QUOTE_SOURCE: 'issuance_source'
  QUOTE_STATUS: 'cast(null as varchar)'
  REALISATION_DATE: 'cast(null as varchar)'
  RECEIPT_DATE: 'cast(null as varchar)'
  RECEIPT_NUMBER: 'cast(null as varchar)'
  RECEIPT_TYPE: 'cast(null as varchar)'
  RECEIVED_DATE: 'cast(null as varchar)'
  REQUESTED_COVER_START_DATE: 'policy_inception_date'
  REQUESTED_POLICY_TERM: 'policy_duration'
  REQUESTED_SUM_INSURED: 'sum_insured'
  RISK_END_TIME: 'cast(null as varchar)'
  RISK_EXPIRY_DATE: 'expiring_policy_expiry_date'
  RISK_INCEPTION_DATE: 'cast(null as varchar)'
  RISK_START_TIME: 'cast(null as varchar)'
  SMS_OPT_IN_INDICATOR: 'sms_communication'
  SOURCE_CHANNEL: 'cast(null as varchar)'
  SOURCE_REFERENCE_NUMBER: 'cast(null as varchar)'
  SOURCE_REFERENCE_TYPE: 'cast(null as varchar)'
  SUB_CHANNEL_CODE: 'cast(null as varchar)'
  SUB_CHANNEL_EFFECTIVE_DATE: 'cast(null as varchar)'
  SUM_INSURED_TOTAL: 'cast(null as varchar)'
  TRANSACTION_CHANNEL: 'cast(null as varchar)'
  TRANSACTION_DATE: 'cast(null as varchar)'
  TRANSACTION_NUMBER: 'transaction_id'
  TRANSACTION_TYPE: 'cast(null as varchar)'
  UIN: 'uin'
  VIP_INDICATOR: 'cast(null as varchar)'
  BASE_CURRENCY_EXCHANGE_RATE: 'cast(null as varchar)'
  COURIER_NAME: 'cast(null as varchar)'
  DOCUMENT_DETAILS_TEXT: 'cast(null as varchar)'
  PROOF_OF_DELIVERY_NUMBER: 'cast(null as varchar)'
  RECORD_VALID_INDICATOR: 'cast(null as varchar)'
  SENDER_NAME: 'cast(null as varchar)'
  SPECIAL_ENCLOSURES_DETAILS: 'cast(null as varchar)'
  SPECIAL_ENCLOSURES_INDICATOR: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
