{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_ASSESSMENT_SUMMARY from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 10 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_properties_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_ASSESSMENT_SUMMARY:
    is_hashdiff: true
    columns:
      - 'ADVISORY_COMMITTEE_REFERRAL_INDICATOR'
      - 'AT_FAULT_PARTY_DESCRIPTION'
      - 'LIVE_VIDEO_SURVEY_INDICATOR'
      - 'NON_MEDICAL_ADMISSIBILITY_COMMENTS'
      - 'NON_MEDICAL_ADMISSIBILITY_INDICATOR'
      - 'SAVINGS_AMOUNT'
      - 'SCRUTINY_STATUS'
      - 'SECTION_64VB_PREMIUM_REALISATION_STATUS'
      - 'SPOT_SURVEY_INDICATOR'
      - 'SURVEY_REQUIRED_INDICATOR'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  ADVISORY_COMMITTEE_REFERRAL_INDICATOR: 'cast(null as varchar)'
  AT_FAULT_PARTY_DESCRIPTION: 'who_is_at_fault'
  LIVE_VIDEO_SURVEY_INDICATOR: 'cast(null as varchar)'
  NON_MEDICAL_ADMISSIBILITY_COMMENTS: 'claim_admissible_comments_non_medical'
  NON_MEDICAL_ADMISSIBILITY_INDICATOR: 'claim_admissible_non_medical'
  SAVINGS_AMOUNT: 'cast(null as varchar)'
  SCRUTINY_STATUS: 'cast(null as varchar)'
  SECTION_64VB_PREMIUM_REALISATION_STATUS: 'cast(null as varchar)'
  SPOT_SURVEY_INDICATOR: 'cast(null as varchar)'
  SURVEY_REQUIRED_INDICATOR: 'cast(null as varchar)'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
