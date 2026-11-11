-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_AGREEMENT_COMMERCIAL_TERMS (parent HUB_AGREEMENT, history SCD2), fed whole from central view stitch_v01_agreement.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_agreement_commercial_terms'
src_pk: 'AGREEMENT_HKEY'
src_payload:
  - 'BILL_SETTLEMENT_TAT_RANGE'
  - 'CASHLESS_BILL_DISCOUNT_BUSINESS_VOLUME'
  - 'CASHLESS_BILL_DISCOUNT_EFFECTIVE_DATE'
  - 'CASHLESS_BILL_DISCOUNT_PERCENTAGE'
  - 'CASHLESS_BILL_DISCOUNT_REMARK'
  - 'CASHLESS_BILL_RECEIPT_TIME'
  - 'DISCOUNT_BASIS'
  - 'EARLY_PAYMENT_DISCOUNT_EFFECTIVE_DATE'
  - 'EARLY_PAYMENT_DISCOUNT_PERCENTAGE'
  - 'EARLY_PAYMENT_DISCOUNT_REMARK'
  - 'EMPANELMENT_DISCOUNT_PERCENTAGE'
  - 'NON_CHM_SURGERY_INDICATOR'
  - 'PACKAGE_ACCEPTANCE_DATE'
  - 'PACKAGE_CLASS'
  - 'PACKAGE_EXPIRY_DATE'
  - 'PACKAGE_TYPE'
  - 'PREFERRED_PROVIDER_REMARKS'
  - 'PREFERRED_PROVIDER_TERMS_EFFECTIVE_DATE'
  - 'PREFERRED_PROVIDER_TERMS_EXPIRY_DATE'
  - 'PROVIDER_PAYMENT_MODE'
  - 'SERVICE_CHARGE_PERCENTAGE'
  - 'SURCHARGE_PERCENTAGE'
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
