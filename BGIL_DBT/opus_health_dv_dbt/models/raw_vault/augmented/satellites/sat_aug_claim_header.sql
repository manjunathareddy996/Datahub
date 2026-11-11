-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CLAIM_HEADER (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v05_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_header'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CLAIM_CLOSED_INDICATOR'
  - 'CLOSED_BY_USER_REFERENCE'
  - 'CLOSURE_APPROVAL_DATE'
  - 'EXTERNAL_CLAIM_REFERENCE'
  - 'INWARD_REGISTRATION_REFERENCE'
  - 'OMNI_INWARD_REFERENCE'
  - 'ORPHAN_CLAIM_NUMBER'
  - 'ORPHAN_INTIMATION_DATE'
  - 'ORPHAN_REMARK'
  - 'REPORTED_CLAIM_AMOUNT'
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
