{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_COVERAGE_LIMITS (parent HUB_COVERAGE).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_coverage_limits_bjaz_trv_plan'
  - 'stg2_coverage_limits_bjaz_trv_rider_dtls'
  - 'stg2_coverage_limits_bjaz_trv_rider_rate_mast'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'DEDUCTIBLE_AMOUNT'
  - 'LIMIT_AMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_coverage_limits_bjaz_trv_plan: 'OPUS'
  stg2_coverage_limits_bjaz_trv_rider_dtls: 'OPUS'
  stg2_coverage_limits_bjaz_trv_rider_rate_mast: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map']) }}
