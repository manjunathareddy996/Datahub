{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_COVERAGE_CONDITIONS from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 1 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_qpd_rskl_rskp_rl_pv'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF_COVERAGE_CONDITIONS:
    is_hashdiff: true
    columns:
      - 'SUB_CONDITION_VALUE'
derived_columns:
  COVERAGE_BK: "nullif(trim(case when nullif(trim(cover_code),'') is not null then 'COV:' || nullif(trim(cover_code), '') end),'')"
  COVERAGE_NK: "'HUB_COVERAGE|' || (nullif(trim(case when nullif(trim(cover_code),'') is not null then 'COV:' || nullif(trim(cover_code), '') end),''))"
  SUB_CONDITION_VALUE: 'sub1'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
