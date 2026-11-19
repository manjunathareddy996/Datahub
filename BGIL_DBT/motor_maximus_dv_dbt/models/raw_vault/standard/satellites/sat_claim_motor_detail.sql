-- Standard sat() for SAT_CLAIM_MOTOR_DETAIL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW | SAT_CLAIM_MOTOR_DETAIL | Driver Type | None: emits WHO_WAS_DRIVING; withheld WHO_WAS_DRIVING_
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW | SAT_CLAIM_MOTOR_DETAIL | Third Party Claim Indicator | None: emits TP_INVOLVEMENT_; withheld DO_YOU_WANT_THIRD_PARTY_INVOLVEMNT
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__claim_motor_detail'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ACCIDENT_TIME'
  - 'ACCIDENT_TYPE'
  - 'DAMAGE_DESCRIPTION'
  - 'DAMAGE_TYPE'
  - 'DRIVER_LICENCE_NUMBER'
  - 'DRIVER_LICENCE_VALID_INDICATOR'
  - 'DRIVER_NAME'
  - 'DRIVER_TYPE'
  - 'GARAGE_REFERENCE'
  - 'REPAIR_ESTIMATE_AMOUNT'
  - 'REPAIR_ESTIMATE_DATE'
  - 'ROAD_ASSISTANCE_USED_INDICATOR'
  - 'SPOT_SURVEY_INDICATOR'
  - 'THIRD_PARTY_CLAIM_INDICATOR'
  - 'VEHICLE_LEFT_AT_REPAIRER_INDICATOR'
  - 'VEHICLE_LOADED_INDICATOR'
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
