{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat() for SAT_AUG_POLICY_HEADER.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, POLICY_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_policy_header'
src_pk: 'POLICY_HKEY'
src_payload:
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
