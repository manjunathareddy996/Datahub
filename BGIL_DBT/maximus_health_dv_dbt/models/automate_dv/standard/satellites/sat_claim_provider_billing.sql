-- Standard ma_sat() for SAT_CLAIM_PROVIDER_BILLING (parent HUB_CLAIM, history Multi-Active SCD2), fed whole from central view stitch_v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_claim_provider_billing'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'BILL_NUMBER_CK'
src_payload:
  - 'BILLED_AMOUNT'
  - 'BILL_NUMBER'
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
