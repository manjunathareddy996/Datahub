-- Standard sat() for SAT_RISK_MOTOR_CPA (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v25_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_motor_cpa'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'COMPULSORY_PA_EFFECTIVE_DATE'
  - 'COMPULSORY_PA_EXPIRY_DATE'
  - 'COMPULSORY_PA_OWNER_DRIVER_INDICATOR'
  - 'COMPULSORY_PA_PREMIUM'
  - 'COMPULSORY_PA_SUM_INSURED'
  - 'COMPULSORY_PA_WAIVER_INDICATOR'
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
