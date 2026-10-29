{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- Covers this view's 1 key slot(s) and its 1 1:1 satellite target(s) in one pass,
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
--   COVERAGE_HKEY                      HUB_COVERAGE  (25 row(s) in the map)
--   HASHDIFF_COVERAGE_SUBLIMIT_SCHEDULE SAT_COVERAGE_SUBLIMIT_SCHEDULE payload 3 of 3 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_ins_cov_covp_msp_msd_prop_pv'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF_COVERAGE_SUBLIMIT_SCHEDULE:
    is_hashdiff: true
    columns:
      - 'ACTIVE_SEQUENCE_NUMBER'
      - 'ITEM_DESCRIPTION'
      - 'SUB_LIMIT_AMOUNT'
      - 'SUB_LIMIT_ITEM'
derived_columns:
  COVERAGE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_cover_code),'')) is not null then 'COV:' || nullif(trim(w0_cover_code), '') end),'')"
  COVERAGE_NK: "'HUB_COVERAGE|' || (nullif(trim(case when coalesce(nullif(trim(w0_cover_code),'')) is not null then 'COV:' || nullif(trim(w0_cover_code), '') end),''))"
  ACTIVE_SEQUENCE_NUMBER: "coalesce(nullif(trim(sublimit_name), ''),'')"
  ITEM_DESCRIPTION: 'items_covered'
  SUB_LIMIT_AMOUNT: 'sum_insured'
  SUB_LIMIT_ITEM: 'sublimit_name'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
