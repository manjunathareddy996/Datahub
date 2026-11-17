-- Standard sat() for SAT_CLAIM_MOTOR_DETAIL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v03_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__claim_motor_detail'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ACCIDENT_TIME'
  - 'DAMAGED_PARTS_DESCRIPTION'
  - 'DAMAGE_DESCRIPTION'
  - 'DAMAGE_TYPE'
  - 'DRIVER_LICENCE_NUMBER'
  - 'DRIVER_NAME'
  - 'DRIVER_TYPE'
  - 'ENGINE_DAMAGE_INDICATOR'
  - 'ESTIMATED_LABOUR_AMOUNT'
  - 'ESTIMATED_OTHER_COST_AMOUNT'
  - 'ESTIMATED_PARTS_AMOUNT'
  - 'FIBRE_PARTS_AMOUNT'
  - 'GARAGE_REFERENCE'
  - 'GLASS_PARTS_AMOUNT'
  - 'IDV_AMOUNT'
  - 'INVALID_CARRIAGE_INDICATOR'
  - 'LABOUR_AMOUNT'
  - 'PAINT_AMOUNT'
  - 'REPAIR_ESTIMATE_AMOUNT'
  - 'REPAIR_ESTIMATE_DATE'
  - 'REPAIR_ESTIMATE_REFERENCE'
  - 'THIRD_PARTY_CLAIM_INDICATOR'
  - 'TOTAL_LOSS_INDICATOR'
  - 'TYRE_DAMAGE_INDICATOR'
  - 'VEHICLE_LEFT_AT_REPAIRER_INDICATOR'
  - 'VEHICLE_LOADED_INDICATOR'
  - 'VEHICLE_PARKED_INDICATOR'
  - 'WHEEL_RIM_DAMAGE_INDICATOR'
  - 'WINDSHIELD_DAMAGE_CODE'
  - 'WORKSHOP_REPAIR_STATUS'
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
