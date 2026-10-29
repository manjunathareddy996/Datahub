{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat() for SAT_AUG_POLICY_COVERAGE_SCHEDULE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, POLICY_HKEY, multi-active on COVERAGE_REFERENCE, COVERAGE_SEQUENCE.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_policy_coverage_schedule'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'COVERAGE_REFERENCE'
  - 'COVERAGE_SEQUENCE'
src_payload:
  - 'ACE_VARIANT_DEDUCTIBLE_AMOUNT'
  - 'AMBULANCE_SUB_COVER_VALUE'
  - 'BENEFIT_UNIT_IN_HOURS'
  - 'BUSINESS_EVENT_CODE'
  - 'COMMON_CARRIER_TYPE'
  - 'COVERAGE_BASE_CURRENCY_CODE'
  - 'COVERAGE_LEVEL_EXCHANGE_RATE'
  - 'COVERAGE_MANUAL_DESCRIPTION'
  - 'COVERAGE_SUM_INSURED_CURRENCY_CODE'
  - 'COVERAGE_TERM'
  - 'COVERAGE_TRANSACTION_CURRENCY_CODE'
  - 'DEDUCTIBLE_AMOUNT_FOR_INDIA_LOSSES'
  - 'DEDUCTIBLE_AMOUNT_FOR_OVERSEAS_LOSSES'
  - 'DEDUCTIBLE_APPLICATION_BASIS'
  - 'DEDUCTIBLE_COMPUTATION_BASIS'
  - 'DEDUCTIBLE_DESCRIPTOR'
  - 'FACULTATIVE_REINSURANCE_INDICATOR'
  - 'FACULTATIVE_REINSURANCE_PERCENTAGE'
  - 'MAXIMUM_COVER_PERIOD_DAYS'
  - 'MAXIMUM_SUM_INSURED'
  - 'NUMBER_OF_DAYS_COVERED'
  - 'NUMBER_OF_WEEKS_COVERED'
  - 'PAYOUT_OPTION'
  - 'PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY'
  - 'SUB_LIMIT_DETAIL'
  - 'SUM_INSURED_IN_BASE_CURRENCY'
  - 'TRAVEL_INCONVENIENCE_SUB_COVER_VALUE'
  - 'TRIP_CANCELLATION_SUB_COVER_VALUE'
  - 'TRIP_DELAY_OPTION'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
