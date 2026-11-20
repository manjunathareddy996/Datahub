-- Standard sat() for SAT_RISK_MOTOR_CPA (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_mxm__v01_assessment.
-- DUAL-GRAIN HUB_RISK_OBJECT: some feeders key the hub at INTEREST (policy-risk-line) grain, others at
-- object/vehicle grain. Ruled legitimate by the senior mapper; the two grains are NOT unified (BUILD_INSTRUCTIONS s3).
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__risk_motor_cpa'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'COMPULSORY_PA_EFFECTIVE_DATE'
  - 'COMPULSORY_PA_EXPIRY_DATE'
  - 'COMPULSORY_PA_OWNER_DRIVER_INDICATOR'
  - 'COMPULSORY_PA_PREMIUM'
  - 'COMPULSORY_PA_SUM_INSURED'
  - 'COMPULSORY_PA_TENURE_YEARS'
  - 'HANDICAPPED_VEHICLE_INDICATOR'
  - 'OWNER_DRIVER_LICENCE_EXISTS_INDICATOR'
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
