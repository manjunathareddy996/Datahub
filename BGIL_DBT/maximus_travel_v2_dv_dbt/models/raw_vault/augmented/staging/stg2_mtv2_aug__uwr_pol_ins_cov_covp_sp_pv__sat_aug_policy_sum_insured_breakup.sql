{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_SUM_INSURED_BREAKUP from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 1 payload column(s); the child key is SUM_INSURED_HEAD.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_cov_covp_sp_pv'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_SUM_INSURED_BREAKUP:
    is_hashdiff: true
    columns:
      - 'SUM_INSURED_BREAK_UP_DETAIL'
      - 'SUM_INSURED_HEAD'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  SUM_INSURED_HEAD: "'RISK:' || nullif(trim(w1_pol_risk_id), '') || '#' || nullif(trim(w2_cover_code), '') || '#' || 'BREAK_UP'"
  SUM_INSURED_BREAK_UP_DETAIL: 'sum_insured_break_up'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
