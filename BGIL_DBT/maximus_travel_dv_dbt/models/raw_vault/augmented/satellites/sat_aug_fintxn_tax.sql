{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat() for SAT_AUG_FINTXN_TAX.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, FINANCIAL_TRANSACTION_HKEY, multi-active on TAX_TYPE.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_fintxn_tax'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_cdk:
  - 'TAX_TYPE'
src_payload:
  - 'INVOICE_MODE'
  - 'SUPPLIER_INVOICE_NUMBER'
  - 'TDS_CERTIFICATE_NUMBER'
  - 'TDS_DEMAND_DRAFT_PAYABLE_AT'
  - 'TDS_DEMAND_DRAFT_STATE'
  - 'TDS_NON_DEDUCTION_INDICATOR'
  - 'TDS_NON_DEDUCTION_REASON'
  - 'TDS_REMITTANCE_MODE'
  - 'TDS_REMITTANCE_PORTAL_REFERENCE_NUMBER'
  - 'TDS_SEPARATE_CHEQUE_INDICATOR'
  - 'TDS_SEPARATE_PAYMENT_INDICATOR'
  - 'TDS_SOURCE_SYSTEM_REFERENCE_NUMBER'
  - 'TDS_WAIVED_INDICATOR'
  - 'TDS_WAIVED_REASON'
  - 'UGST_AMOUNT'
  - 'UGST_RATE'
  - 'UTGST_AMOUNT'
  - 'VAT_REGISTRATION_NUMBER'
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
