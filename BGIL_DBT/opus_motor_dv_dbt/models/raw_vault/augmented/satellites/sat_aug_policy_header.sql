-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_HEADER (parent HUB_POLICY, history SCD2), fed whole from central view stitch_motor__v13_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__policy_header'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'ADDITIONAL_REMARKS'
  - 'BUSINESS_VERTICAL_SEGMENT'
  - 'COVER_NOTE_CONVERSION_AGREED_INDICATOR'
  - 'ELECTRONIC_REQUEST_NUMBER'
  - 'FINANCIAL_YEAR'
  - 'FLOAT_FUNDING_TYPE'
  - 'INSURED_NAME'
  - 'INSURED_VEHICLE_INTERNAL_REFERENCE'
  - 'INTERNAL_TRACKING_NUMBER'
  - 'LATEST_PRIOR_POLICY_INDICATOR'
  - 'LIABILITY_COVER_BASIS'
  - 'PLAN_PARTNER_IDENTIFIER'
  - 'POLICY_TRANSACTION_TYPE'
  - 'PRODUCT_PACKAGE_IDENTIFIER'
  - 'PROMOTION_REFERENCE'
  - 'RISK_OBJECT_INTERNAL_REFERENCE'
  - 'SCRUTINY_REFERENCE'
  - 'TRADE_CERTIFICATE_COUNT'
  - 'TRADE_CERTIFICATE_INDICATOR'
  - 'UNDERLYING_BASIC_POLICY_REFERENCE'
  - 'UNDERWRITING_YEAR'
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
