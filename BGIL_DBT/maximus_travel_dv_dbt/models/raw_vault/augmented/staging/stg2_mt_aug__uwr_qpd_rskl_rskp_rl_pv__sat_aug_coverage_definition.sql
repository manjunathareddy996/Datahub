{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_COVERAGE_DEFINITION from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- ALIGNED to the OPUS sibling (BUILD_RULES 7.7). travel_dv_dbt already builds
-- SAT_AUG_COVERAGE_DEFINITION with src_pk COVERAGE_HKEY, single-active, no child key and a bare
-- HASHDIFF. This EXTENDS that satellite's payload; a second Maximus-side satellite
-- for the same concept would be model invention wearing an AUG_ prefix.
--
-- 2 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_qpd_rskl_rskp_rl_pv'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF_COVERAGE_DEFINITION:
    is_hashdiff: true
    columns:
      - 'COVERAGE_PLAN_VARIANT'
      - 'LEADING_COVER_INDICATOR'
derived_columns:
  COVERAGE_BK: "nullif(trim(case when nullif(trim(cover_code),'') is not null then 'COV:' || nullif(trim(cover_code), '') end),'')"
  COVERAGE_NK: "'HUB_COVERAGE|' || (nullif(trim(case when nullif(trim(cover_code),'') is not null then 'COV:' || nullif(trim(cover_code), '') end),''))"
  COVERAGE_PLAN_VARIANT: 'cover_plan'
  LEADING_COVER_INDICATOR: 'leading_cover'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
