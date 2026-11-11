-- Standard sat() for SAT_CLAIM_HEADER (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v07_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_claim_header'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CLAIM_CATEGORY'
  - 'CLAIM_REFERENCE_NUMBER'
  - 'CLAIM_REMARKS'
  - 'CLAIM_STATUS'
  - 'CLAIM_SUB_STATUS'
  - 'CLAIM_TYPE'
  - 'CLOSED_DATE'
  - 'GROSS_INCURRED_AMOUNT'
  - 'LOSS_DATE'
  - 'NET_INCURRED_AMOUNT'
  - 'NOTIFICATION_DATE'
  - 'POLICY_REFERENCE'
  - 'REGISTRATION_DATE'
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
