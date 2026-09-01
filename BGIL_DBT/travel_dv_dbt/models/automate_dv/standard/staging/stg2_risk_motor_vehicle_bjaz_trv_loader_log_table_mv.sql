{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_RISK_MOTOR_VEHICLE, table 'BJAZ_TRV_LOADER_LOG_TABLE_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  RISK_OBJECT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUBIC_CAPACITY'
      - 'CHASSIS_NUMBER'
      - 'ENGINE_NUMBER'
      - 'MAKE'
      - 'MODEL'
      - 'REGISTRATION_NUMBER'
      - 'SEATING_CAPACITY'
      - 'VEHICLE_SUB_CLASS'
      - 'MANUFACTURING_YEAR'
derived_columns:
  PARENT_BK: 'policynumber'
  PARENT_NK: "'HUB_RISK_OBJECT|' || (policynumber)"
  CUBIC_CAPACITY: 'cc'
  CHASSIS_NUMBER: 'chassisno'
  ENGINE_NUMBER: 'engineno'
  MAKE: 'make'
  MODEL: 'model'
  REGISTRATION_NUMBER: 'registrationno'
  SEATING_CAPACITY: 'seatingcapacity'
  VEHICLE_SUB_CLASS: 'subtype'
  MANUFACTURING_YEAR: 'yearofmfg'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
