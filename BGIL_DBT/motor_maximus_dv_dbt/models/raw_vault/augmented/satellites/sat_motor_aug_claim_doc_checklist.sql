-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_CLAIM_DOC_CHECKLIST (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_doc_checklist'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'REQUIRED_DOCUMENT_TYPE_CK'
src_payload:
  - 'DOCUMENT_DETAIL_TEXT'
  - 'DOCUMENT_ISSUE_DATE'
  - 'DOCUMENT_RECEIVED_DATE'
  - 'DOCUMENT_SUBMITTED_INDICATOR'
  - 'DOCUMENT_TYPE'
  - 'FINAL_DOCUMENT_INDICATOR'
  - 'INWARD_DOCUMENT_TYPE'
  - 'OUTWARD_DOCUMENT_TYPE'
  - 'REQUIREMENT_REMARKS'
  - 'REQUIREMENT_REQUESTED_BY_REFERENCE'
  - 'REQUIREMENT_RESPONSE_TEXT'
  - 'REQUIREMENT_SOUGHT_FROM_PARTY_NAME'
  - 'REQUIREMENT_STATUS'
  - 'REQUIREMENT_TYPE_NAME'
  - 'SPECIAL_ENCLOSURES_DETAIL'
  - 'SPECIAL_ENCLOSURES_INDICATOR'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
