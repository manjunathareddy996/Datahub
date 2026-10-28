{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS
-- Covers this view's 2 key slot(s) and its 4 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mtv2_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   CLAIM_HKEY                         HUB_CLAIM  (16 row(s) in the map)
--   POLICY_HKEY                        HUB_POLICY  (1 row(s) in the map)
--   HASHDIFF_CLAIM_ASSESSMENT_SUMMARY  SAT_CLAIM_ASSESSMENT_SUMMARY payload 1 of 1 live here
--   HASHDIFF_CLAIM_FNOL                SAT_CLAIM_FNOL payload 1 of 7 live here
--   HASHDIFF_CLAIM_HEADER              SAT_CLAIM_HEADER payload 6 of 14 live here
--   HASHDIFF_CLAIM_SLA_TRACKING        SAT_CLAIM_SLA_TRACKING payload 1 of 1 live here

{%- set yaml_metadata -%}
source_model: 'stg_mtv2__clm_clmd'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_CLAIM_ASSESSMENT_SUMMARY:
    is_hashdiff: true
    columns:
      - 'NET_ASSESSED_AMOUNT'
  HASHDIFF_CLAIM_FNOL:
    is_hashdiff: true
    columns:
      - 'FNOL_CHANNEL'
      - 'FNOL_TIME'
      - 'PRELIMINARY_LOSS_DESCRIPTION'
      - 'PRELIMINARY_LOSS_ESTIMATE'
      - 'REPORTED_BY_CONTACT'
      - 'REPORTED_BY_NAME'
      - 'SELF_SERVICE_INDICATOR'
  HASHDIFF_CLAIM_HEADER:
    is_hashdiff: true
    columns:
      - 'CATASTROPHE_CODE'
      - 'CLAIM_CATEGORY'
      - 'CLAIM_HANDLER_REFERENCE'
      - 'CLAIM_REFERENCE_NUMBER'
      - 'CLAIM_STATUS'
      - 'CLAIM_SUB_STATUS'
      - 'CLAIM_TYPE'
      - 'HANDLING_ORG_UNIT_CODE'
      - 'INTIMATED_BY_ROLE'
      - 'INTIMATION_CHANNEL'
      - 'LOSS_DATE'
      - 'NOTIFICATION_DATE'
      - 'PRIORITY_CODE'
      - 'REGISTRATION_DATE'
  HASHDIFF_CLAIM_SLA_TRACKING:
    is_hashdiff: true
    columns:
      - 'LAST_ACTION_DATE'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(claimno),'')) is not null then nullif(trim(claimno), '') end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(claimno),'')) is not null then nullif(trim(claimno), '') end),''))"
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(policyno),'')) is not null then nullif(trim(policyno), '') end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(policyno),'')) is not null then nullif(trim(policyno), '') end),''))"
  CATASTROPHE_CODE: 'cast(null as varchar)'
  CLAIM_CATEGORY: 'claim_bucket'
  CLAIM_HANDLER_REFERENCE: 'cast(null as varchar)'
  CLAIM_REFERENCE_NUMBER: 'subclaimno'
  CLAIM_STATUS: 'claimstatus'
  CLAIM_SUB_STATUS: 'cast(null as varchar)'
  CLAIM_TYPE: 'cast(null as varchar)'
  FNOL_CHANNEL: 'cast(null as varchar)'
  FNOL_TIME: 'cast(null as varchar)'
  HANDLING_ORG_UNIT_CODE: 'claimbranch'
  INTIMATED_BY_ROLE: 'cast(null as varchar)'
  INTIMATION_CHANNEL: 'cast(null as varchar)'
  LAST_ACTION_DATE: 'statuschangedate'
  LOSS_DATE: 'lossdate'
  NET_ASSESSED_AMOUNT: 'net_assessed_amount'
  NOTIFICATION_DATE: 'intimationdate'
  PRELIMINARY_LOSS_DESCRIPTION: 'lossdesc'
  PRELIMINARY_LOSS_ESTIMATE: 'cast(null as varchar)'
  PRIORITY_CODE: 'cast(null as varchar)'
  REGISTRATION_DATE: 'cast(null as varchar)'
  REPORTED_BY_CONTACT: 'cast(null as varchar)'
  REPORTED_BY_NAME: 'cast(null as varchar)'
  SELF_SERVICE_INDICATOR: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
