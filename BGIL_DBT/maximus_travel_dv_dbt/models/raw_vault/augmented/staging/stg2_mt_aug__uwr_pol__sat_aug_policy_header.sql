{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_POLICY_HEADER from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 23 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'stg_mt__uwr_pol'
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
  POLICY_BK: "nullif(trim(case when nullif(trim(policy_number),'') is not null then nullif(trim(policy_number), '') end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when nullif(trim(policy_number),'') is not null then nullif(trim(policy_number), '') end),''))"
  CBM_REFERENCE_NUMBER: 'cast(null as varchar)'
  COVER_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE: 'cast(null as varchar)'
  CRM_REFERENCE_NUMBER: 'cast(null as varchar)'
  DISTRIBUTION_CHANNEL_NAME: 'cast(null as varchar)'
  EXTERNAL_REFERENCE_DETAILS: 'cast(null as varchar)'
  EXTERNAL_REFERENCE_IDENTIFIER: 'cast(null as varchar)'
  OPERATING_UNIT_CODE: 'cast(null as varchar)'
  POLICY_INTIMATION_DATE: 'policy_intimation_date'
  POLICY_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE: 'cast(null as varchar)'
  POLICY_TERM_UNIT: 'policy_durationunit'
  POLICY_UNIQUE_IDENTIFICATION_CODE: 'cast(null as varchar)'
  PREMIUM_PAYMENT_MODE: 'premium_mode'
  PREMIUM_PAYMENT_OPTION: 'cast(null as varchar)'
  PREMIUM_TRANSACTION_REFERENCE_NUMBER: 'cast(null as varchar)'
  REINSURANCE_PLACEMENT_PENDING_INDICATOR: 'cast(null as varchar)'
  SOURCE_POLICY_IDENTIFIER: 'cast(null as varchar)'
  SOURCE_RECORD_IDENTIFIER: 'cast(null as varchar)'
  SUM_INSURED_CURRENCY_CODE: 'cast(null as varchar)'
  SUM_INSURED_CURRENCY_EXCHANGE_RATE: 'cast(null as varchar)'
  SUM_INSURED_TOTAL_IN_BASE_CURRENCY: 'cast(null as varchar)'
  SUM_INSURED_TOTAL_IN_SUM_INSURED_CURRENCY: 'cast(null as varchar)'
  SUM_INSURED_TOTAL_IN_TRANSACTION_CURRENCY: 'cast(null as varchar)'
  UNDERWRITING_REFERRAL_REQUIRED_INDICATOR: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
