{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY
-- Covers this view's 1 key slot(s) and its 0 1:1 satellite target(s) in one pass,
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
--   CLAIM_HKEY                         HUB_CLAIM  (16 row(s) in the map)

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_claim_history'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
