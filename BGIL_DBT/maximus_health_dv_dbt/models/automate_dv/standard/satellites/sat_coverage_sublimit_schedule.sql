-- Standard ma_sat() for SAT_COVERAGE_SUBLIMIT_SCHEDULE (parent HUB_COVERAGE, history Multi-Active SCD2), fed whole from central view stitch_v06_coverage.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_coverage_sublimit_schedule'
src_pk: 'COVERAGE_HKEY'
src_cdk:
  - 'ACTIVE_SEQUENCE_NUMBER_CK'
src_payload:
  - 'CAPPING_BASIS'
  - 'PER_DAY_LIMIT'
  - 'ROOM_CATEGORY_LINKAGE'
  - 'SUB_LIMIT_AMOUNT'
  - 'SUB_LIMIT_PERCENTAGE'
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
