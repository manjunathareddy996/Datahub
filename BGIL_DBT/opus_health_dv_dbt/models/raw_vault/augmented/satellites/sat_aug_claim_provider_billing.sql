-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CLAIM_PROVIDER_BILLING (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v08_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_provider_billing'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'BILL_ADJUDICATED_BY_USER'
  - 'BILL_ADJUDICATION_TIMESTAMP'
  - 'CLAIMED_AMOUNT'
  - 'CO_PAY_AMOUNT'
  - 'DISCOUNT_AMOUNT'
  - 'MOU_APPROVED_AMOUNT'
  - 'PATIENT_PAID_AMOUNT'
  - 'RELATED_BILL_REFERENCE'
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
