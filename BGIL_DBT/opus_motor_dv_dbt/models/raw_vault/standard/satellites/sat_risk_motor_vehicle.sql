-- Standard sat() for SAT_RISK_MOTOR_VEHICLE (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v26_risk_object.
-- SINGLE WRITER (G-3) BA_QUOTE_MOT_DTLS | SAT_RISK_MOTOR_VEHICLE | Registration Number | None: emits VEHICLE_REG_NO; withheld REG_NO_PART1, REG_NO_PART2, REG_NO_PART3, REG_NO_PART4
-- SINGLE WRITER (G-3) BJAZ_SCR_MOT_VEH_DTLS | SAT_RISK_MOTOR_VEHICLE | Registration Number | None: emits REGISTRATION_NO; withheld REG_NO_PART1, REG_NO_PART2, REG_NO_PART3, REG_NO_PART4
-- SINGLE WRITER (G-3) BJAZ_WAP_MOT_ADD_QSTN_DTLS | SAT_RISK_MOTOR_VEHICLE | Odometer Reading | None: emits KM_READING; withheld ODMETER
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_motor_vehicle'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'ANTI_THEFT_DEVICE_INDICATOR'
  - 'ASSOCIATION_MEMBERSHIP_EXPIRY_DATE'
  - 'ASSOCIATION_MEMBERSHIP_INDICATOR'
  - 'ASSOCIATION_MEMBERSHIP_NUMBER'
  - 'BH_REGISTRATION_INDICATOR'
  - 'BODY_TYPE'
  - 'CARRYING_CAPACITY'
  - 'CHASSIS_NUMBER'
  - 'CNG_LPG_KIT_VALUE'
  - 'COLOUR'
  - 'CUBIC_CAPACITY'
  - 'DRIVEN_BY_TYPE'
  - 'ENGINE_NUMBER'
  - 'FUEL_TYPE'
  - 'GROSS_VEHICLE_WEIGHT'
  - 'HYPOTHECATION_BANK_NAME'
  - 'MAKE'
  - 'MAKE_CODE'
  - 'MANUFACTURING_YEAR'
  - 'MODEL'
  - 'MODEL_CODE'
  - 'ODOMETER_READING'
  - 'REGISTRATION_DATE'
  - 'REGISTRATION_NUMBER'
  - 'REGISTRATION_TYPE'
  - 'RTO_CODE'
  - 'RTO_NAME'
  - 'TRAILER_COUNT'
  - 'TRANSMISSION_TYPE'
  - 'VARIANT'
  - 'VARIANT_CODE'
  - 'VEHICLE_CATEGORY_CODE'
  - 'VEHICLE_CLASS'
  - 'VEHICLE_INVOICE_NUMBER'
  - 'VEHICLE_SUB_CATEGORY'
  - 'VEHICLE_SUB_CLASS'
  - 'VEHICLE_USAGE'
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
