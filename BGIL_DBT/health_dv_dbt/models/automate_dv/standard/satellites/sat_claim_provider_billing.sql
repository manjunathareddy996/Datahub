{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_CLAIM_PROVIDER_BILLING (HUB_CLAIM grain) -- stitch-backed, 4 table(s) joined.
-- Source: stg2_claim_provider_billing.

{%- set yaml_metadata -%}
source_model: 'stg2_claim_provider_billing'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'BILL_NUMBER_CK'
src_payload:
  - 'APPROVED_AMOUNT'
  - 'AUTHORISED_AMOUNT'
  - 'BILL_DATE'
  - 'BILL_NUMBER'
  - 'BILL_STATUS_TYPE'
  - 'BILL_TYPE'
  - 'BILLED_AMOUNT'
  - 'DISALLOWANCE_REASON'
  - 'DISALLOWED_AMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
