-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_RISK_MOTOR_IDV (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_mxm__v15_risk_object.
-- DUAL-GRAIN HUB_RISK_OBJECT: some feeders key the hub at INTEREST (policy-risk-line) grain, others at
-- object/vehicle grain. Ruled legitimate by the senior mapper; the two grains are NOT unified (BUILD_INSTRUCTIONS s3).
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__risk_motor_idv'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'BATTERY_IDV'
  - 'BODY_PRICE'
  - 'CHASSIS_PRICE'
  - 'ELECTRICAL_ACCESSORIES_IDV'
  - 'IDV_PERCENTAGE_VARIATION'
  - 'NON_ELECTRICAL_ACCESSORIES_IDV'
  - 'ORIGINAL_IDV_BEFORE_ADJUSTMENT'
  - 'REVISED_IDV'
  - 'ROAD_TAX_AMOUNT'
  - 'VEHICLE_AGE_MONTHS'
  - 'VEHICLE_INVOICE_PRICE'
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
