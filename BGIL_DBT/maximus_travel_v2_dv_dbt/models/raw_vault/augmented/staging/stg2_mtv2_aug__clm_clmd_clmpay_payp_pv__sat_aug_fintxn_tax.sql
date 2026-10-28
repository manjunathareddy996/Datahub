{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_FINTXN_TAX from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- Reads the fan-out model up_mtv2__clm_clmd_clmpay_payp_pv__aug_sat_aug_fintxn_tax: 3 instance(s) on this view.
--
-- 18 payload column(s); the child key is TAX_TYPE.

{%- set yaml_metadata -%}
source_model: 'up_mtv2__clm_clmd_clmpay_payp_pv__aug_sat_aug_fintxn_tax'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT: 'FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT'
  HASHDIFF_FINTXN_TAX:
    is_hashdiff: true
    columns:
      - 'INVOICE_MODE'
      - 'SUPPLIER_INVOICE_NUMBER'
      - 'TAX_TYPE'
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
derived_columns:
  FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT: "'HUB_FINANCIAL_TRANSACTION|' || (FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT)"
  FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT: 'FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT'
  TAX_TYPE: 'TAX_TYPE'
  INVOICE_MODE: 'INVOICE_MODE'
  SUPPLIER_INVOICE_NUMBER: 'SUPPLIER_INVOICE_NUMBER'
  TDS_CERTIFICATE_NUMBER: 'TDS_CERTIFICATE_NUMBER'
  TDS_DEMAND_DRAFT_PAYABLE_AT: 'TDS_DEMAND_DRAFT_PAYABLE_AT'
  TDS_DEMAND_DRAFT_STATE: 'TDS_DEMAND_DRAFT_STATE'
  TDS_NON_DEDUCTION_INDICATOR: 'TDS_NON_DEDUCTION_INDICATOR'
  TDS_NON_DEDUCTION_REASON: 'TDS_NON_DEDUCTION_REASON'
  TDS_REMITTANCE_MODE: 'TDS_REMITTANCE_MODE'
  TDS_REMITTANCE_PORTAL_REFERENCE_NUMBER: 'TDS_REMITTANCE_PORTAL_REFERENCE_NUMBER'
  TDS_SEPARATE_CHEQUE_INDICATOR: 'TDS_SEPARATE_CHEQUE_INDICATOR'
  TDS_SEPARATE_PAYMENT_INDICATOR: 'TDS_SEPARATE_PAYMENT_INDICATOR'
  TDS_SOURCE_SYSTEM_REFERENCE_NUMBER: 'TDS_SOURCE_SYSTEM_REFERENCE_NUMBER'
  TDS_WAIVED_INDICATOR: 'TDS_WAIVED_INDICATOR'
  TDS_WAIVED_REASON: 'TDS_WAIVED_REASON'
  UGST_AMOUNT: 'UGST_AMOUNT'
  UGST_RATE: 'UGST_RATE'
  UTGST_AMOUNT: 'UTGST_AMOUNT'
  VAT_REGISTRATION_NUMBER: 'VAT_REGISTRATION_NUMBER'
  RECORD_SOURCE: 'record_source'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
