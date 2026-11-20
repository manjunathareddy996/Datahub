-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_PROPOSAL_HEADER (parent HUB_PROPOSAL, history SCD2), fed whole from central view stitch_motor__v24_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__proposal_header'
src_pk:
  - 'PROPOSAL_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'COVER_PACKAGE_CODE'
  - 'COVER_PACKAGE_DESCRIPTION'
  - 'EXTERNAL_PARTNER_REQUEST_REFERENCE'
  - 'LEAD_REFERENCE_NUMBER'
  - 'MOTOR_WEB_SERVICE_TRANSACTION_REFERENCE'
  - 'SALES_ORDER_FORM_REFERENCE_NUMBER'
  - 'SOURCE_SYSTEM_REFERENCE_NUMBER'
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
