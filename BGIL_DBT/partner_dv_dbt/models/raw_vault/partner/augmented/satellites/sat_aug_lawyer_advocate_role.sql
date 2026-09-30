{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF']
    )
}}

-- PARTNER AUGMENTED (unconfirmed) sat() for SAT_AUG_LAWYER_ADVOCATE_ROLE (HUB_PARTY grain,
-- role-special: 'lawyer-advocate'). Mapper-approved LOB-local new satellite (P1) -- NOT in
-- data_5a.js. Grain: party plays lawyer/advocate role. Single source table
-- (BJAZ_CLM_SUPP_EXTN), 13 attrs. Promote to canonical only if this role recurs in another
-- LOB (Motor flagged as the next candidate).

{%- set yaml_metadata -%}
source_model: 'stg2_aug_rolesat_bjaz_clm_supp_extn__lnk_role_lawyer_advocate'
src_pk: 'PARTY_HKEY'
src_payload:
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
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
