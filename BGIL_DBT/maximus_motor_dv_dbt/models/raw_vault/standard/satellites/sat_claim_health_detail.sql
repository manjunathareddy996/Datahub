-- Standard sat() for SAT_CLAIM_HEALTH_DETAIL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__claim_health_detail'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'ADMISSION_DATE'
  - 'AILMENT_DESCRIPTION'
  - 'DISCHARGE_DATE'
  - 'HEALTH_CLAIM_REMARKS'
  - 'ICD_CODE'
  - 'PRE_EXISTING_DISEASE_RELATED_INDICATOR'
  - 'TREATING_DOCTOR_NAME'
  - 'TREATMENT_TYPE'
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
