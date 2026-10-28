{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT
-- Covers this view's 4 key slot(s) and its 2 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mtv2_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   CLAIM_HKEY                         HUB_CLAIM  (6 row(s) in the map)
--   CLAIM_HKEY__CLAIM_PAYEE            HUB_CLAIM / claim-payee  (1 row(s) in the map)
--   CLAIM_PARTY_HKEY__CLAIM_PAYEE      LNK_CLAIM_PARTY / claim-payee  LINK
--   PARTY_HKEY__CLAIM_PAYEE            HUB_PARTY / claim-payee  (2 row(s) in the map)
--   HASHDIFF_CLAIM_PAYMENT_TRANCHE     SAT_CLAIM_PAYMENT_TRANCHE payload 5 of 10 live here
--   HASHDIFF_LNK_CLAIM_PARTY_ROLE      SAT_LNK_CLAIM_PARTY_ROLE payload 0 of 0 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmpay'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  CLAIM_HKEY__CLAIM_PAYEE: 'CLAIM_NK__CLAIM_PAYEE'
  CLAIM_PARTY_HKEY__CLAIM_PAYEE: 'CLAIM_PARTY_NK__CLAIM_PAYEE'
  PARTY_HKEY__CLAIM_PAYEE: 'PARTY_NK__CLAIM_PAYEE'
  HASHDIFF_CLAIM_PAYMENT_TRANCHE:
    is_hashdiff: true
    columns:
      - 'APPROVAL_REFERENCE'
      - 'FINAL_INDICATOR'
      - 'GROSS_AMOUNT'
      - 'HOLD_INDICATOR'
      - 'HOLD_REASON'
      - 'NET_AMOUNT'
      - 'PAYMENT_DATE'
      - 'PAYMENT_MODE'
      - 'PAYMENT_TYPE'
      - 'STATUS'
      - 'TRANCHE_NUMBER'
  HASHDIFF_LNK_CLAIM_PARTY_ROLE:
    is_hashdiff: true
    columns:
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_SEQUENCE'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__CLAIM_PAYEE: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK__CLAIM_PAYEE: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_PARTY_BK__CLAIM_PAYEE: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(paymentpartycode),'')) is not null then nullif(trim(paymentpartycode), '') end),''),'')"
  CLAIM_PARTY_NK__CLAIM_PAYEE: "'LNK_CLAIM_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(paymentpartycode),'')) is not null then nullif(trim(paymentpartycode), '') end),''),''))"
  PARTY_BK__CLAIM_PAYEE: "nullif(trim(case when coalesce(nullif(trim(paymentpartycode),'')) is not null then nullif(trim(paymentpartycode), '') end),'')"
  PARTY_NK__CLAIM_PAYEE: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(paymentpartycode),'')) is not null then nullif(trim(paymentpartycode), '') end),''))"
  APPROVAL_REFERENCE: 'approvedby'
  FINAL_INDICATOR: 'cast(null as varchar)'
  GROSS_AMOUNT: 'cast(null as varchar)'
  HOLD_INDICATOR: 'cast(null as varchar)'
  HOLD_REASON: 'cast(null as varchar)'
  NET_AMOUNT: 'netpaymentamount'
  PARTY_ROLE_TYPE: "coalesce(nullif(trim(paymentpartystakecode), ''),'')"
  PAYMENT_DATE: 'cast(null as varchar)'
  PAYMENT_MODE: 'paymentmethod'
  PAYMENT_TYPE: 'paymentpurpose'
  ROLE_SEQUENCE: "'1'"
  STATUS: 'paymentstatus'
  TRANCHE_NUMBER: "coalesce(nullif(trim(claimpaymentid), ''),'')"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
