{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_CLAIM_PAYMENT_TRANCHE from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 16 payload column(s); the child key is TRANCHE_NUMBER.

{%- set yaml_metadata -%}
source_model: 'resolved_mt__clm_clmd_clmpay'
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
  TRANCHE_NUMBER: "coalesce(nullif(trim(claimpaymentid), ''),'')"
  AOL_MODE_CODE: 'cast(null as varchar)'
  CASHLESS_CLAIM_TYPE: 'cast(null as varchar)'
  DAMAGE_TYPE_CODE: 'cast(null as varchar)'
  FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME: 'cast(null as varchar)'
  FIXED_DEPOSIT_RECEIPT_TENURE: 'cast(null as varchar)'
  INTEREST_AMOUNT: 'cast(null as varchar)'
  PAYABLE_INDICATOR: 'payindicator'
  PAYMENT_AUTHORISATION_DATE: 'cast(null as varchar)'
  PAYMENT_DUE_DATE: 'paymentduedate'
  PAYMENT_NARRATION: 'cast(null as varchar)'
  PAYMENT_REFERENCE_NUMBER: 'cast(null as varchar)'
  PAYMENT_RELEASE_CONFIRMED_INDICATOR: 'cast(null as varchar)'
  PAYMENT_REMARKS: 'remarks'
  POLICY_SECTION_CODE: 'cast(null as varchar)'
  PORTAL_PAYMENT_REFERENCE_NUMBER: 'cast(null as varchar)'
  RESERVE_HEAD_CODE: 'payreservetypre'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
