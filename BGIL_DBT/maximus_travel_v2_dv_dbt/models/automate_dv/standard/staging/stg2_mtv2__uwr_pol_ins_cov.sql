{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS
-- Covers this view's 2 key slot(s) and its 3 1:1 satellite target(s) in one pass,
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
--   COVERAGE_HKEY                      HUB_COVERAGE  (2 row(s) in the map)
--   POLICY_HKEY                        HUB_POLICY  (5 row(s) in the map)
--   HASHDIFF_COVERAGE_DEFINITION       SAT_COVERAGE_DEFINITION payload 1 of 3 live here
--   HASHDIFF_POLICY_COVERAGE_SCHEDULE  SAT_POLICY_COVERAGE_SCHEDULE payload 2 of 8 live here
--   HASHDIFF_POLICY_PREMIUM_HEAD       SAT_POLICY_PREMIUM_HEAD payload 1 of 4 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_cov'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_COVERAGE_DEFINITION:
    is_hashdiff: true
    columns:
      - 'COVERAGE_DESCRIPTION'
      - 'COVERAGE_NAME'
      - 'PERIL_COVERED'
  HASHDIFF_POLICY_COVERAGE_SCHEDULE:
    is_hashdiff: true
    columns:
      - 'COVERAGE_END_DATE'
      - 'COVERAGE_OPTED_INDICATOR'
      - 'COVERAGE_REFERENCE'
      - 'COVERAGE_SEQUENCE'
      - 'COVERAGE_START_DATE'
      - 'CO_PAYMENT_PERCENTAGE'
      - 'DEDUCTIBLE_AMOUNT'
      - 'LIMIT_AMOUNT'
      - 'PREMIUM_FOR_COVERAGE'
      - 'SUM_INSURED'
  HASHDIFF_POLICY_PREMIUM_HEAD:
    is_hashdiff: true
    columns:
      - 'ADJUSTED_INDICATOR'
      - 'BASE_AMOUNT'
      - 'COVERAGE_REFERENCE__SAT_POLICY_PREMIUM_HEAD'
      - 'LOADING_AMOUNT'
      - 'NET_HEAD_PREMIUM'
      - 'PREMIUM_BASIS'
      - 'PREMIUM_HEAD_CODE'
      - 'SECTION'
derived_columns:
  COVERAGE_BK: "nullif(trim(case when coalesce(nullif(trim(cover_code),'')) is not null then 'COV:' || nullif(trim(cover_code), '') end),'')"
  COVERAGE_NK: "'HUB_COVERAGE|' || (nullif(trim(case when coalesce(nullif(trim(cover_code),'')) is not null then 'COV:' || nullif(trim(cover_code), '') end),''))"
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  ADJUSTED_INDICATOR: "'N'"
  BASE_AMOUNT: 'cast(null as varchar)'
  COVERAGE_DESCRIPTION: 'cast(null as varchar)'
  COVERAGE_END_DATE: 'cover_expiry_date'
  COVERAGE_NAME: 'cover_name'
  COVERAGE_OPTED_INDICATOR: 'cast(null as varchar)'
  COVERAGE_REFERENCE: "coalesce(nullif(trim(cover_code), ''),'')"
  COVERAGE_REFERENCE__SAT_POLICY_PREMIUM_HEAD: "nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || coalesce(nullif(trim(cover_code), ''), '')), '#')"
  COVERAGE_SEQUENCE: "coalesce(nullif(trim(w1_pol_risk_id), ''),'')"
  COVERAGE_START_DATE: 'cover_inception_date'
  CO_PAYMENT_PERCENTAGE: 'cast(null as varchar)'
  DEDUCTIBLE_AMOUNT: 'cast(null as varchar)'
  LIMIT_AMOUNT: 'cast(null as varchar)'
  LOADING_AMOUNT: 'cast(null as varchar)'
  NET_HEAD_PREMIUM: 'net_premium'
  PERIL_COVERED: 'cast(null as varchar)'
  PREMIUM_BASIS: 'cast(null as varchar)'
  PREMIUM_FOR_COVERAGE: 'cast(null as varchar)'
  PREMIUM_HEAD_CODE: "'COVER_NET_PREMIUM'"
  SECTION: "'COVER'"
  SUM_INSURED: 'cast(null as varchar)'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
