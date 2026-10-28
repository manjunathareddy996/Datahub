{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_ASSESSMENT_HEADER from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 2 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'stg_mtv2__uwr_pol_tele'
hashed_columns:
  ASSESSMENT_HKEY__TELE_VERIFICATION: 'ASSESSMENT_NK__TELE_VERIFICATION'
  HASHDIFF_ASSESSMENT_HEADER:
    is_hashdiff: true
    columns:
      - 'ASSESSMENT_END_TIME'
      - 'ASSESSMENT_START_TIME'
derived_columns:
  ASSESSMENT_BK__TELE_VERIFICATION: "nullif(trim(case when coalesce(nullif(trim(transaction_id),'')) is not null then 'TELEVERIF:' || nullif(trim(transaction_id), '') end),'')"
  ASSESSMENT_NK__TELE_VERIFICATION: "'HUB_ASSESSMENT|' || (nullif(trim(case when coalesce(nullif(trim(transaction_id),'')) is not null then 'TELEVERIF:' || nullif(trim(transaction_id), '') end),''))"
  ASSESSMENT_END_TIME: 'end_time'
  ASSESSMENT_START_TIME: 'start_time'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
