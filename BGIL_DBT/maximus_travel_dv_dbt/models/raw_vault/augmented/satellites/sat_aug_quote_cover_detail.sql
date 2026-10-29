{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat() for SAT_AUG_QUOTE_COVER_DETAIL.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, QUOTE_HKEY, multi-active on COVERAGE_REFERENCE, COVERAGE_SEQUENCE.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_quote_cover_detail'
src_pk: 'QUOTE_HKEY'
src_cdk:
  - 'COVERAGE_REFERENCE'
  - 'COVERAGE_SEQUENCE'
src_payload:
  - 'BENEFIT_UNIT_IN_HOURS'
  - 'COVER_PERIOD'
  - 'COVER_PREMIUM_AMOUNT'
  - 'COVER_PREMIUM_AMOUNT_IN_BASE_CURRENCY'
  - 'COVER_SUM_INSURED'
  - 'COVER_SUM_INSURED_ACE_VARIANT'
  - 'COVER_SUM_INSURED_FOR_ABROAD_IN_USD'
  - 'COVER_SUM_INSURED_FOR_INDIA_IN_INR'
  - 'PAYOUT_OPTION'
  - 'PRIOR_COVER_PREMIUM_AMOUNT'
  - 'SUB_LIMIT_DETAIL'
  - 'SUM_INSURED_BREAK_UP_DETAIL'
  - 'SUM_INSURED_PER_UNIT'
  - 'TOTAL_COVER_SUM_INSURED'
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
