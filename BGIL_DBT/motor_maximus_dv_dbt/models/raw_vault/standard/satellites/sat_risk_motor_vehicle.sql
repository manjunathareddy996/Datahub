-- Standard sat() for SAT_RISK_MOTOR_VEHICLE (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_mxm__v15_risk_object.
-- DUAL-GRAIN HUB_RISK_OBJECT: some feeders key the hub at INTEREST (policy-risk-line) grain, others at
-- object/vehicle grain. Ruled legitimate by the senior mapper; the two grains are NOT unified (BUILD_INSTRUCTIONS s3).
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Manufacturing Year | None: emits YEAR_OF_MANUFACTURE; withheld YEAR_OF_MANUFACTURE_SCPA
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Body Type | None: emits BODY_TYPE; withheld TYPE_OF_BODY
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Vehicle Sub Class | None: emits VEHICLE_SUBTYPE; withheld VEHICLE_SUB_TYPE
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Manufacturing Year | None: emits YEAR_OF_MANUFACTURING; withheld YOM_STORE
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Registration Number | None: emits REGISTRATION_NO; withheld REGISTRATION_NUMBER
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Vehicle Sub Class | None: emits VEHICLE_SUBTYPE; withheld SUBTYPE_STORE
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Manufacturing Year | None: emits YEAR_OF_MANUFACTURING; withheld YOM_STORE
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Registration Number | None: emits REGISTRATION_NO; withheld REGISTRATION_NUMBER
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Vehicle Sub Class | None: emits VEHICLE_SUBTYPE; withheld SUBTYPE_STORE
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Body Type | None: emits BODY_TYPE; withheld TYPE_OF_BODY
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | SAT_RISK_MOTOR_VEHICLE | Vehicle Sub Class | None: emits VEHICLE_SUBTYPE; withheld VEHICLE_SUB_TYPE
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__risk_motor_vehicle'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'ANTI_THEFT_DEVICE_INDICATOR'
  - 'BATTERY_CAPACITY'
  - 'BODY_TYPE'
  - 'CARRYING_CAPACITY'
  - 'CNG_LPG_KIT_INDICATOR'
  - 'COLOUR'
  - 'CUBIC_CAPACITY'
  - 'ENGINE_NUMBER'
  - 'FUEL_TYPE'
  - 'GROSS_VEHICLE_WEIGHT'
  - 'HORSEPOWER'
  - 'MAKE'
  - 'MANUFACTURING_YEAR'
  - 'MODEL'
  - 'ODOMETER_READING'
  - 'PERMIT_TYPE'
  - 'REGISTRATION_DATE'
  - 'REGISTRATION_NUMBER'
  - 'REGISTRATION_TYPE'
  - 'RTO_CODE'
  - 'RTO_NAME'
  - 'SEATING_CAPACITY'
  - 'TRAILER_COUNT'
  - 'VARIANT'
  - 'VEHICLE_CATEGORY_CODE'
  - 'VEHICLE_CLASS'
  - 'VEHICLE_SEGMENT'
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
