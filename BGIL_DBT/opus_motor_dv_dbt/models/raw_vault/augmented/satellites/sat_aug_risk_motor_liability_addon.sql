-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_RISK_MOTOR_LIABILITY_ADDON (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v25_risk_object.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_motor_liability_addon'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'LEGAL_LIABILITY_CLEANER_INDICATOR'
  - 'LEGAL_LIABILITY_CLEANER_PREMIUM'
  - 'LEGAL_LIABILITY_CONDUCTOR_INDICATOR'
  - 'LEGAL_LIABILITY_CONDUCTOR_PREMIUM'
  - 'LEGAL_LIABILITY_HELPER_INDICATOR'
  - 'LEGAL_LIABILITY_HELPER_PREMIUM'
  - 'LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_INDICATOR'
  - 'LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_PREMIUM'
  - 'PA_CLEANER_INDICATOR'
  - 'PA_CLEANER_PREMIUM'
  - 'PA_CONDUCTOR_INDICATOR'
  - 'PA_CONDUCTOR_PREMIUM'
  - 'PA_EMPLOYEE_OCCUPANT_SUM_INSURED'
  - 'PA_HELPER_INDICATOR'
  - 'PA_HELPER_PREMIUM'
  - 'PA_PAID_DRIVER_PREMIUM'
  - 'PA_PILLION_RIDER_PREMIUM'
  - 'PA_UNNAMED_DRIVER_PREMIUM'
  - 'PA_UNNAMED_PASSENGER_COUNT'
  - 'PA_UNNAMED_PASSENGER_INDICATOR'
  - 'PA_UNNAMED_PASSENGER_SUM_INSURED_PER_PERSON'
  - 'PA_UNNAMED_PERSON_PREMIUM'
  - 'THIRD_PARTY_PROPERTY_DAMAGE_RESTRICTED_INDICATOR'
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
