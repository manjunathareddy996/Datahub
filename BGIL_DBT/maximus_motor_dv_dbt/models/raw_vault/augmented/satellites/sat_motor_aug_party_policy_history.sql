-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_PARTY_POLICY_HISTORY (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v04_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__party_policy_history'
src_pk:
  - 'PARTY_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'LATEST_POLICY_ISSUING_OFFICE'
  - 'LATEST_POLICY_LINE_OF_BUSINESS'
  - 'LATEST_POLICY_PRODUCT_NAME'
  - 'LATEST_POLICY_SUB_CHANNEL'
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
