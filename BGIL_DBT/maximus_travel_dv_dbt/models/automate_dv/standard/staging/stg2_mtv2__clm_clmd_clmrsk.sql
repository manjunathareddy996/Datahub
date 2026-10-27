{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK
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
--   RISK_OBJECT_HKEY__CLAIMED_RISK_ITEM HUB_RISK_OBJECT / claimed-risk-item  (2 row(s) in the map)
--   HASHDIFF_RISK_OBJECT_CORE          SAT_RISK_OBJECT_CORE payload 1 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk'
hashed_columns:
  RISK_OBJECT_HKEY__CLAIMED_RISK_ITEM: 'RISK_OBJECT_NK__CLAIMED_RISK_ITEM'
  HASHDIFF_RISK_OBJECT_CORE:
    is_hashdiff: true
    columns:
      - 'EXPOSURE_QUANTITY'
      - 'EXPOSURE_UNIT'
      - 'RISK_CLASS_CODE'
      - 'RISK_OBJECT_DESCRIPTION'
      - 'RISK_OBJECT_REFERENCE_NUMBER'
      - 'RISK_OBJECT_TYPE'
derived_columns:
  RISK_OBJECT_BK__CLAIMED_RISK_ITEM: "nullif(trim(case when coalesce(nullif(trim(w0_policyno),''), nullif(trim(riskcode),'')) is not null then 'RISK:' || nullif(trim(w0_policyno), '') || '#' || nullif(trim(riskcode), '') end),'')"
  RISK_OBJECT_NK__CLAIMED_RISK_ITEM: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policyno),''), nullif(trim(riskcode),'')) is not null then 'RISK:' || nullif(trim(w0_policyno), '') || '#' || nullif(trim(riskcode), '') end),''))"
  EXPOSURE_QUANTITY: 'cast(null as varchar)'
  EXPOSURE_UNIT: 'cast(null as varchar)'
  RISK_CLASS_CODE: 'cast(null as varchar)'
  RISK_OBJECT_DESCRIPTION: 'riskdesc'
  RISK_OBJECT_REFERENCE_NUMBER: 'cast(null as varchar)'
  RISK_OBJECT_TYPE: 'cast(null as varchar)'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
