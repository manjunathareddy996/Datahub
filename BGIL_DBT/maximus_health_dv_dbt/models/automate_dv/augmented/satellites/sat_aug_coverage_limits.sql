-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_COVERAGE_LIMITS (parent HUB_COVERAGE, history SCD2), fed whole from central view stitch_v06_coverage.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_coverage_limits'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'INDEMNITY_PERIOD_DAYS'
  - 'LIMIT_APPLICABILITY_BASIS'
  - 'MAXIMUM_INDEMNITY_PERIOD_DAYS'
  - 'POST_HOSPITALISATION_PERIOD'
  - 'PRE_HOSPITALISATION_PERIOD'
  - 'REINSTATED_SUM_INSURED_AMOUNT'
  - 'REINSTATEMENT_COUNT'
  - 'REINSTATEMENT_COUNT_AKL_VARIANT'
  - 'RESTORATION_APPLIED_INDICATOR'
  - 'RESTORATION_DATE'
  - 'RESTORATION_REQUIRED_INDICATOR'
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
