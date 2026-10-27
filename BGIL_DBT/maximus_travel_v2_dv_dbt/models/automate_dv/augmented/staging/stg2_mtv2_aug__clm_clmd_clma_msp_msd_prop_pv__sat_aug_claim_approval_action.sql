{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_APPROVAL_ACTION from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 9 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clma_msp_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_APPROVAL_ACTION:
    is_hashdiff: true
    columns:
      - 'ACTION_CLOSURE_DATE'
      - 'ACTION_REMARKS'
      - 'APPROVAL_DECISION'
      - 'APPROVAL_STATUS'
      - 'APPROVER_REFERENCE'
      - 'APPROVER_REMARKS'
      - 'LAST_UPDATED_BY_REFERENCE'
      - 'REQUESTOR_REFERENCE'
      - 'REQUESTOR_REMARKS'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  ACTION_CLOSURE_DATE: 'closure_date'
  ACTION_REMARKS: 'remarks'
  APPROVAL_DECISION: 'approvereject'
  APPROVAL_STATUS: 'cast(null as varchar)'
  APPROVER_REFERENCE: 'approver'
  APPROVER_REMARKS: 'approver_remarks'
  LAST_UPDATED_BY_REFERENCE: 'last_updated_by'
  REQUESTOR_REFERENCE: 'requested_by'
  REQUESTOR_REMARKS: 'requestor_remarks'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
