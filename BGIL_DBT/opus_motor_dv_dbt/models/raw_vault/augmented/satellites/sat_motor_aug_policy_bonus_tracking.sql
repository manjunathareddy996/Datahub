-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_POLICY_BONUS_TRACKING (parent HUB_POLICY, history SCD2), fed whole from central view stitch_motor__v14_policy.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__policy_bonus_tracking'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'PREVIOUS_BONUS_DECLARATION_SOURCE'
  - 'PREVIOUS_POLICY_CLAIM_COUNT'
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
