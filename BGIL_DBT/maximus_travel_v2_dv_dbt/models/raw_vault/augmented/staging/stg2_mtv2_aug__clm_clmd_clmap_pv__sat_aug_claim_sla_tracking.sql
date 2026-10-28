{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_SLA_TRACKING from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 11 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
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
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CASE_MANAGEMENT_INDICATOR: 'cast(null as varchar)'
  CLAIM_ACTION_REASON_CODE: 'reasonop'
  FURTHER_EXECUTION_REQUIRED_INDICATOR: 'execution_required'
  LOSS_MANAGEMENT_CASE_STATUS: 'cast(null as varchar)'
  LOSS_MANAGEMENT_INTERIM_UPDATE: 'cast(null as varchar)'
  OUTSTANDING_REQUIREMENT_STATUS: 'claim_requirement_status'
  PRIORITY_SERVICE_INDICATOR: 'priority_service'
  REGISTRATION_TAT_BREACH_INDICATOR: 'tat_exceeded_for_delay_in_registration'
  RISK_PRIORITY_REVIEW_FEEDBACK: 'risk_priority_feedback'
  WORKFLOW_TRIGGER_REASON: 'reasontrigger'
  WORK_BUCKET_DESCRIPTION: 'bucket_description'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
