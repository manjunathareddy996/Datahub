-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_COMMON_ADDRESS (parent HUB_LOCATION, history SCD2), fed whole from central view stitch_motor__v08_org_unit.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__common_address'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'ADDRESS_LINE4'
  - 'ADDRESS_LINE_5'
  - 'CITY_OTHER_TEXT'
  - 'FULL_ADDRESS_TEXT'
  - 'LOCALITY_OTHER_TEXT'
  - 'SAME_AS_RISK_ADDRESS_INDICATOR'
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
