{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_PAYMENT_TRANCHE from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 16 payload column(s); the child key is TRANCHE_NUMBER.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_PAYMENT_TRANCHE:
    is_hashdiff: true
    columns:
      - 'AOL_MODE_CODE'
      - 'CASHLESS_CLAIM_TYPE'
      - 'DAMAGE_TYPE_CODE'
      - 'FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME'
      - 'FIXED_DEPOSIT_RECEIPT_TENURE'
      - 'INTEREST_AMOUNT'
      - 'PAYABLE_INDICATOR'
      - 'PAYMENT_AUTHORISATION_DATE'
      - 'PAYMENT_DUE_DATE'
      - 'PAYMENT_NARRATION'
      - 'PAYMENT_REFERENCE_NUMBER'
      - 'PAYMENT_RELEASE_CONFIRMED_INDICATOR'
      - 'PAYMENT_REMARKS'
      - 'POLICY_SECTION_CODE'
      - 'PORTAL_PAYMENT_REFERENCE_NUMBER'
      - 'RESERVE_HEAD_CODE'
      - 'TRANCHE_NUMBER'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  TRANCHE_NUMBER: "coalesce(nullif(trim(payment_id), ''),'')"
  AOL_MODE_CODE: 'cast(null as varchar)'
  CASHLESS_CLAIM_TYPE: 'cast(null as varchar)'
  DAMAGE_TYPE_CODE: 'cast(null as varchar)'
  FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME: 'fdr_favoring'
  FIXED_DEPOSIT_RECEIPT_TENURE: 'fdr_period'
  INTEREST_AMOUNT: 'cast(null as varchar)'
  PAYABLE_INDICATOR: 'cast(null as varchar)'
  PAYMENT_AUTHORISATION_DATE: 'cast(null as varchar)'
  PAYMENT_DUE_DATE: 'cast(null as varchar)'
  PAYMENT_NARRATION: 'reference_text'
  PAYMENT_REFERENCE_NUMBER: 'payment_reference_no'
  PAYMENT_RELEASE_CONFIRMED_INDICATOR: 'confirm_payment'
  PAYMENT_REMARKS: 'cast(null as varchar)'
  POLICY_SECTION_CODE: 'cast(null as varchar)'
  PORTAL_PAYMENT_REFERENCE_NUMBER: 'portal_payment_reference_number'
  RESERVE_HEAD_CODE: 'cast(null as varchar)'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
