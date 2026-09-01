{{ config(materialized='incremental') }}

-- TRAVEL AUGMENTED (build-side, no modeler round-trip -- see
-- docs/TRAVEL_FIXES_APPLIED.md) sat() for SAT_AUG_COVERAGE_DEFINITION.
-- PROMOTE-WATCH: recurs from Health per the mapper -- promote to canonical if Motor confirms overlap.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_coverage_definition_bjaz_trv_plan_mv_eff_date'
  - 'stg2_aug_coverage_definition_bjaz_trv_plan_mv_sequence_covers'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'COVERAGE_SEQUENCE'
  - 'EFFECTIVE_DATE'
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
