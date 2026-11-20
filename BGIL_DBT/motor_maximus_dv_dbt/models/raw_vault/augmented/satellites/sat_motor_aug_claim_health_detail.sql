-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_HEALTH_DETAIL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_health_detail'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'DISEASE_CATEGORY'
  - 'HOSPITAL_EMAIL_ADDRESS'
  - 'ICD_CODE_DESCRIPTION'
  - 'ICD_DESCRIPTION'
  - 'MEDICAL_CLAIM_NUMBER'
  - 'MEDICAL_REVIEWER_COMMENTS'
  - 'PRE_EXISTING_DISEASE_DESCRIPTION'
  - 'PURPOSE_OF_VISIT'
  - 'SYSTEM_OF_MEDICINE'
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
