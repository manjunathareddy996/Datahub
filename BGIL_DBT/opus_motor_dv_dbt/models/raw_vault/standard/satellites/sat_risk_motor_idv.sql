-- Standard sat() for SAT_RISK_MOTOR_IDV (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v24_risk_object.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_motor_idv'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'AGREED_IDV'
  - 'CNG_KIT_IDV'
  - 'COMPUTED_IDV'
  - 'DEPRECIATION_PERCENTAGE'
  - 'EX_SHOWROOM_PRICE'
  - 'IDV_BASIS'
  - 'IDV_BASIS_INDICATOR'
  - 'TOTAL_IDV'
  - 'VEHICLE_AGE'
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
