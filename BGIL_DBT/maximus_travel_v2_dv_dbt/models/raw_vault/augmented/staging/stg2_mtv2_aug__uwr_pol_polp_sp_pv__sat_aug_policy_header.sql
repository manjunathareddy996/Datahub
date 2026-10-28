{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_HEADER from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 23 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_polp_sp_pv'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_HEADER:
    is_hashdiff: true
    columns:
      - 'CBM_REFERENCE_NUMBER'
      - 'COVER_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE'
      - 'CRM_REFERENCE_NUMBER'
      - 'DISTRIBUTION_CHANNEL_NAME'
      - 'EXTERNAL_REFERENCE_DETAILS'
      - 'EXTERNAL_REFERENCE_IDENTIFIER'
      - 'OPERATING_UNIT_CODE'
      - 'POLICY_INTIMATION_DATE'
      - 'POLICY_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE'
      - 'POLICY_TERM_UNIT'
      - 'POLICY_UNIQUE_IDENTIFICATION_CODE'
      - 'PREMIUM_PAYMENT_MODE'
      - 'PREMIUM_PAYMENT_OPTION'
      - 'PREMIUM_TRANSACTION_REFERENCE_NUMBER'
      - 'REINSURANCE_PLACEMENT_PENDING_INDICATOR'
      - 'SOURCE_POLICY_IDENTIFIER'
      - 'SOURCE_RECORD_IDENTIFIER'
      - 'SUM_INSURED_CURRENCY_CODE'
      - 'SUM_INSURED_CURRENCY_EXCHANGE_RATE'
      - 'SUM_INSURED_TOTAL_IN_BASE_CURRENCY'
      - 'SUM_INSURED_TOTAL_IN_SUM_INSURED_CURRENCY'
      - 'SUM_INSURED_TOTAL_IN_TRANSACTION_CURRENCY'
      - 'UNDERWRITING_REFERRAL_REQUIRED_INDICATOR'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  CBM_REFERENCE_NUMBER: 'cbm_reference_id'
  COVER_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE: 'cover_level_transaction_currency_for_sum_insured'
  CRM_REFERENCE_NUMBER: 'crm_reference_number'
  DISTRIBUTION_CHANNEL_NAME: 'cast(null as varchar)'
  EXTERNAL_REFERENCE_DETAILS: 'reference_details'
  EXTERNAL_REFERENCE_IDENTIFIER: 'reference_id'
  OPERATING_UNIT_CODE: 'unit'
  POLICY_INTIMATION_DATE: 'cast(null as varchar)'
  POLICY_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE: 'policy_level_transaction_currency_for_sum_insured'
  POLICY_TERM_UNIT: 'cast(null as varchar)'
  POLICY_UNIQUE_IDENTIFICATION_CODE: 'unique_identification_code_for_policy'
  PREMIUM_PAYMENT_MODE: 'cast(null as varchar)'
  PREMIUM_PAYMENT_OPTION: 'cast(null as varchar)'
  PREMIUM_TRANSACTION_REFERENCE_NUMBER: 'reference_no'
  REINSURANCE_PLACEMENT_PENDING_INDICATOR: 'cast(null as varchar)'
  SOURCE_POLICY_IDENTIFIER: 'policy_id'
  SOURCE_RECORD_IDENTIFIER: 'policy_rid'
  SUM_INSURED_CURRENCY_CODE: 'sum_insured_currency'
  SUM_INSURED_CURRENCY_EXCHANGE_RATE: 'sum_insured_currency_exchange_rate'
  SUM_INSURED_TOTAL_IN_BASE_CURRENCY: 'policy_sum_insured_in_base_currency'
  SUM_INSURED_TOTAL_IN_SUM_INSURED_CURRENCY: 'sum_insured_in_si_currency'
  SUM_INSURED_TOTAL_IN_TRANSACTION_CURRENCY: 'policy_sum_insured_in_transaction_currency'
  UNDERWRITING_REFERRAL_REQUIRED_INDICATOR: 'underwriting_rqrd_flag'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
