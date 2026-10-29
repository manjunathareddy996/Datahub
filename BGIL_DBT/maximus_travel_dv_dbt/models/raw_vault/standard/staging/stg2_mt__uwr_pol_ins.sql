{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
-- Covers this view's 2 key slot(s) and its 2 1:1 satellite target(s) in one pass,
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
--   RISK_OBJECT_HKEY                   HUB_RISK_OBJECT  (1 row(s) in the map)
--   RISK_OBJECT_HKEY__INSURED_RISK_LINE HUB_RISK_OBJECT / insured-risk-line  (6 row(s) in the map)
--   HASHDIFF_RISK_OBJECT_CORE          SAT_RISK_OBJECT_CORE payload 2 of 6 live here
--   HASHDIFF_RISK_OBJECT_VALUATION     SAT_RISK_OBJECT_VALUATION payload 1 of 3 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_ins'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  RISK_OBJECT_HKEY__INSURED_RISK_LINE: 'RISK_OBJECT_NK__INSURED_RISK_LINE'
  HASHDIFF_RISK_OBJECT_CORE:
    is_hashdiff: true
    columns:
      - 'EXPOSURE_QUANTITY'
      - 'EXPOSURE_UNIT'
      - 'RISK_CLASS_CODE'
      - 'RISK_OBJECT_DESCRIPTION'
      - 'RISK_OBJECT_REFERENCE_NUMBER'
      - 'RISK_OBJECT_TYPE'
  HASHDIFF_RISK_OBJECT_VALUATION:
    is_hashdiff: true
    columns:
      - 'INSURED_VALUE'
      - 'INSURED_VALUE_IN_SUM_INSURED_CURRENCY'
      - 'INSURED_VALUE_IN_TRANSACTION_CURRENCY'
derived_columns:
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(pol_risk_id), '') end),''))"
  RISK_OBJECT_BK__INSURED_RISK_LINE: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(pol_risk_id), '') end),'')"
  RISK_OBJECT_NK__INSURED_RISK_LINE: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(pol_risk_id), '') end),''))"
  EXPOSURE_QUANTITY: 'cast(null as varchar)'
  EXPOSURE_UNIT: 'cast(null as varchar)'
  INSURED_VALUE: 'sum_insured'
  RISK_CLASS_CODE: 'risk_code'
  RISK_OBJECT_DESCRIPTION: 'risk_desc'
  RISK_OBJECT_REFERENCE_NUMBER: 'cast(null as varchar)'
  RISK_OBJECT_TYPE: 'cast(null as varchar)'
  INSURED_VALUE_IN_SUM_INSURED_CURRENCY: 'cast(null as varchar)'
  INSURED_VALUE_IN_TRANSACTION_CURRENCY: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
