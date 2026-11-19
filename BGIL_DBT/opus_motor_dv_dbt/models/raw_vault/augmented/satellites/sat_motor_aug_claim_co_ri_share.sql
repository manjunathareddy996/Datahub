-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_CO_RI_SHARE (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__claim_co_ri_share'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CO_INSURANCE_RECOVERY_AMOUNT'
  - 'REINSURANCE_ENDORSEMENT_NUMBER'
  - 'REINSURANCE_EXPIRY_DATE'
  - 'REINSURANCE_PREMIUM_AMOUNT'
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
