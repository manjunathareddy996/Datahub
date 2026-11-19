-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_ORG_UNIT_DEFINITION (parent HUB_ORG_UNIT, history SCD2), fed whole from central view stitch_mxm__v14_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__org_unit_definition'
src_pk: 'ORG_UNIT_HKEY'
src_payload:
  - 'CLUSTER_CODE'
  - 'CLUSTER_NAME'
  - 'OFFICE_NAME_AND_ADDRESS_TEXT'
  - 'OPERATING_UNIT_LABEL'
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
