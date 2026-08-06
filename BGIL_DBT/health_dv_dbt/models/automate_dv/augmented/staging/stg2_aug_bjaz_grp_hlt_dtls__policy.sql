{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_GRP_HLT_DTLS'.
-- 14 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_GRP_HLT_DTLS carries a verified HUB_POLICY key
-- (REG_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INSP_PRM_PAYED_EXP_STAX'
      - 'PREMIUM_ADDITION'
      - 'PRM_IN2YRS_OFEXPIRY'
      - 'MEMBER_COUNT_EXPIRING'
      - 'UTIZATION_CORPORATE'
      - 'CLAIMS_ANALYSIS_DATE'
      - 'CONTINUITY_GUIDELINE'
      - 'OTHER_OPAYMENT_DTLS'
      - 'CLAIMS_PAID_ASON_DATE'
      - 'CLAIMS_OUTSTANDING_ASON_DATE'
      - 'CLM_PYD_IN2YRS_PRE_EXPIRY'
      - 'CLAIMS_ANALYSIS_DATE_GPG'
      - 'TOTAL_CLAIM'
      - 'POLICY_ISSUANCE_CONFIRMATION'
derived_columns:
  PARENT_BK: 'reg_no'
  PARENT_NK: "'HUB_POLICY|' || (reg_no)"
  INSP_PRM_PAYED_EXP_STAX: 'insp_prm_payed_exp_stax'
  PREMIUM_ADDITION: 'premium_addition'
  PRM_IN2YRS_OFEXPIRY: 'prm_in2yrs_ofexpiry'
  MEMBER_COUNT_EXPIRING: 'member_count_expiring'
  UTIZATION_CORPORATE: 'utization_corporate'
  CLAIMS_ANALYSIS_DATE: 'claims_analysis_date'
  CONTINUITY_GUIDELINE: 'continuity_guideline'
  OTHER_OPAYMENT_DTLS: 'other_opayment_dtls'
  CLAIMS_PAID_ASON_DATE: 'claims_paid_ason_date'
  CLAIMS_OUTSTANDING_ASON_DATE: 'claims_outstanding_ason_date'
  CLM_PYD_IN2YRS_PRE_EXPIRY: 'clm_pyd_in2yrs_pre_expiry'
  CLAIMS_ANALYSIS_DATE_GPG: 'claims_analysis_date_gpg'
  TOTAL_CLAIM: 'total_claim'
  POLICY_ISSUANCE_CONFIRMATION: 'policy_issuance_confirmation'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
