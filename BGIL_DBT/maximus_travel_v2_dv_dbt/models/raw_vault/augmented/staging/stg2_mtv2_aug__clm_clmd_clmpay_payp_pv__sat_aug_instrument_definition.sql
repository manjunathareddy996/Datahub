{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_INSTRUMENT_DEFINITION from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 2 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmpay_payp_pv'
hashed_columns:
  PAYMENT_INSTRUMENT_HKEY__PAYEE_BANK_ACCOUNT: 'PAYMENT_INSTRUMENT_NK__PAYEE_BANK_ACCOUNT'
  HASHDIFF_INSTRUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_CATEGORY_CODE'
      - 'BANK_BRANCH_CODE'
derived_columns:
  PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT: "nullif(trim(case when coalesce(nullif(trim(account_number),'')) is not null then 'ACCT:' || nullif(trim(account_number), '') end),'')"
  PAYMENT_INSTRUMENT_NK__PAYEE_BANK_ACCOUNT: "'HUB_PAYMENT_INSTRUMENT|' || (nullif(trim(case when coalesce(nullif(trim(account_number),'')) is not null then 'ACCT:' || nullif(trim(account_number), '') end),''))"
  ACCOUNT_CATEGORY_CODE: 'account_category_code'
  BANK_BRANCH_CODE: 'branch_code'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
