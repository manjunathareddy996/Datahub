{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_FOLLOWUP_TASK from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 13 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_claim_event_followup'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_FOLLOWUP_TASK:
    is_hashdiff: true
    columns:
      - 'ASSIGNED_TO_REFERENCE'
      - 'CREATED_BY_REFERENCE'
      - 'CREATED_DATE'
      - 'EVENT_EFFECTIVE_DATE'
      - 'FOLLOWUP_DESCRIPTION'
      - 'FOLLOWUP_EVENT_CODE'
      - 'FOLLOWUP_STATUS'
      - 'FOLLOWUP_TIMESTAMP'
      - 'JOB_STATUS'
      - 'KEYWORD'
      - 'LAST_UPDATED_BY_REFERENCE'
      - 'LAST_UPDATED_DATE'
      - 'PRIORITY_INDICATOR'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  ASSIGNED_TO_REFERENCE: 'assigned_personal'
  CREATED_BY_REFERENCE: 'created_by'
  CREATED_DATE: 'created_date'
  EVENT_EFFECTIVE_DATE: 'event_effective_date'
  FOLLOWUP_DESCRIPTION: 'description_remarks'
  FOLLOWUP_EVENT_CODE: 'event_code'
  FOLLOWUP_STATUS: 'claim_followup_status'
  FOLLOWUP_TIMESTAMP: 'followup_timestamp'
  JOB_STATUS: 'job_status'
  KEYWORD: 'keyword'
  LAST_UPDATED_BY_REFERENCE: 'last_updated_by'
  LAST_UPDATED_DATE: 'last_updated_date'
  PRIORITY_INDICATOR: 'priority_indicator'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
