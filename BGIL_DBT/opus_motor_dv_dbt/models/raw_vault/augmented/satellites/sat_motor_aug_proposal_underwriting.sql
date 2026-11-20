-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_PROPOSAL_UNDERWRITING (parent HUB_PROPOSAL, history SCD2), fed whole from central view stitch_motor__v09_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__proposal_underwriting'
src_pk:
  - 'PROPOSAL_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'DRIVING_OFFENCE_SCORE'
  - 'MANUAL_APPROVAL_INDICATOR'
  - 'PARTIAL_LOSS_PROPENSITY_SCORE'
  - 'PINCODE_ELIGIBILITY_CONDITION'
  - 'REFERRED_BY_REFERENCE'
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
