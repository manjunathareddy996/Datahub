{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_PREMIUM_DETAILS
-- Covers this view's 1 key slot(s) and its 1 1:1 satellite target(s) in one pass,
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
--   POLICY_HKEY                        HUB_POLICY  (2 row(s) in the map)
--   HASHDIFF_POLICY_PREMIUM_SUMMARY    SAT_POLICY_PREMIUM_SUMMARY payload 2 of 7 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_prem'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_PREMIUM_SUMMARY:
    is_hashdiff: true
    columns:
      - 'BASE_PREMIUM'
      - 'GROSS_PREMIUM'
      - 'LOADING_AMOUNT'
      - 'NET_PREMIUM'
      - 'PREMIUM_OUTSTANDING'
      - 'REFUND_AMOUNT'
      - 'TOTAL_PREMIUM_COLLECTED'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  BASE_PREMIUM: 'cast(null as varchar)'
  GROSS_PREMIUM: 'cast(null as varchar)'
  LOADING_AMOUNT: 'cast(null as varchar)'
  NET_PREMIUM: 'cast(null as varchar)'
  PREMIUM_OUTSTANDING: 'outstanding_premium'
  REFUND_AMOUNT: 'cast(null as varchar)'
  TOTAL_PREMIUM_COLLECTED: 'collected_premium'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_PREMIUM_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
