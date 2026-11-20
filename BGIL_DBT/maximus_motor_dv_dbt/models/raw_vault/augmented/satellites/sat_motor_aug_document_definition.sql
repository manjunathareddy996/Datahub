-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_DOCUMENT_DEFINITION (parent HUB_DOCUMENT, history SCD2), fed whole from central view stitch_mxm__v06_document.
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_DOCUMENT_DEFINITION | Courier Vendor Name | None: emits COURIER_NAME; withheld COURIERPOST_NAME
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__document_definition'
src_pk:
  - 'DOCUMENT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'COURIER_VENDOR_NAME'
  - 'DISPATCH_DATE'
  - 'DISPATCH_DESTINATION'
  - 'DISPATCH_MODE'
  - 'DISPATCH_PRIORITY'
  - 'DISPATCH_REMARKS'
  - 'DISPATCH_SERIAL_NUMBER'
  - 'DISPATCH_STATUS'
  - 'DOCUMENT_DETAIL_TEXT'
  - 'INWARD_MODE'
  - 'INWARD_REGISTRATION_DATE'
  - 'OUTWARD_DISPATCH_DATE'
  - 'OUTWARD_DOCUMENT_TYPE'
  - 'OUTWARD_REGISTRATION_NUMBER'
  - 'PROOF_OF_DELIVERY_NUMBER'
  - 'RECIPIENT_NAME'
  - 'SENDER_NAME'
  - 'SENT_TO_NAME'
  - 'SPECIAL_ENCLOSURE_DETAILS'
  - 'SPECIAL_ENCLOSURE_INDICATOR'
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
