{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RESERVE
-- Covers this view's 4 key slot(s) and its 2 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   CLAIM_HKEY                         HUB_CLAIM  (5 row(s) in the map)
--   CLAIM_HKEY__V2                     HUB_CLAIM  (1 row(s) in the map)
--   CLAIM_PARTY_HKEY                   LNK_CLAIM_PARTY  LINK
--   PARTY_HKEY                         HUB_PARTY  (2 row(s) in the map)
--   HASHDIFF_CLAIM_RESERVE             SAT_CLAIM_RESERVE payload 4 of 5 live here
--   HASHDIFF_LNK_CLAIM_PARTY_ROLE      SAT_LNK_CLAIM_PARTY_ROLE payload 0 of 0 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__clm_clmd_claim_reserve'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  CLAIM_HKEY__V2: 'CLAIM_NK__V2'
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_NK'
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_CLAIM_RESERVE:
    is_hashdiff: true
    columns:
      - 'CURRENT_RESERVE_AMOUNT'
      - 'INITIAL_RESERVE_AMOUNT'
      - 'OUTSTANDING_RESERVE_AMOUNT'
      - 'PAID_TO_DATE_AMOUNT'
      - 'RESERVE_HEAD'
      - 'RESERVE_TYPE'
  HASHDIFF_LNK_CLAIM_PARTY_ROLE:
    is_hashdiff: true
    columns:
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_SEQUENCE'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__V2: "nullif(trim(case when coalesce(nullif(trim(w1_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w1_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK__V2: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w1_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w1_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_PARTY_BK: "coalesce(nullif(trim(case when coalesce(nullif(trim(w1_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w1_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(reservparty),'')) is not null then nullif(trim(reservparty), '') end),''),'')"
  CLAIM_PARTY_NK: "'LNK_CLAIM_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w1_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w1_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(reservparty),'')) is not null then nullif(trim(reservparty), '') end),''),''))"
  PARTY_BK: "nullif(trim(case when coalesce(nullif(trim(reservparty),'')) is not null then nullif(trim(reservparty), '') end),'')"
  PARTY_NK: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(reservparty),'')) is not null then nullif(trim(reservparty), '') end),''))"
  CURRENT_RESERVE_AMOUNT: 'reserveamount'
  INITIAL_RESERVE_AMOUNT: 'cast(null as varchar)'
  OUTSTANDING_RESERVE_AMOUNT: 'pendingamount'
  PAID_TO_DATE_AMOUNT: 'paidamount'
  PARTY_ROLE_TYPE: "coalesce(nullif(trim(reservestake), ''),'')"
  RESERVE_HEAD: "coalesce(nullif(trim(reservetype), ''),'')"
  RESERVE_TYPE: 'reservetypedesc'
  ROLE_SEQUENCE: "'1'"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RESERVE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
