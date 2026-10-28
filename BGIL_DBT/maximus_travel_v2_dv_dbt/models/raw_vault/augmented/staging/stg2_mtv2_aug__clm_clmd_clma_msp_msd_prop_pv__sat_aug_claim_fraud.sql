{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_FRAUD from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 13 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clma_msp_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_FRAUD:
    is_hashdiff: true
    columns:
      - 'ANALYTICS_ALERT_DATE'
      - 'ANALYTICS_TRIGGER_DISPOSITION_DESCRIPTION'
      - 'ANALYTICS_TRIGGER_FEEDBACK'
      - 'FRAUD_APPROVER_REFERENCE'
      - 'FRAUD_APPROVER_REMARKS'
      - 'FRAUD_CLASSIFICATION'
      - 'FRAUD_REFERRAL_RAISED_BY_REFERENCE'
      - 'FRAUD_SEVERITY'
      - 'FRAUD_SEVERITY_GRADE'
      - 'LIFECYCLE_MANAGEMENT_TRIGGER_SELECTED'
      - 'MATERIAL_NON_DISCLOSURE_INDICATOR'
      - 'NON_DISCLOSURE_INDICATOR'
      - 'RISK_ACCEPTANCE_PRIORITY'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  ANALYTICS_ALERT_DATE: 'cast(null as varchar)'
  ANALYTICS_TRIGGER_DISPOSITION_DESCRIPTION: 'cast(null as varchar)'
  ANALYTICS_TRIGGER_FEEDBACK: 'cast(null as varchar)'
  FRAUD_APPROVER_REFERENCE: 'fraud_approver'
  FRAUD_APPROVER_REMARKS: 'fraud_approver_remarks'
  FRAUD_CLASSIFICATION: 'fraud_classification'
  FRAUD_REFERRAL_RAISED_BY_REFERENCE: 'fraud_requested_by'
  FRAUD_SEVERITY: 'severity_of_fraud'
  FRAUD_SEVERITY_GRADE: 'cast(null as varchar)'
  LIFECYCLE_MANAGEMENT_TRIGGER_SELECTED: 'cast(null as varchar)'
  MATERIAL_NON_DISCLOSURE_INDICATOR: 'cast(null as varchar)'
  NON_DISCLOSURE_INDICATOR: 'cast(null as varchar)'
  RISK_ACCEPTANCE_PRIORITY: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
