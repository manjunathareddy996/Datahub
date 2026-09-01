{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for SAT_AUG_LNK_ROLE_PROVIDER
-- (HUB_PARTY grain, role-special: 'provider'), table 'BJAZ_HM_HOSPITAL_MASTER'.
-- Reuses the exact PARTY_HKEY formula (hosid) from the matching standard-model
-- stg2_rolesat_*__lnk_role_provider.sql. 

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_hm_hospital_master'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONTACT_PERSON_NAME'
      - 'CONTACT_PERSON_DESIGNATION'
      - 'NETWORK_TYPE'
      - 'EMPANEL_DATE'
      - 'DIAGNO_YN'
      - 'PRIORITY_FLG'
      - 'HOSP_SPEC_TYPE'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  CONTACT_PERSON_NAME: 'contact_person'
  CONTACT_PERSON_DESIGNATION: 'designation'
  NETWORK_TYPE: 'network_type'
  EMPANEL_DATE: 'empanel_date'
  DIAGNO_YN: 'diagno_yn'
  PRIORITY_FLG: 'priority_flg'
  HOSP_SPEC_TYPE: 'hosp_spec_type'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
