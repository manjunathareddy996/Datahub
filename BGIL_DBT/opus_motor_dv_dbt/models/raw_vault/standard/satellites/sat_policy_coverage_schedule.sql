-- Standard ma_sat() for SAT_POLICY_COVERAGE_SCHEDULE (parent HUB_POLICY, history Multi-Active SCD2), fed whole from central view stitch_motor__v05_coverage.
-- GRAIN_UNRATIFIED (P-2): emitted as the map states. Self-named child-key blocks here write several
-- attributes of ONE entity, shredding it into child rows. Not ratified as a grain change; routed to the modeller.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__policy_coverage_schedule'
src_pk:
  - 'POLICY_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'COVERAGE_REFERENCE_CK'
  - 'COVERAGE_SEQUENCE_CK'
src_payload:
  - 'COVERAGE_OPTED_INDICATOR'
  - 'COVERAGE_SEQUENCE'
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
