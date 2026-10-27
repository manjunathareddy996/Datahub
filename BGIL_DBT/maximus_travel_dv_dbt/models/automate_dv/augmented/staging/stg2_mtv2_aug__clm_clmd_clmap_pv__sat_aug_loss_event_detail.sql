{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_LOSS_EVENT_DETAIL from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 1 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
hashed_columns:
  LOSS_EVENT_HKEY__V2: 'LOSS_EVENT_NK__V2'
  HASHDIFF_LOSS_EVENT_DETAIL:
    is_hashdiff: true
    columns:
      - 'POLICE_REPORT_TIME'
derived_columns:
  LOSS_EVENT_BK__V2: "nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w2_claimno),'')) is not null then 'LOSSEVT:' || coalesce(nullif(trim(claimno), ''), nullif(trim(w2_claimno), '')) end),'')"
  LOSS_EVENT_NK__V2: "'HUB_LOSS_EVENT|' || (nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w2_claimno),'')) is not null then 'LOSSEVT:' || coalesce(nullif(trim(claimno), ''), nullif(trim(w2_claimno), '')) end),''))"
  POLICE_REPORT_TIME: 'police_report_time'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
