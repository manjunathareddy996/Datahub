-- Standard sat() for SAT_ASSESSMENT_PRE_INSPECTION (parent HUB_ASSESSMENT, history SCD2), fed whole from central view stitch_mxm__v14_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__assessment_pre_inspection'
src_pk:
  - 'ASSESSMENT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'EXISTING_DAMAGE_DESCRIPTION'
  - 'INSPECTION_DATE'
  - 'INSPECTION_LOCATION_ADDRESS'
  - 'INSPECTOR_REFERENCE'
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
