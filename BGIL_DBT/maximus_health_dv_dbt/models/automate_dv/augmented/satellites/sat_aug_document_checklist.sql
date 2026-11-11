-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_DOCUMENT_CHECKLIST (parent HUB_DOCUMENT, history SCD2), fed whole from central view stitch_v07_document.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_document_checklist'
src_pk: 'DOCUMENT_HKEY'
src_cdk:
  - 'REQUIRED_DOCUMENT_TYPE_CK'
src_payload:
  - 'DOCUMENT_BELONGS_TO_PARTY_ROLE'
  - 'REQUIRED_FROM_PARTY_ROLE'
  - 'REQUIREMENT_RAISED_BY_REFERENCE'
  - 'REQUIREMENT_RAISED_DATE'
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
