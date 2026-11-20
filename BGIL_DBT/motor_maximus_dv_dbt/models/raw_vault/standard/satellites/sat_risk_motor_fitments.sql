-- Standard ma_sat() for SAT_RISK_MOTOR_FITMENTS (parent HUB_RISK_OBJECT, history Multi-Active SCD2), fed whole from central view stitch_mxm__v01_assessment.
-- DUAL-GRAIN HUB_RISK_OBJECT: some feeders key the hub at INTEREST (policy-risk-line) grain, others at
-- object/vehicle grain. Ruled legitimate by the senior mapper; the two grains are NOT unified (BUILD_INSTRUCTIONS s3).
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__risk_motor_fitments'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'FITMENT_TYPE_CK'
  - 'SEQUENCE_CK'
src_payload:
  - 'FITMENT_DESCRIPTION'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
