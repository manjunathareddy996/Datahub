{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat() for SAT_AUG_COVERAGE_SUBLIMIT_SCHEDULE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, COVERAGE_HKEY, multi-active on ACTIVE_SEQUENCE_NUMBER.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_coverage_sublimit_schedule'
src_pk: 'COVERAGE_HKEY'
src_cdk:
  - 'ACTIVE_SEQUENCE_NUMBER'
src_payload:
  - 'BENEFIT_AMOUNT'
  - 'DELAY_THRESHOLD_EXCEEDED'
  - 'DELAY_THRESHOLD_EXCEEDED_ACE_VARIANT'
  - 'LIMIT_SUM_INSURED_AMOUNT'
  - 'LOADING_ACE_VARIANT'
  - 'MAIN_SUB_COVER_LOADING_ACE_VARIANT'
  - 'MAIN_SUB_COVER_RATE_PER_TRIP_PER_MILLE'
  - 'MAIN_SUB_COVER_SUM_INSURED_ACE_VARIANT'
  - 'OFFICE_PREMIUM_RATE_PER_MILLE_PER_ANNUM'
  - 'OFFICE_PREMIUM_RATE_PER_MILLE_PER_TRIP'
  - 'RATE_PER_TRIP_PER_MILLE'
  - 'RATING_SLAB_BAND'
  - 'SUB_LIMIT_DEDUCTIBLE_AMOUNT'
  - 'SUB_LIMIT_PERIOD'
  - 'SUM_INSURED_ACE_VARIANT'
  - 'TRIP_TYPE_FOR_INCONVENIENCE_COVER'
  - 'TRIP_TYPE_FOR_TRIP_CALCULATION'
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
