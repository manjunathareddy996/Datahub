-- Standard sat() for SAT_RISK_PERSON_STUDENT_PA (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v11_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_person_student_pa'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'COURSE_DURATION_MONTHS'
  - 'COURSE_NAME'
  - 'INSTITUTION_ADDRESS'
  - 'INSTITUTION_NAME'
  - 'SEMESTER_NUMBER'
  - 'STUDENT_FITNESS_STATUS'
  - 'TUITION_FEE_AMOUNT'
  - 'TUITION_FEE_PAYER'
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
