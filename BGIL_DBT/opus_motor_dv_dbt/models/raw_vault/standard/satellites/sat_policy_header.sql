-- Standard sat() for SAT_POLICY_HEADER (parent HUB_POLICY, history SCD2), fed whole from central view stitch_motor__v16_policy.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__policy_header'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'CONVERSION_FROM_QUOTE_INDICATOR'
  - 'COVER_NOTE_REFERENCE'
  - 'ISSUE_DATE'
  - 'ISSUING_CHANNEL_REFERENCE'
  - 'ISSUING_ORG_UNIT_CODE'
  - 'MASTER_POLICY_REFERENCE'
  - 'NUMBER_OF_LIVES_COVERED'
  - 'POLICY_CHANNEL_TYPE'
  - 'POLICY_NUMBER'
  - 'POLICY_REFERENCE_NUMBER'
  - 'POLICY_REMARKS'
  - 'POLICY_STATUS'
  - 'POLICY_TERM'
  - 'POLICY_TERM_DAYS'
  - 'POLICY_TYPE'
  - 'RISK_EXPIRY_DATE'
  - 'RISK_INCEPTION_DATE'
  - 'RISK_START_TIME'
  - 'SERVICING_ORG_UNIT_CODE'
  - 'SHORT_PERIOD_INDICATOR'
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
