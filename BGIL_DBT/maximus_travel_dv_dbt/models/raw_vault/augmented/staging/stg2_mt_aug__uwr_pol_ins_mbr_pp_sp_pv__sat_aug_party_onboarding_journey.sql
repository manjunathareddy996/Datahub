{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_PARTY_ONBOARDING_JOURNEY from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 14 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_ins_mbr_pp_sp_pv'
hashed_columns:
  PARTY_HKEY__INSURED_MEMBER: 'PARTY_NK__INSURED_MEMBER'
  HASHDIFF_PARTY_ONBOARDING_JOURNEY:
    is_hashdiff: true
    columns:
      - 'APPLICATION_REJECTION_REASON'
      - 'APPOINTMENT_CATEGORY'
      - 'APPOINTMENT_ISSUE_DATE'
      - 'CANDIDATE_BACKGROUND_SUMMARY'
      - 'IRDA_CODE_EXAMINATION_DETAILS'
      - 'PARTY_DECLARATION_TEXT'
      - 'PREVIOUS_EMPLOYER_LOCATION'
      - 'PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE'
      - 'PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE'
      - 'PREVIOUS_NON_GENERAL_INSURER_NAME'
      - 'PRIOR_FINANCIAL_SECTOR_EXPERIENCE'
      - 'REASON_FOR_LEAVING_PREVIOUS_EMPLOYER'
      - 'RESIGNATION_ACCEPTANCE_DATE'
      - 'RESIGNATION_SUBMISSION_DATE'
derived_columns:
  PARTY_BK__INSURED_MEMBER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  APPLICATION_REJECTION_REASON: 'rejected_reason'
  APPOINTMENT_CATEGORY: 'cast(null as varchar)'
  APPOINTMENT_ISSUE_DATE: 'cast(null as varchar)'
  CANDIDATE_BACKGROUND_SUMMARY: 'cast(null as varchar)'
  IRDA_CODE_EXAMINATION_DETAILS: 'cast(null as varchar)'
  PARTY_DECLARATION_TEXT: 'declaration'
  PREVIOUS_EMPLOYER_LOCATION: 'cast(null as varchar)'
  PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE: 'cast(null as varchar)'
  PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE: 'cast(null as varchar)'
  PREVIOUS_NON_GENERAL_INSURER_NAME: 'cast(null as varchar)'
  PRIOR_FINANCIAL_SECTOR_EXPERIENCE: 'cast(null as varchar)'
  REASON_FOR_LEAVING_PREVIOUS_EMPLOYER: 'cast(null as varchar)'
  RESIGNATION_ACCEPTANCE_DATE: 'cast(null as varchar)'
  RESIGNATION_SUBMISSION_DATE: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
