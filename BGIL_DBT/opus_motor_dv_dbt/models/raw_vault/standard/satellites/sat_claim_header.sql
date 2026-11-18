-- Standard sat() for SAT_CLAIM_HEADER (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v02_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__claim_header'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CLAIM_EXAMINER_REFERENCE'
  - 'CLAIM_HANDLER_REFERENCE'
  - 'CLAIM_REFERENCE_NUMBER'
  - 'CLAIM_REMARKS'
  - 'CLAIM_SUB_STATUS'
  - 'CLAIM_TYPE'
  - 'CLOSED_DATE'
  - 'FAST_TRACK_INDICATOR'
  - 'HANDLING_ORG_UNIT_CODE'
  - 'INTIMATED_BY_ROLE'
  - 'INTIMATION_CHANNEL'
  - 'LOSS_DATE'
  - 'NOTIFICATION_DATE'
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
