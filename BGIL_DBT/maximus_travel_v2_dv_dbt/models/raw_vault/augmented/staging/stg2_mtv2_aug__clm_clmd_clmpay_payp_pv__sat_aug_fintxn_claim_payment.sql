{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_FINTXN_CLAIM_PAYMENT from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 3 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmpay_payp_pv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT: 'FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT'
  HASHDIFF_FINTXN_CLAIM_PAYMENT:
    is_hashdiff: true
    columns:
      - 'INSTRUMENT_PAYABLE_AT_LOCATION'
      - 'INSTRUMENT_PRINT_LOCATION_CODE'
      - 'NEFT_APPROVAL_REFERENCE'
derived_columns:
  FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT: "nullif(trim(case when coalesce(nullif(trim(w1_claimpaymentid),'')) is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),'')"
  FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(w1_claimpaymentid),'')) is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),''))"
  INSTRUMENT_PAYABLE_AT_LOCATION: 'payable_at'
  INSTRUMENT_PRINT_LOCATION_CODE: 'print_location_code'
  NEFT_APPROVAL_REFERENCE: 'neft_approval'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
