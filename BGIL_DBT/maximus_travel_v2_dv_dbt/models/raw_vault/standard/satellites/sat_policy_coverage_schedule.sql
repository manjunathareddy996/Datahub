{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 ma_sat() for SAT_POLICY_COVERAGE_SCHEDULE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, POLICY_HKEY, multi-active on COVERAGE_REFERENCE, COVERAGE_SEQUENCE.

{%- set yaml_metadata -%}
source_model: 'satfeed_mtv2_sat_policy_coverage_schedule'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'COVERAGE_REFERENCE'
  - 'COVERAGE_SEQUENCE'
src_payload:
  - 'COVERAGE_END_DATE'
  - 'COVERAGE_OPTED_INDICATOR'
  - 'COVERAGE_START_DATE'
  - 'CO_PAYMENT_PERCENTAGE'
  - 'DEDUCTIBLE_AMOUNT'
  - 'LIMIT_AMOUNT'
  - 'PREMIUM_FOR_COVERAGE'
  - 'SUM_INSURED'
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
