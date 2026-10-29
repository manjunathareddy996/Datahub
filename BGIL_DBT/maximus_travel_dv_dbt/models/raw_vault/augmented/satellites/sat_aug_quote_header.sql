{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat() for SAT_AUG_QUOTE_HEADER.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, QUOTE_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_quote_header'
src_pk: 'QUOTE_HKEY'
src_payload:
  - 'ACTION_REASON_TEXT'
  - 'BANCASSURANCE_SOURCED_INDICATOR'
  - 'BILLING_STAKE_CODE'
  - 'BUSINESS_EVENT_TYPE'
  - 'BUSINESS_TYPE_CODE'
  - 'CANCELLED_BY_USER_REFERENCE'
  - 'CBM_REFERENCE_NUMBER'
  - 'CREATED_BY_USER_REFERENCE'
  - 'EFFECTIVE_DATE'
  - 'EMAIL_COMMUNICATION_REFERENCE'
  - 'EMPLOYER_ORGANISATION_NAME'
  - 'ENDORSEMENT_INVOICE_REFERENCE'
  - 'ENDORSEMENT_TYPE'
  - 'ENDORSEMENT_TYPE_CODE'
  - 'ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE'
  - 'EXPIRING_POLICY_INSURER_NAME'
  - 'EXTERNAL_REFERENCE_DETAILS'
  - 'EXTERNAL_REFERENCE_IDENTIFIER'
  - 'FIRST_YEAR_INDICATOR'
  - 'GLOBAL_ACCOUNT_INDICATOR'
  - 'GROUP_NAME'
  - 'GROUP_TYPE'
  - 'INSURED_EMPLOYEE_CODE'
  - 'INTIMATION_DATE'
  - 'OPERATING_UNIT_CODE'
  - 'POLICY_REFERENCE_NUMBER'
  - 'POLICY_UNIQUE_IDENTIFICATION_CODE'
  - 'PREMIUM_CALCULATOR_URN'
  - 'PREMIUM_PAYER_REFERENCE'
  - 'PREMIUM_PAYMENT_MODE'
  - 'PREMIUM_PAYMENT_OPTION'
  - 'PREMIUM_TRANSACTION_REFERENCE_NUMBER'
  - 'PROGRAM_IDENTIFIER'
  - 'QUOTED_PLAN_CODE'
  - 'QUOTED_POLICY_SUB_STATUS'
  - 'QUOTED_POLICY_TYPE'
  - 'QUOTE_CAPTURE_EVENT_CODE'
  - 'RECORD_ENTRY_DATE'
  - 'REFERRAL_INDICATOR'
  - 'REINSURANCE_PLACEMENT_PENDING_INDICATOR'
  - 'RENEWAL_APPLICABLE_INDICATOR'
  - 'RENEWAL_NOTICE_EXCEPTION_CLUSTER_NAME'
  - 'RENEWAL_QUOTE_GENERATED_INDICATOR'
  - 'REPLACED_POLICY_EXPIRY_DATE'
  - 'REPLACED_POLICY_INCEPTION_DATE'
  - 'REPLACED_POLICY_PRODUCT_CODE'
  - 'REQUESTED_COVER_END_DATE'
  - 'REQUESTED_COVER_END_TIME'
  - 'REQUESTED_COVER_START_TIME'
  - 'REQUESTED_POLICY_TERM_UNIT'
  - 'REQUESTED_SUM_INSURED_IN_BASE_CURRENCY'
  - 'REQUESTED_SUM_INSURED_IN_SUM_INSURED_CURRENCY'
  - 'REQUESTED_SUM_INSURED_IN_TRANSACTION_CURRENCY'
  - 'SERVICING_ACTION_REASON'
  - 'SOURCE_OF_BUSINESS_CODE'
  - 'SOURCE_POLICY_IDENTIFIER'
  - 'SOURCE_RECORD_IDENTIFIER'
  - 'SOURCE_SYSTEM_CONTRACT_IDENTIFIER'
  - 'SOURCE_SYSTEM_ENDORSEMENT_NUMBER'
  - 'SUM_INSURED_CURRENCY_CODE'
  - 'SUM_INSURED_CURRENCY_EXCHANGE_RATE'
  - 'TOUR_TYPE_CODE'
  - 'TRANSIT_JOURNEY_COVER'
  - 'UNDERWRITING_REFERRAL_REQUIRED_INDICATOR'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
