-- Standard sat() for SAT_POLICY_HEADER (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v26_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_policy_header'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'COVER_NOTE_DATE'
  - 'COVER_NOTE_REFERENCE'
  - 'CO_INSURANCE_INDICATOR'
  - 'FIRST_YEAR_INDICATOR'
  - 'ISSUE_DATE'
  - 'ISSUING_CHANNEL_REFERENCE'
  - 'ISSUING_ORG_UNIT_CODE'
  - 'LINE_OF_BUSINESS'
  - 'MASTER_POLICY_REFERENCE'
  - 'MULTI_YEAR_INDICATOR'
  - 'POLICY_NUMBER'
  - 'POLICY_REFERENCE_NUMBER'
  - 'POLICY_REMARKS'
  - 'POLICY_STATUS'
  - 'POLICY_TERM'
  - 'POLICY_TERM_DAYS'
  - 'POLICY_TYPE'
  - 'PREMIUM_PAYER_REFERENCE'
  - 'PRODUCT_REFERENCE'
  - 'RISK_END_TIME'
  - 'RISK_EXPIRY_DATE'
  - 'RISK_INCEPTION_DATE'
  - 'RISK_START_TIME'
  - 'RURAL_SECTOR_POLICY_INDICATOR'
  - 'SUM_INSURED_BASIS'
  - 'SUM_INSURED_TOTAL'
  - 'TOP_UP_POLICY_INDICATOR'
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
