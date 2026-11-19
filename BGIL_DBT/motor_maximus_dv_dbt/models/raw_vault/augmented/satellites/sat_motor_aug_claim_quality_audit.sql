-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_QUALITY_AUDIT (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_quality_audit'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'AUDIT_FLAG_INDICATOR'
  - 'PUBLISH_REVIEWER_COMMENTS_EXTERNALLY_INDICATOR'
  - 'PUBLISH_REVIEWER_COMMENTS_EXTERNALLY_INDICATOR_AT_ASSESSMENT'
  - 'REWARD_AND_RECOGNITION_FLAG_INDICATOR'
  - 'SCRUTINY_REMARKS'
  - 'SCRUTINY_STATUS'
  - 'VENDOR_SCORE'
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
