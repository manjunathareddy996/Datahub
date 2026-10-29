{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat() for SAT_AUG_QUOTE_COVERAGE_SCHEDULE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, QUOTE_HKEY, multi-active on COVERAGE_REFERENCE.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_quote_coverage_schedule'
src_pk: 'QUOTE_HKEY'
src_cdk:
  - 'COVERAGE_REFERENCE'
src_payload:
  - 'COVERAGE_DURATION'
  - 'DEDUCTIBLE_AMOUNT'
  - 'DELAY_TRIGGER_THRESHOLD'
  - 'EXCLUDED_COUNTRIES'
  - 'EXCLUDED_EVENTS'
  - 'ITEMS_COVERED'
  - 'PREMIUM_BASIS'
  - 'SUB_COVER_SELECTION'
  - 'SUM_INSURED_AMOUNT'
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
