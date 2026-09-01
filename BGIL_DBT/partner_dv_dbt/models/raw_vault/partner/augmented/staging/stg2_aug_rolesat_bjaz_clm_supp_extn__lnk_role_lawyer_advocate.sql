{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for SAT_AUG_LAWYER_ADVOCATE_ROLE
-- (HUB_PARTY grain, role-special: 'lawyer-advocate'), table 'BJAZ_CLM_SUPP_EXTN'.
-- Mapper-approved LOB-local new satellite (P1, MAPPER_REPLIES_PARTNER.md) -- build-side,
-- no modeler round-trip unless this role recurs in another LOB (Motor flagged as a watch
-- item). Reuses the same partner_id party-key formula as this table's other roles
-- (provider, surveyor).

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_clm_supp_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BAR_ASSOCIATION_NAME'
      - 'ENROLMENT_NO'
      - 'COVERED_COURT_LOC'
      - 'LAWYER_TYPE'
      - 'DATE_OF_JOINING'
      - 'YR_EXPERIENCE'
      - 'NO_OF_BRIEFS'
      - 'NO_OF_CONSUMER'
      - 'NO_OF_JUNIOR'
      - 'NO_OF_WC'
      - 'NO_OF_MACT'
      - 'NO_OF_COMPANIES'
      - 'ACD_QUALIFICATION'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  ROLE_TYPE_CK: '!lawyer-advocate'
  BAR_ASSOCIATION_NAME: 'bar_association_name'
  ENROLMENT_NO: 'enrolment_no'
  COVERED_COURT_LOC: 'covered_court_loc'
  LAWYER_TYPE: 'lawyer_type'
  DATE_OF_JOINING: 'date_of_joining'
  YR_EXPERIENCE: 'yr_experience'
  NO_OF_BRIEFS: 'no_of_briefs'
  NO_OF_CONSUMER: 'no_of_consumer'
  NO_OF_JUNIOR: 'no_of_junior'
  NO_OF_WC: 'no_of_wc'
  NO_OF_MACT: 'no_of_mact'
  NO_OF_COMPANIES: 'no_of_companies'
  ACD_QUALIFICATION: 'acd_qualification'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_CLM_SUPP_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
