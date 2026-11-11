-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_DOCUMENT_DEFINITION (parent HUB_DOCUMENT, history SCD2), fed whole from central view stitch_v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_document_definition'
src_pk: 'DOCUMENT_HKEY'
src_payload:
  - 'COURIER_PROOF_OF_DELIVERY_NUMBER'
  - 'SECONDARY_DOCUMENT_TYPE'
  - 'SENDER_DESPATCH_REFERENCE_NUMBER'
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
