{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_LNK_ROLE_SURVEYOR, table 'BJAZ_CLM_SUPP_EXTN'.
-- role-special: built directly off HUB_PARTY with a literal role_type_ck
-- ('surveyor') -- same modelling deviation ratified for Health (M3): a
-- load-time provenance label, not a fabricated business key.
-- BUG FIX (mapper feedback round 2): IRDAI_SURVEYOR_LICENCE_NUMBER was previously sourced from
-- 'irda_license', which sample data shows is a Y/N flag (["Y","N"]), not a licence number. The
-- real licence value lives in 'surveyor_license_no' (format "IRDA/IND/SLA-nnnnn", far higher
-- population). Re-pointed here; 'irda_license' itself has no canonical home (see mapper note).

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_clm_supp_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'IRDAI_SURVEYOR_LICENCE_NUMBER'
      - 'LICENCE_CATEGORY'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  ROLE_TYPE_CK: '!surveyor'
  IRDAI_SURVEYOR_LICENCE_NUMBER: 'surveyor_license_no'
  LICENCE_CATEGORY: 'surveyor_category'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_CLM_SUPP_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
