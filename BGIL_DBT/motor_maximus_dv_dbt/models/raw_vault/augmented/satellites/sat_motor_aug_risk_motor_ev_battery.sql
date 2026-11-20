-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_RISK_MOTOR_EV_BATTERY (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_mxm__v15_risk_object.
-- DUAL-GRAIN HUB_RISK_OBJECT: some feeders key the hub at INTEREST (policy-risk-line) grain, others at
-- object/vehicle grain. Ruled legitimate by the senior mapper; the two grains are NOT unified (BUILD_INSTRUCTIONS s3).
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__risk_motor_ev_battery'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'BATTERY_SERIAL_NUMBER_CK'
src_payload:
  - 'BATTERY_AGE'
  - 'BATTERY_CELL_COUNT'
  - 'BATTERY_CHARGING_HOURS'
  - 'BATTERY_CHEMISTRY_TYPE'
  - 'BATTERY_CLAIM_HISTORY_TEXT'
  - 'BATTERY_GPS_FITTED_INDICATOR'
  - 'BATTERY_LEASED_INDICATOR'
  - 'BATTERY_LEASE_DETAIL'
  - 'BATTERY_MAKE'
  - 'BATTERY_MANUFACTURING_DATE'
  - 'BATTERY_MODEL'
  - 'BATTERY_NEW_OR_USED_INDICATOR'
  - 'BATTERY_POWER_RATING'
  - 'BATTERY_PRIOR_CLAIM_COUNT'
  - 'BATTERY_SERIAL_NUMBER'
  - 'BATTERY_TYPE'
  - 'BATTERY_WARRANTY_STATUS'
  - 'BATTERY_WEIGHT'
  - 'CENTRAL_SYSTEM_CONNECTIVITY_INDICATOR'
  - 'CHARGER_CURRENT_TYPE'
  - 'CHARGING_AREA_INFRASTRUCTURE_TYPE'
  - 'CHARGING_INFRASTRUCTURE_AVAILABILITY_TYPE'
  - 'CHARGING_INFRASTRUCTURE_OWNERSHIP_TYPE'
  - 'CHARGING_POINT_POWER_FLUCTUATION'
  - 'OPERATING_TEMPERATURE_ZONE'
  - 'SINGLE_CHARGE_RANGE_KILOMETRES'
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
