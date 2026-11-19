-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_PA_DETAIL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_pa_detail'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CAUSE_OF_LOSS'
  - 'INJURY_CATEGORY'
  - 'INJURY_OR_DEATH_CLASSIFICATION'
  - 'PA_CLAIM_INDICATOR'
  - 'PERSONAL_ACCIDENT_CLAIM_FOR'
  - 'SCALE_OF_COMPENSATION'
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
