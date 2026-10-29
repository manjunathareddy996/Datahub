{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_CLAIM_SLA_TRACKING from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 11 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__clm_clmd_clmrsk_rska_properties_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_SLA_TRACKING:
    is_hashdiff: true
    columns:
      - 'CASE_MANAGEMENT_INDICATOR'
      - 'CLAIM_ACTION_REASON_CODE'
      - 'FURTHER_EXECUTION_REQUIRED_INDICATOR'
      - 'LOSS_MANAGEMENT_CASE_STATUS'
      - 'LOSS_MANAGEMENT_INTERIM_UPDATE'
      - 'OUTSTANDING_REQUIREMENT_STATUS'
      - 'PRIORITY_SERVICE_INDICATOR'
      - 'REGISTRATION_TAT_BREACH_INDICATOR'
      - 'RISK_PRIORITY_REVIEW_FEEDBACK'
      - 'WORKFLOW_TRIGGER_REASON'
      - 'WORK_BUCKET_DESCRIPTION'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CASE_MANAGEMENT_INDICATOR: 'case_management'
  CLAIM_ACTION_REASON_CODE: 'cast(null as varchar)'
  FURTHER_EXECUTION_REQUIRED_INDICATOR: 'cast(null as varchar)'
  LOSS_MANAGEMENT_CASE_STATUS: 'ilm_case_status'
  LOSS_MANAGEMENT_INTERIM_UPDATE: 'ilm_interim_update'
  OUTSTANDING_REQUIREMENT_STATUS: 'cast(null as varchar)'
  PRIORITY_SERVICE_INDICATOR: 'cast(null as varchar)'
  REGISTRATION_TAT_BREACH_INDICATOR: 'cast(null as varchar)'
  RISK_PRIORITY_REVIEW_FEEDBACK: 'cast(null as varchar)'
  WORKFLOW_TRIGGER_REASON: 'cast(null as varchar)'
  WORK_BUCKET_DESCRIPTION: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
