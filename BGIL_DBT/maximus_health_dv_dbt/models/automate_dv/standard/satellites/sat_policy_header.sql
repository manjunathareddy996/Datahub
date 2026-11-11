-- Standard sat() for SAT_POLICY_HEADER (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v15_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_policy_header'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'CO_INSURANCE_INDICATOR'
  - 'CURRENCY_CODE'
  - 'ISSUING_CHANNEL_REFERENCE'
  - 'LINE_OF_BUSINESS'
  - 'NUMBER_OF_LIVES_COVERED'
  - 'POLICY_CHANNEL_TYPE'
  - 'POLICY_NUMBER'
  - 'POLICY_REMARKS'
  - 'POLICY_STATUS'
  - 'POLICY_SUB_STATUS'
  - 'POLICY_TERM'
  - 'POLICY_TERM_DAYS'
  - 'POLICY_TYPE'
  - 'PREMIUM_FREQUENCY'
  - 'PREMIUM_PAYER_REFERENCE'
  - 'RISK_EXPIRY_DATE'
  - 'RISK_INCEPTION_DATE'
  - 'RISK_START_TIME'
  - 'SUM_INSURED_TOTAL'
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
