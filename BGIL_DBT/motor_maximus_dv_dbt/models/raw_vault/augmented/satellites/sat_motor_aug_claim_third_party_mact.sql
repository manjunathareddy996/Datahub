-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_THIRD_PARTY_MACT (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v09_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_third_party_mact'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME'
  - 'FIXED_DEPOSIT_RECEIPT_TENURE'
  - 'INTEREST_APPLICABLE_INDICATOR'
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
