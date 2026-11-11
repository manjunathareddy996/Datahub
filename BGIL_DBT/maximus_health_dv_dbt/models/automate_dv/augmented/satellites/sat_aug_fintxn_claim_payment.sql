-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_FINTXN_CLAIM_PAYMENT (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_v08_financial_transaction.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_fintxn_claim_payment'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_payload:
  - 'FIXED_PAYMENT'
  - 'IMPACTED_COVER_NAME'
  - 'NEFT_STATUS'
  - 'PAYMENT_APPROVAL_DATE'
  - 'PAYMENT_APPROVED_BY_REFERENCE'
  - 'PAYMENT_DETAIL_EFFECTIVE_FROM_DATE'
  - 'PAYMENT_DETAIL_EFFECTIVE_TO_DATE'
  - 'UTR_DATE'
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
