{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_ONBOARDING_JOURNEY from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 14 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pp_sp_pv'
hashed_columns:
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
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
  PARTY_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  APPLICATION_REJECTION_REASON: 'rejected_reason'
  APPOINTMENT_CATEGORY: 'category_of_appointment'
  APPOINTMENT_ISSUE_DATE: 'date_of_issue_of_appointment'
  CANDIDATE_BACKGROUND_SUMMARY: 'background_of_candidate'
  IRDA_CODE_EXAMINATION_DETAILS: 'examinations_details_for_irda_code'
  PARTY_DECLARATION_TEXT: 'declaration'
  PREVIOUS_EMPLOYER_LOCATION: 'previous_company_location'
  PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE: 'previous_company_parent_imd_code'
  PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE: 'previous_company_parent_subimd_code'
  PREVIOUS_NON_GENERAL_INSURER_NAME: 'name_of_nongeneral_insurer_worked_for'
  PRIOR_FINANCIAL_SECTOR_EXPERIENCE: 'insurancebankingfinancial_experience'
  REASON_FOR_LEAVING_PREVIOUS_EMPLOYER: 'reason_for_leaving_remarks'
  RESIGNATION_ACCEPTANCE_DATE: 'date_of_acceptance_of_resignation'
  RESIGNATION_SUBMISSION_DATE: 'date_of_submitting_resignation'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
