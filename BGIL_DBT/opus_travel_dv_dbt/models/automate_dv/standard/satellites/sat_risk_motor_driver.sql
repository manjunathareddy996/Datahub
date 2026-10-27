{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_RISK_MOTOR_DRIVER (parent HUB_RISK_OBJECT).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_risk_motor_driver_bjaz_trv_loader_log_table_mv'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'OWNER_DRIVER_INDICATOR'
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
