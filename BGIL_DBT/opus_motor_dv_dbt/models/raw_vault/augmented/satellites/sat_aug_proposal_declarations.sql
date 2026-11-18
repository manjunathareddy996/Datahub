-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PROPOSAL_DECLARATIONS (parent HUB_PROPOSAL, history SCD2), fed whole from central view stitch_motor__v24_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__proposal_declarations'
src_pk: 'PROPOSAL_HKEY'
src_payload:
  - 'EXISTING_MOTOR_POLICY_NUMBER'
  - 'EXISTING_NON_MOTOR_POLICY_INDICATOR'
  - 'EXISTING_NON_MOTOR_POLICY_NUMBER'
  - 'PREVIOUS_OWN_DAMAGE_CLAIM_AMOUNT'
  - 'PREVIOUS_OWN_DAMAGE_CLAIM_COUNT'
  - 'PREVIOUS_THEFT_CLAIM_INDICATOR'
  - 'PREVIOUS_THIRD_PARTY_CLAIM_AMOUNT'
  - 'PREVIOUS_THIRD_PARTY_CLAIM_COUNT'
  - 'PREVIOUS_TOTAL_LOSS_CLAIM_INDICATOR'
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
