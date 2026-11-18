-- Standard sat() for SAT_RISK_MOTOR_LIABILITY_ADDON (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v06_distribution_channel.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_motor_liability_addon'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'LEGAL_LIABILITY_CLEANER_COUNT'
  - 'LEGAL_LIABILITY_CONDUCTOR_COUNT'
  - 'LEGAL_LIABILITY_HELPER_COUNT'
  - 'LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_COUNT'
  - 'LEGAL_LIABILITY_OTHER_EMPLOYEE_COUNT'
  - 'LEGAL_LIABILITY_OTHER_EMPLOYEE_INDICATOR'
  - 'LEGAL_LIABILITY_OTHER_EMPLOYEE_PREMIUM'
  - 'LEGAL_LIABILITY_PAID_DRIVER_COUNT'
  - 'LEGAL_LIABILITY_PAID_DRIVER_INDICATOR'
  - 'LEGAL_LIABILITY_PAID_DRIVER_PREMIUM'
  - 'LEGAL_LIABILITY_UNNAMED_PASSENGER_COUNT'
  - 'LEGAL_LIABILITY_UNNAMED_PASSENGER_INDICATOR'
  - 'LEGAL_LIABILITY_UNNAMED_PASSENGER_PREMIUM'
  - 'PA_CLEANER_COUNT'
  - 'PA_CONDUCTOR_COUNT'
  - 'PA_HELPER_COUNT'
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
