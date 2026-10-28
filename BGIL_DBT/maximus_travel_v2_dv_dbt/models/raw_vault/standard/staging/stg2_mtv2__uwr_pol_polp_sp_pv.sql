{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- Covers this view's 14 key slot(s) and its 25 1:1 satellite target(s) in one pass,
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
--   ASSESSMENT_HKEY                    HUB_ASSESSMENT  (1 row(s) in the map)
--   DISTRIBUTION_CHANNEL_HKEY          HUB_DISTRIBUTION_CHANNEL  (2 row(s) in the map)
--   DOCUMENT_HKEY                      HUB_DOCUMENT  (1 row(s) in the map)
--   DOCUMENT_HKEY__PREVIOUS_CERTIFICATE HUB_DOCUMENT / previous-certificate  (1 row(s) in the map)
--   FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM HUB_FINANCIAL_TRANSACTION / policy-premium  (7 row(s) in the map)
--   ORG_UNIT_HKEY                      HUB_ORG_UNIT  (2 row(s) in the map)
--   PARTY_HKEY__POLICYHOLDER           HUB_PARTY / policyholder  (2 row(s) in the map)
--   PARTY_HKEY__RELATIONSHIP_MANAGER   HUB_PARTY / relationship-manager  (1 row(s) in the map)
--   PARTY_ROLE_HKEY__POLICYHOLDER      LNK_PARTY_ROLE / policyholder  LINK
--   PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER LNK_PARTY_ROLE / relationship-manager  LINK
--   POLICY_HKEY                        HUB_POLICY  (108 row(s) in the map)
--   POLICY_HKEY__MASTER_POLICY         HUB_POLICY / master-policy  (2 row(s) in the map)
--   POLICY_HKEY__PREVIOUS_POLICY       HUB_POLICY / previous-policy  (2 row(s) in the map)
--   PRODUCT_HKEY                       HUB_PRODUCT  (2 row(s) in the map)
--   HASHDIFF_CHANNEL_DEFINITION        SAT_CHANNEL_DEFINITION payload 1 of 5 live here
--   HASHDIFF_COMMON_BUSINESS_AUDIT     SAT_COMMON_BUSINESS_AUDIT payload 3 of 3 live here
--   HASHDIFF_COMMON_COMMUNICATION_PREFERENCE SAT_COMMON_COMMUNICATION_PREFERENCE payload 1 of 4 live here
--   HASHDIFF_COMMON_LIFECYCLE          SAT_COMMON_LIFECYCLE payload 1 of 1 live here
--   HASHDIFF_COMMON_MONETARY_CONTEXT   SAT_COMMON_MONETARY_CONTEXT payload 3 of 3 live here
--   HASHDIFF_COMMON_STATUS             SAT_COMMON_STATUS payload 1 of 1 live here
--   HASHDIFF_DOCUMENT_DEFINITION       SAT_DOCUMENT_DEFINITION payload 1 of 6 live here
--   HASHDIFF_FINTXN_HEADER             SAT_FINTXN_HEADER payload 1 of 7 live here
--   HASHDIFF_FINTXN_PREMIUM            SAT_FINTXN_PREMIUM payload 1 of 1 live here
--   HASHDIFF_FIN_RECEIPT               SAT_FIN_RECEIPT payload 1 of 6 live here
--   HASHDIFF_LNK_ROLE_CUSTOMER         SAT_LNK_ROLE_CUSTOMER payload 1 of 3 live here
--   HASHDIFF_LNK_ROLE_EMPLOYEE         SAT_LNK_ROLE_EMPLOYEE payload 1 of 1 live here
--   HASHDIFF_ORG_UNIT_DEFINITION       SAT_ORG_UNIT_DEFINITION payload 1 of 2 live here
--   HASHDIFF_POLICY_CANCELLATION       SAT_POLICY_CANCELLATION payload 1 of 1 live here
--   HASHDIFF_POLICY_COVERAGE_SCHEDULE  SAT_POLICY_COVERAGE_SCHEDULE payload 1 of 8 live here
--   HASHDIFF_POLICY_ENDORSEMENT        SAT_POLICY_ENDORSEMENT payload 2 of 5 live here
--   HASHDIFF_POLICY_GROUP              SAT_POLICY_GROUP payload 1 of 1 live here
--   HASHDIFF_POLICY_HEADER             SAT_POLICY_HEADER payload 15 of 19 live here
--   HASHDIFF_POLICY_INTERMEDIARY_SPLIT SAT_POLICY_INTERMEDIARY_SPLIT payload 1 of 2 live here
--   HASHDIFF_POLICY_PORTABILITY_MIGRATION SAT_POLICY_PORTABILITY_MIGRATION payload 1 of 1 live here
--   HASHDIFF_POLICY_PREMIUM_SUMMARY    SAT_POLICY_PREMIUM_SUMMARY payload 6 of 7 live here
--   HASHDIFF_POLICY_TAX_BREAKUP        SAT_POLICY_TAX_BREAKUP payload 4 of 5 live here
--   HASHDIFF_POLICY_TAX_HEAD           SAT_POLICY_TAX_HEAD payload 1 of 1 live here
--   HASHDIFF_POLICY_TERMS              SAT_POLICY_TERMS payload 1 of 1 live here
--   HASHDIFF_PRODUCT_DEFINITION        SAT_PRODUCT_DEFINITION payload 2 of 4 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_polp_sp_pv'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  DOCUMENT_HKEY__PREVIOUS_CERTIFICATE: 'DOCUMENT_NK__PREVIOUS_CERTIFICATE'
  FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM: 'FINANCIAL_TRANSACTION_NK__POLICY_PREMIUM'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY__POLICYHOLDER: 'PARTY_NK__POLICYHOLDER'
  PARTY_HKEY__RELATIONSHIP_MANAGER: 'PARTY_NK__RELATIONSHIP_MANAGER'
  PARTY_ROLE_HKEY__POLICYHOLDER: 'PARTY_ROLE_NK__POLICYHOLDER'
  PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER: 'PARTY_ROLE_NK__RELATIONSHIP_MANAGER'
  POLICY_HKEY: 'POLICY_NK'
  POLICY_HKEY__MASTER_POLICY: 'POLICY_NK__MASTER_POLICY'
  POLICY_HKEY__PREVIOUS_POLICY: 'POLICY_NK__PREVIOUS_POLICY'
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF_CHANNEL_DEFINITION:
    is_hashdiff: true
    columns:
      - 'CHANNEL_NAME'
      - 'CHANNEL_REMARKS'
      - 'CHANNEL_TYPE'
      - 'SUB_CHANNEL_CODE'
      - 'SUB_CHANNEL_EFFECTIVE_DATE'
  HASHDIFF_COMMON_BUSINESS_AUDIT:
    is_hashdiff: true
    columns:
      - 'CREATED_BY_USER_REFERENCE'
      - 'CREATED_DATE'
      - 'SOURCE_APPLICATION_NAME'
  HASHDIFF_COMMON_COMMUNICATION_PREFERENCE:
    is_hashdiff: true
    columns:
      - 'GO_GREEN_OPT_IN_INDICATOR'
      - 'PREFERRED_CHANNEL_CODE'
      - 'PREFERRED_LANGUAGE_CODE'
      - 'SMS_OPT_IN_INDICATOR'
  HASHDIFF_COMMON_LIFECYCLE:
    is_hashdiff: true
    columns:
      - 'EFFECTIVE_DATE'
  HASHDIFF_COMMON_MONETARY_CONTEXT:
    is_hashdiff: true
    columns:
      - 'BASE_CURRENCY_CODE'
      - 'CURRENCY_CODE'
      - 'EXCHANGE_RATE'
  HASHDIFF_COMMON_STATUS:
    is_hashdiff: true
    columns:
      - 'STATUS_REASON_DESCRIPTION'
  HASHDIFF_DOCUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_NAME'
      - 'DOCUMENT_REFERENCE_NUMBER'
      - 'DOCUMENT_TYPE'
      - 'ISSUE_DATE'
      - 'RECEIVED_DATE'
      - 'SOURCE_CHANNEL'
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
  HASHDIFF_POLICY_CANCELLATION:
    is_hashdiff: true
    columns:
      - 'CANCELLATION_REQUESTED_BY_ROLE'
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
  HASHDIFF_POLICY_ENDORSEMENT:
    is_hashdiff: true
    columns:
      - 'EFFECTIVE_DATE__SAT_POLICY_ENDORSEMENT'
      - 'ENDORSEMENT_NUMBER'
      - 'ENDORSEMENT_REASON'
      - 'ENDORSEMENT_TYPE'
      - 'PREMIUM_IMPACT_AMOUNT'
      - 'SUM_INSURED_IMPACT_AMOUNT'
  HASHDIFF_POLICY_GROUP:
    is_hashdiff: true
    columns:
      - 'GROUP_TYPE'
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
  HASHDIFF_POLICY_PORTABILITY_MIGRATION:
    is_hashdiff: true
    columns:
      - 'PREVIOUS_POLICY_NUMBER'
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
      - 'IGST_AMOUNT'
      - 'SGST_AMOUNT'
      - 'STAMP_DUTY_AMOUNT'
  HASHDIFF_POLICY_TAX_HEAD:
    is_hashdiff: true
    columns:
      - 'TAX_AMOUNT'
      - 'TAX_HEAD_CODE'
  HASHDIFF_POLICY_TERMS:
    is_hashdiff: true
    columns:
      - 'GEOGRAPHICAL_SCOPE'
  HASHDIFF_PRODUCT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'LINE_OF_BUSINESS'
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_NAME'
      - 'UIN'
derived_columns:
  ASSESSMENT_BK: "nullif(trim(case when coalesce(nullif(trim(bagic_scrutiny_number),'')) is not null then 'SCRUTINY:' || nullif(trim(bagic_scrutiny_number), '') end),'')"
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || (nullif(trim(case when coalesce(nullif(trim(bagic_scrutiny_number),'')) is not null then 'SCRUTINY:' || nullif(trim(bagic_scrutiny_number), '') end),''))"
  DISTRIBUTION_CHANNEL_BK: "nullif(trim(case when coalesce(nullif(trim(imd_code),'')) is not null then nullif(trim(imd_code), '') end),'')"
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (nullif(trim(case when coalesce(nullif(trim(imd_code),'')) is not null then nullif(trim(imd_code), '') end),''))"
  DOCUMENT_BK: "nullif(trim(case when coalesce(nullif(trim(coi_number),'')) is not null then 'COI:' || nullif(trim(coi_number), '') end),'')"
  DOCUMENT_NK: "'HUB_DOCUMENT|' || (nullif(trim(case when coalesce(nullif(trim(coi_number),'')) is not null then 'COI:' || nullif(trim(coi_number), '') end),''))"
  DOCUMENT_BK__PREVIOUS_CERTIFICATE: "nullif(trim(case when coalesce(nullif(trim(old_coi_number),'')) is not null then 'COI:' || nullif(trim(old_coi_number), '') end),'')"
  DOCUMENT_NK__PREVIOUS_CERTIFICATE: "'HUB_DOCUMENT|' || (nullif(trim(case when coalesce(nullif(trim(old_coi_number),'')) is not null then 'COI:' || nullif(trim(old_coi_number), '') end),''))"
  FINANCIAL_TRANSACTION_BK__POLICY_PREMIUM: "nullif(trim(case when coalesce(nullif(trim(w1_policy_number),''), nullif(trim(foreign_key),'')) is not null then 'POLPREM:' || coalesce(nullif(trim(w1_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  FINANCIAL_TRANSACTION_NK__POLICY_PREMIUM: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(w1_policy_number),''), nullif(trim(foreign_key),'')) is not null then 'POLPREM:' || coalesce(nullif(trim(w1_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  ORG_UNIT_BK: "nullif(trim(case when coalesce(nullif(trim(branch_code),'')) is not null then nullif(trim(branch_code), '') end),'')"
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || (nullif(trim(case when coalesce(nullif(trim(branch_code),'')) is not null then nullif(trim(branch_code), '') end),''))"
  PARTY_BK__POLICYHOLDER: "nullif(trim(case when coalesce(nullif(trim(w3_policy_holder_code),'')) is not null then nullif(trim(w3_policy_holder_code), '') end),'')"
  PARTY_NK__POLICYHOLDER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w3_policy_holder_code),'')) is not null then nullif(trim(w3_policy_holder_code), '') end),''))"
  PARTY_BK__RELATIONSHIP_MANAGER: "nullif(trim(case when coalesce(nullif(trim(bagic_rm_ecode),'')) is not null then 'EMP:' || nullif(trim(bagic_rm_ecode), '') end),'')"
  PARTY_NK__RELATIONSHIP_MANAGER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(bagic_rm_ecode),'')) is not null then 'EMP:' || nullif(trim(bagic_rm_ecode), '') end),''))"
  PARTY_ROLE_BK__POLICYHOLDER: "coalesce(nullif(trim(case when coalesce(nullif(trim(w3_policy_holder_code),'')) is not null then nullif(trim(w3_policy_holder_code), '') end),''),'') || '|' || coalesce('CUSTOMER','')"
  PARTY_ROLE_NK__POLICYHOLDER: "'LNK_PARTY_ROLE|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w3_policy_holder_code),'')) is not null then nullif(trim(w3_policy_holder_code), '') end),''),'') || '|' || coalesce('CUSTOMER',''))"
  PARTY_ROLE_ROLE: "'CUSTOMER'"
  PARTY_ROLE_BK__RELATIONSHIP_MANAGER: "coalesce(nullif(trim(case when coalesce(nullif(trim(bagic_rm_ecode),'')) is not null then 'EMP:' || nullif(trim(bagic_rm_ecode), '') end),''),'')"
  PARTY_ROLE_NK__RELATIONSHIP_MANAGER: "'LNK_PARTY_ROLE|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(bagic_rm_ecode),'')) is not null then 'EMP:' || nullif(trim(bagic_rm_ecode), '') end),''),''))"
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  POLICY_BK__MASTER_POLICY: "nullif(trim(case when coalesce(nullif(trim(master_policy_number),'')) is not null then nullif(trim(master_policy_number), '') end),'')"
  POLICY_NK__MASTER_POLICY: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(master_policy_number),'')) is not null then nullif(trim(master_policy_number), '') end),''))"
  POLICY_BK__PREVIOUS_POLICY: "nullif(trim(case when coalesce(nullif(trim(expiring_policy_number),'')) is not null then nullif(trim(expiring_policy_number), '') end),'')"
  POLICY_NK__PREVIOUS_POLICY: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(expiring_policy_number),'')) is not null then nullif(trim(expiring_policy_number), '') end),''))"
  PRODUCT_BK: "nullif(trim(case when coalesce(nullif(trim(w2_product_code),'')) is not null then 'PROD:' || nullif(trim(w2_product_code), '') end),'')"
  PRODUCT_NK: "'HUB_PRODUCT|' || (nullif(trim(case when coalesce(nullif(trim(w2_product_code),'')) is not null then 'PROD:' || nullif(trim(w2_product_code), '') end),''))"
  AMOUNT_RECEIVED: 'cast(null as varchar)'
  BASE_CURRENCY_CODE: 'policy_level_base_currency'
  BASE_PREMIUM: 'base_premium'
  CANCELLATION_REQUESTED_BY_ROLE: 'cancelled_by'
  CESS_AMOUNT: 'cess'
  CGST_AMOUNT: 'cgst_amount'
  CHANNEL_NAME: 'partner_name'
  CHANNEL_REMARKS: 'cast(null as varchar)'
  CHANNEL_TYPE: 'cast(null as varchar)'
  COLLECTION_MODE: 'mode_of_payment'
  COMMISSION_AMOUNT: 'cast(null as varchar)'
  CONSENT_FOR_DATA_SHARING_INDICATOR: 'cast(null as varchar)'
  COST_CENTRE_CODE: 'cost_center'
  COVERAGE_END_DATE: 'cast(null as varchar)'
  COVERAGE_OPTED_INDICATOR: 'transit_journey_cover'
  COVERAGE_REFERENCE: "'TRANSIT_JOURNEY_COVER'"
  COVERAGE_SEQUENCE: "'1'"
  COVERAGE_START_DATE: 'cast(null as varchar)'
  CO_INSURANCE_INDICATOR: 'coinsurance_applicable'
  CO_PAYMENT_PERCENTAGE: 'cast(null as varchar)'
  CREATED_BY_USER_REFERENCE: 'coalesce(bagic_created_by, created_by)'
  CREATED_DATE: 'entry_date'
  CURRENCY_CODE: 'policy_level_transaction_currency'
  CURRENCY_CODE__SAT_POLICY_HEADER: 'cast(null as varchar)'
  DEDUCTIBLE_AMOUNT: 'cast(null as varchar)'
  DOCUMENT_NAME: 'cast(null as varchar)'
  DOCUMENT_REFERENCE_NUMBER: 'coi_number'
  DOCUMENT_TYPE: 'cast(null as varchar)'
  EFFECTIVE_DATE: 'effective_date'
  EFFECTIVE_DATE__SAT_POLICY_ENDORSEMENT: 'cast(null as varchar)'
  EMPLOYEE_CODE: 'bagic_rm_ecode'
  ENDORSEMENT_NUMBER: "coalesce(nullif(trim(bagic_endorsement_number), ''),'')"
  ENDORSEMENT_REASON: 'reason_for_initiating_this_action'
  ENDORSEMENT_TYPE: 'type_of_endorsement'
  EXCHANGE_RATE: 'forex_rate_at_policy_level'
  FIRST_YEAR_INDICATOR: 'first_time_executed'
  GEOGRAPHICAL_SCOPE: 'geographical_coverage'
  GO_GREEN_OPT_IN_INDICATOR: 'cast(null as varchar)'
  GROSS_PREMIUM: 'gross_premium'
  GROUP_TYPE: 'nature_of_groups'
  IGST_AMOUNT: 'igst_amount'
  INTERMEDIARY_REFERENCE: "coalesce(nullif(trim(imd_code), ''),'')"
  ISSUE_DATE: 'cast(null as varchar)'
  LIMIT_AMOUNT: 'cast(null as varchar)'
  LINE_OF_BUSINESS: 'cast(null as varchar)'
  LOADING_AMOUNT: 'loading'
  NET_PREMIUM: 'net_premium'
  ORG_UNIT_CODE: 'cast(null as varchar)'
  ORG_UNIT_NAME: 'cast(null as varchar)'
  PAYMENT_GATEWAY_REFERENCE: 'pgtransaction_id'
  POLICYHOLDER_REFERENCE: 'policy_holder'
  POLICY_CHANNEL_TYPE: 'cast(null as varchar)'
  POLICY_REFERENCE_NUMBER: 'bagic_contract_id'
  POLICY_REMARKS: 'remarks'
  POLICY_STATUS: 'cast(null as varchar)'
  POLICY_SUB_STATUS: 'policy_sub_status'
  POLICY_TERM: 'policy_duration'
  POLICY_TYPE: 'coalesce(master_policy_type, policy_type)'
  PREFERRED_CHANNEL_CODE: 'cast(null as varchar)'
  PREFERRED_CUSTOMER_INDICATOR: 'prive_flag'
  PREFERRED_LANGUAGE_CODE: 'cast(null as varchar)'
  PREMIUM_FOR_COVERAGE: 'cast(null as varchar)'
  PREMIUM_FREQUENCY: 'payment_frequency'
  PREMIUM_IMPACT_AMOUNT: 'cast(null as varchar)'
  PREMIUM_OUTSTANDING: 'cast(null as varchar)'
  PREMIUM_PAYER_REFERENCE: 'bill_to'
  PREVIOUS_POLICY_NUMBER: 'previous_policy_number'
  PRODUCT_CATEGORY: 'plan_category'
  PRODUCT_NAME: 'cast(null as varchar)'
  PRODUCT_REFERENCE: 'cast(null as varchar)'
  REALISATION_DATE: 'cast(null as varchar)'
  RECEIPT_DATE: 'cast(null as varchar)'
  RECEIPT_NUMBER: 'cast(null as varchar)'
  RECEIPT_TYPE: 'cast(null as varchar)'
  RECEIVED_DATE: 'cast(null as varchar)'
  REFUND_AMOUNT: 'refund_amount'
  RISK_END_TIME: 'policy_expiry_time'
  RISK_EXPIRY_DATE: 'coalesce(expiring_policy_expiry_date, policy_expiry_date)'
  RISK_INCEPTION_DATE: 'policy_inception_date'
  RISK_START_TIME: 'policy_inception_time'
  SGST_AMOUNT: 'sgst_amount'
  SMS_OPT_IN_INDICATOR: 'sms_communication'
  SOURCE_APPLICATION_NAME: 'issuance_source'
  SOURCE_CHANNEL: 'cast(null as varchar)'
  SOURCE_REFERENCE_NUMBER: 'cast(null as varchar)'
  SOURCE_REFERENCE_TYPE: 'cast(null as varchar)'
  STAMP_DUTY_AMOUNT: 'cast(null as varchar)'
  STATUS_REASON_DESCRIPTION: 'reason'
  SUB_CHANNEL_CODE: 'cast(null as varchar)'
  SUB_CHANNEL_EFFECTIVE_DATE: 'cast(null as varchar)'
  SUB_IMD_CODE: 'sub_imd_code'
  SUM_INSURED: 'cast(null as varchar)'
  SUM_INSURED_IMPACT_AMOUNT: 'cast(null as varchar)'
  SUM_INSURED_TOTAL: 'sum_insured'
  TAX_AMOUNT: 'utgst_amount'
  TAX_HEAD_CODE: "'UTGST'"
  TOTAL_PREMIUM_COLLECTED: 'premium_collected'
  TRANSACTION_CHANNEL: 'cast(null as varchar)'
  TRANSACTION_DATE: 'cast(null as varchar)'
  TRANSACTION_NUMBER: 'transaction_id'
  TRANSACTION_TYPE: 'cast(null as varchar)'
  UIN: 'uin'
  VIP_INDICATOR: 'cast(null as varchar)'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
