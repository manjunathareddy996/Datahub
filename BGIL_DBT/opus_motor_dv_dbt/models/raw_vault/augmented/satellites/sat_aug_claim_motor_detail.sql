-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CLAIM_MOTOR_DETAIL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v01_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__claim_motor_detail'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CHASSIS_DAMAGE_INDICATOR'
  - 'DAMAGED_TYRE_COUNT'
  - 'DAMAGE_CAPTURE_DEVICE_SOURCE'
  - 'DENTING_AMOUNT'
  - 'DEVICE_MAKE_AND_MODEL'
  - 'DEVICE_SERIAL_NUMBER'
  - 'DRIVER_LICENCE_EXPIRY_DATE'
  - 'DRIVER_LICENCE_ISSUE_DATE'
  - 'DRIVER_LICENCE_TYPE'
  - 'DRIVER_NAME_VERIFIED_INDICATOR'
  - 'DRIVER_RELATIONSHIP_TO_INSURED'
  - 'FAULT_ATTRIBUTED_TO_PARTY'
  - 'FAULT_ATTRIBUTED_TO_ROLE'
  - 'FIRE_DAMAGE_INDICATOR'
  - 'FRONT_DAMAGE_CODE'
  - 'FUEL_TANK_DAMAGE_INDICATOR'
  - 'GOODS_TYPE_CARRIED'
  - 'INSPECTION_LOCATION_TEXT'
  - 'INSURED_VEHICLE_INTERNAL_REFERENCE'
  - 'INSURED_VEHICLE_INTERNAL_VERSION'
  - 'JOURNEY_DESTINATION_CITY'
  - 'JOURNEY_ORIGIN_CITY'
  - 'KILOMETRE_LIMIT'
  - 'LEFT_SIDE_DAMAGE_CODE'
  - 'METAL_PARTS_AMOUNT'
  - 'MISCELLANEOUS_ASSESSED_AMOUNT'
  - 'ODOMETER_DISCREPANCY_REASON'
  - 'ODOMETER_READING_AT_LOSS'
  - 'OWN_REPAIRER_INDICATOR'
  - 'PARTIAL_THEFT_INDICATOR'
  - 'PLASTIC_PARTS_AMOUNT'
  - 'REAR_DAMAGE_CODE'
  - 'REAR_GLASS_DAMAGE_CODE'
  - 'REPAIR_INVOICE_NUMBER'
  - 'RIGHT_SIDE_DAMAGE_CODE'
  - 'RIM_WITH_TYRE_DAMAGE_INDICATOR'
  - 'ROLL_OVER_DAMAGE_CODE'
  - 'ROOF_DAMAGE_CODE'
  - 'SILENCER_DAMAGE_INDICATOR'
  - 'SPOT_SURVEY_UPDATE_TEXT'
  - 'SURVEYOR_UPDATE_TEXT'
  - 'TRAFFIC_CHALLAN_DATE'
  - 'TRAFFIC_CHALLAN_DETAILS'
  - 'TYRE_DAMAGE_CODE'
  - 'UNCLASSIFIED_DAMAGE_CODE'
  - 'UNDERSIDE_DAMAGE_CODE'
  - 'VEHICLE_INSPECTION_CARRIED_OUT_INDICATOR'
  - 'VEHICLE_LYING_LOCATION_TEXT'
  - 'WATER_FLOOD_DAMAGE_INDICATOR'
  - 'WEIGHT_CARRIED_AT_LOSS'
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
