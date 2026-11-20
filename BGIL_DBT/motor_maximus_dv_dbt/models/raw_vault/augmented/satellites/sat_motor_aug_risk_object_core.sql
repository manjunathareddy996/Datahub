-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_RISK_OBJECT_CORE (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_mxm__v14_risk_object.
-- DUAL-GRAIN HUB_RISK_OBJECT: some feeders key the hub at INTEREST (policy-risk-line) grain, others at
-- object/vehicle grain. Ruled legitimate by the senior mapper; the two grains are NOT unified (BUILD_INSTRUCTIONS s3).
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_RISK_OBJECT_CORE | Risk Line Serial Number | None: emits SERIAL_NO; withheld SRL_NO
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | SAT_MOTOR_AUG_RISK_OBJECT_CORE | Risk Line Serial Number | None: emits SERIAL_NO; withheld SRL_NO
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__risk_object_core'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'RISK_COVER_END_TIME'
  - 'RISK_COVER_EXPIRY_DATE'
  - 'RISK_COVER_INCEPTION_DATE'
  - 'RISK_COVER_START_TIME'
  - 'RISK_LINE_SERIAL_NUMBER'
  - 'WEATHER_EXPOSURE_SCORE'
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
