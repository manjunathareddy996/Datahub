-- Standard sat() for SAT_RISK_OBJECT_CORE (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_mxm__v14_risk_object.
-- DUAL-GRAIN HUB_RISK_OBJECT: some feeders key the hub at INTEREST (policy-risk-line) grain, others at
-- object/vehicle grain. Ruled legitimate by the senior mapper; the two grains are NOT unified (BUILD_INSTRUCTIONS s3).
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__risk_object_core'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'ACQUISITION_DATE'
  - 'EXPOSURE_UNIT'
  - 'NEW_OR_USED_INDICATOR'
  - 'OWNERSHIP_TYPE'
  - 'RISK_CLASS_CODE'
  - 'RISK_OBJECT_DESCRIPTION'
  - 'RISK_OBJECT_REFERENCE_NUMBER'
  - 'RISK_OBJECT_TYPE'
  - 'USAGE_TYPE'
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
