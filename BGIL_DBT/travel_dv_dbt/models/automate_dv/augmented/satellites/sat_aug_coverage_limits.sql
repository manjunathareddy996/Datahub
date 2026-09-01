{{ config(materialized='incremental') }}

-- TRAVEL AUGMENTED (build-side, no modeler round-trip -- see
-- docs/TRAVEL_FIXES_APPLIED.md) sat() for SAT_AUG_COVERAGE_LIMITS.
-- PROMOTE-WATCH: recurs from Health per the mapper -- promote to canonical if Motor confirms overlap.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_coverage_limits_bjaz_trv_plan_mv_currency'
  - 'stg2_aug_coverage_limits_bjaz_trv_plan_mv_deductible_desc'
  - 'stg2_aug_coverage_limits_bjaz_trv_plan_mv_limit_desc'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'CURRENCY_CODE'
  - 'DEDUCTIBLE_DESCRIPTION'
  - 'LIMIT_DESCRIPTION'
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
