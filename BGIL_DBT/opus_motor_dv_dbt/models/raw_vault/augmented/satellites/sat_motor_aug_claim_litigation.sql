-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_LITIGATION (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v02_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__claim_litigation'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ADVISORY_COMMITTEE_REMARKS'
  - 'LITIGATION_CASE_NARRATIVE'
  - 'LONG_TAIL_DISPUTED_INDICATOR'
  - 'OMBUDSMAN_COMPLAINT_INDICATOR'
  - 'SUIT_OR_RECOVERY_INDICATOR'
  - 'SUIT_OR_RECOVERY_RECORD_INDICATOR'
  - 'THIRD_PARTY_ADVOCATE_CONTACT_NUMBER'
  - 'THIRD_PARTY_ADVOCATE_NAME'
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
