-- Standard sat() for SAT_POLICY_HEADER (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v14_risk_object.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_POLICY_HEADER | Policy Type | None: emits POLICY_TYPE; withheld TYPEOFPOLICY
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__policy_header'
src_pk:
  - 'POLICY_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'COVER_NOTE_REFERENCE'
  - 'CO_INSURANCE_INDICATOR'
  - 'CURRENCY_CODE'
  - 'LINE_OF_BUSINESS'
  - 'MASTER_POLICY_REFERENCE'
  - 'POLICYHOLDER_REFERENCE'
  - 'POLICY_CHANNEL_TYPE'
  - 'POLICY_NUMBER'
  - 'POLICY_REFERENCE_NUMBER'
  - 'POLICY_REMARKS'
  - 'POLICY_STATUS'
  - 'POLICY_SUB_STATUS'
  - 'POLICY_TERM'
  - 'POLICY_TYPE'
  - 'PREMIUM_FREQUENCY'
  - 'PREMIUM_PAYER_REFERENCE'
  - 'PRODUCT_REFERENCE'
  - 'RISK_END_TIME'
  - 'RISK_EXPIRY_DATE'
  - 'RISK_INCEPTION_DATE'
  - 'RISK_START_TIME'
  - 'SERVICING_ORG_UNIT_CODE'
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
