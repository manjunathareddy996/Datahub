-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_RISK_MOTOR_VEHICLE (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v26_risk_object.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_motor_vehicle'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'CARRIER_TYPE'
  - 'HOUR_METER_READING'
  - 'INSURER_VEHICLE_CODE'
  - 'INSURER_VEHICLE_MASTER_CODE'
  - 'INTERNAL_VEHICLE_CODE'
  - 'MISCELLANEOUS_VEHICLE_CLASS_CODE'
  - 'MISCELLANEOUS_VEHICLE_TYPE'
  - 'MISCELLANEOUS_VEHICLE_TYPE_CODE'
  - 'MOTOR_RATING_ZONE'
  - 'NEW_INSURER_VEHICLE_CODE_LIST'
  - 'NEW_INTERNAL_VEHICLE_CODE_LIST'
  - 'ORIGINAL_INSURER_VEHICLE_CODE'
  - 'ORIGINAL_INSURER_VEHICLE_CODE_LIST'
  - 'ORIGINAL_INTERNAL_VEHICLE_CODE'
  - 'ORIGINAL_INTERNAL_VEHICLE_CODE_LIST'
  - 'OTHER_STATE_REGISTRATION_INDICATOR'
  - 'OWN_PREMISES_USE_INDICATOR'
  - 'PRE_EXISTING_DAMAGE_DESCRIPTION'
  - 'PUC_CERTIFICATE_VALID_INDICATOR'
  - 'RATING_ZONE_CODE'
  - 'REGISTRATION_CITY'
  - 'REGISTRATION_LOCATION_OTHER_TEXT'
  - 'REGISTRATION_RECORDED_POLICY_NUMBER'
  - 'REGISTRATION_STATUS'
  - 'REGISTRATION_YEAR'
  - 'SECONDARY_MOTOR_NUMBER'
  - 'TARIFF_PASSENGER_RANGE'
  - 'VEHICLE_DELIVERY_DATE'
  - 'VEHICLE_INVOICE_DATE'
  - 'VEHICLE_KEY_COUNT'
  - 'VEHICLE_MASTER_CODE'
  - 'VEHICLE_TYPE_CODE'
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
