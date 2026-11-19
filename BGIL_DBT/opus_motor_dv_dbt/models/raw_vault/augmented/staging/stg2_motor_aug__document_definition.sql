-- automate_dv.stage() for SAT_MOTOR_AUG_DOCUMENT_DEFINITION, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INVOICE_PRESENT_INDICATOR'
      - 'OCR_ACCEPTED_DATE'
      - 'OCR_APPROVED_DATE'
      - 'OCR_PROCESSING_FLAG'
      - 'OCR_REQUEST_REFERENCE'
      - 'OCR_SENT_DATE'
derived_columns:
  DOCUMENT_NK: "case when coalesce(AUG_DOCUMENT_DEFINITION__INVOICE_PRESENT_INDICATOR, AUG_DOCUMENT_DEFINITION__OCR_ACCEPTED_DATE, AUG_DOCUMENT_DEFINITION__OCR_APPROVED_DATE, AUG_DOCUMENT_DEFINITION__OCR_PROCESSING_FLAG, AUG_DOCUMENT_DEFINITION__OCR_REQUEST_REFERENCE, AUG_DOCUMENT_DEFINITION__OCR_SENT_DATE) is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  INVOICE_PRESENT_INDICATOR: 'AUG_DOCUMENT_DEFINITION__INVOICE_PRESENT_INDICATOR'
  OCR_ACCEPTED_DATE: 'AUG_DOCUMENT_DEFINITION__OCR_ACCEPTED_DATE'
  OCR_APPROVED_DATE: 'AUG_DOCUMENT_DEFINITION__OCR_APPROVED_DATE'
  OCR_PROCESSING_FLAG: 'AUG_DOCUMENT_DEFINITION__OCR_PROCESSING_FLAG'
  OCR_REQUEST_REFERENCE: 'AUG_DOCUMENT_DEFINITION__OCR_REQUEST_REFERENCE'
  OCR_SENT_DATE: 'AUG_DOCUMENT_DEFINITION__OCR_SENT_DATE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
