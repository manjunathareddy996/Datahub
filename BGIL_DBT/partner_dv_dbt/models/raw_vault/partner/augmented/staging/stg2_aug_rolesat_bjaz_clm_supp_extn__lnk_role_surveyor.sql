{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for SAT_AUG_LNK_ROLE_SURVEYOR
-- (HUB_PARTY grain, role-special: 'surveyor'), table 'BJAZ_CLM_SUPP_EXTN'.
-- Reuses the exact PARTY_HKEY formula (partner_id) from the matching standard-model
-- stg2_rolesat_*__lnk_role_surveyor.sql. LICENSE_NO and SURVEYOR_LICENSE_NO deliberately excluded -- see file header.
-- HAS_IRDA_LICENCE_INDICATOR added per docs/PARTNER_BUILD_STATE.md section 3: IRDA_LICENSE is
-- a Y/N flag (not the licence number, which is SURVEYOR_LICENSE_NO -- already the canonical
-- payload on the standard-model satellite) -- build-side "Has IRDA Licence" indicator.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_clm_supp_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SUR_LICENSE_EXP_DATE'
      - 'IIISLA_MEM_NO'
      - 'IIISLA_MEM_STATUS'
      - 'HAS_IRDA_LICENCE_INDICATOR'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  SUR_LICENSE_EXP_DATE: 'sur_license_exp_date'
  IIISLA_MEM_NO: 'iiisla_mem_no'
  IIISLA_MEM_STATUS: 'iiisla_mem_status'
  HAS_IRDA_LICENCE_INDICATOR: 'irda_license'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CLM_SUPP_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
