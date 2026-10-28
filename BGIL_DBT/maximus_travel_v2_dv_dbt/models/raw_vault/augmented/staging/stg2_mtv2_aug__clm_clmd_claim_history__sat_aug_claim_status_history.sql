{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_STATUS_HISTORY from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 16 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_claim_history'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_STATUS_HISTORY:
    is_hashdiff: true
    columns:
      - 'CLAIM_STATUS_AT_EVENT'
      - 'CLAIM_SUB_STATUS_AT_EVENT'
      - 'DELAY_REASON'
      - 'ENTRY_CREATED_DATE'
      - 'EVENT_CODE'
      - 'EVENT_DATE'
      - 'EVENT_DESCRIPTION'
      - 'EVENT_DETAILS'
      - 'EVENT_REFERENCE_NUMBER'
      - 'EVENT_REMARKS'
      - 'HISTORY_ENTRY_TYPE'
      - 'PPI_INDICATOR'
      - 'RECORDED_BY_USER_REFERENCE'
      - 'REQUIREMENT_STATUS'
      - 'SCRUTINY_STATUS'
      - 'SURVEY_REPORT_STATUS'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_STATUS_AT_EVENT: 'claim_status'
  CLAIM_SUB_STATUS_AT_EVENT: 'claim_sub_status'
  DELAY_REASON: 'delay_reason'
  ENTRY_CREATED_DATE: 'created_date'
  EVENT_CODE: 'event'
  EVENT_DATE: 'event_date'
  EVENT_DESCRIPTION: 'event_description'
  EVENT_DETAILS: 'details'
  EVENT_REFERENCE_NUMBER: 'reference_number'
  EVENT_REMARKS: 'remarks'
  HISTORY_ENTRY_TYPE: 'type'
  PPI_INDICATOR: 'ppi_indicator'
  RECORDED_BY_USER_REFERENCE: 'user_code'
  REQUIREMENT_STATUS: 'claim_requirement_status'
  SCRUTINY_STATUS: 'scrutiny_status'
  SURVEY_REPORT_STATUS: 'survey_report_status'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
