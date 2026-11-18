-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PRODUCT_DISTRIBUTION_RULES (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_motor__v06_distribution_channel.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__product_distribution_rules'
src_pk: 'PRODUCT_HKEY'
src_payload:
  - 'RTA_CONFIGURATION_RULE_TYPE'
  - 'RTA_CONFIGURATION_VEHICLE_TYPE_CODE'
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
