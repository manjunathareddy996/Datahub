{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS
-- Covers this view's 1 key slot(s) and its 1 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   ASSESSMENT_HKEY__TELE_VERIFICATION HUB_ASSESSMENT / tele-verification  (5 row(s) in the map)
--   HASHDIFF_ASSESSMENT_HEADER         SAT_ASSESSMENT_HEADER payload 4 of 4 live here

{%- set yaml_metadata -%}
source_model: 'stg_mt__uwr_pol_tele'
hashed_columns:
  ASSESSMENT_HKEY__TELE_VERIFICATION: 'ASSESSMENT_NK__TELE_VERIFICATION'
  HASHDIFF_ASSESSMENT_HEADER:
    is_hashdiff: true
    columns:
      - 'ASSESSMENT_END_TIME'
      - 'ASSESSMENT_START_TIME'
      - 'ASSESSMENT_STATUS'
      - 'REQUESTED_DATE'
derived_columns:
  ASSESSMENT_BK__TELE_VERIFICATION: "nullif(trim(case when nullif(trim(transaction_id),'') is not null then 'TELEVERIF:' || nullif(trim(transaction_id), '') end),'')"
  ASSESSMENT_NK__TELE_VERIFICATION: "'HUB_ASSESSMENT|' || (nullif(trim(case when nullif(trim(transaction_id),'') is not null then 'TELEVERIF:' || nullif(trim(transaction_id), '') end),''))"
  ASSESSMENT_STATUS: 'tele_varification_status'
  REQUESTED_DATE: 'tele_varification_initiated_date'
  ASSESSMENT_END_TIME: 'end_time'
  ASSESSMENT_START_TIME: 'start_time'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
