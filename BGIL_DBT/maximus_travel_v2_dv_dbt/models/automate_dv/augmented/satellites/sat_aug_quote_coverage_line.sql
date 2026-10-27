{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_AUG_QUOTE_COVERAGE_LINE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, QUOTE_HKEY, single-active.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_aug_sat_aug_quote_coverage_line'
src_pk: 'QUOTE_HKEY'
src_payload:
  - 'ACE_VARIANT_DEDUCTIBLE_AMOUNT'
  - 'AMBULANCE_SUB_COVER_VALUE'
  - 'COMMON_CARRIER_TYPE'
  - 'COVERAGE_BASE_CURRENCY_CODE'
  - 'COVERAGE_END_DATE'
  - 'COVERAGE_LEVEL_EXCHANGE_RATE'
  - 'COVERAGE_LIMIT_AMOUNT'
  - 'COVERAGE_MANUAL_DESCRIPTION'
  - 'COVERAGE_PREMIUM_IN_BASE_CURRENCY'
  - 'COVERAGE_PREMIUM_IN_TRANSACTION_CURRENCY'
  - 'COVERAGE_START_DATE'
  - 'COVERAGE_SUM_INSURED_CURRENCY_CODE'
  - 'COVERAGE_SUM_INSURED_IN_BASE_CURRENCY'
  - 'COVERAGE_SUM_INSURED_IN_TRANSACTION_CURRENCY'
  - 'COVERAGE_TRANSACTION_CURRENCY_CODE'
  - 'CO_PAYMENT_PERCENTAGE'
  - 'DEDUCTIBLE_AMOUNT'
  - 'DEDUCTIBLE_AMOUNT_FOR_INDIA_LOSSES'
  - 'DEDUCTIBLE_AMOUNT_FOR_OVERSEAS_LOSSES'
  - 'DEDUCTIBLE_APPLICATION_BASIS'
  - 'DEDUCTIBLE_COMPUTATION_BASIS'
  - 'DEDUCTIBLE_DESCRIPTOR'
  - 'ENDORSEMENT_PREMIUM'
  - 'FACULTATIVE_REINSURANCE_INDICATOR'
  - 'FACULTATIVE_REINSURANCE_PERCENTAGE'
  - 'GROSS_PREMIUM'
  - 'MAXIMUM_COVER_PERIOD_DAYS'
  - 'MAXIMUM_SUM_INSURED'
  - 'NET_PREMIUM_IN_PREMIUM_CURRENCY'
  - 'NUMBER_OF_DAYS_COVERED'
  - 'NUMBER_OF_WEEKS_COVERED'
  - 'TRAVEL_INCONVENIENCE_SUB_COVER_VALUE'
  - 'TRIP_CANCELLATION_SUB_COVER_VALUE'
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
