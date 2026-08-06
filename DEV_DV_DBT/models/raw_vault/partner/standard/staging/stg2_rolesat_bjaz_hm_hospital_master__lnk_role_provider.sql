{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_LNK_ROLE_PROVIDER, table 'BJAZ_HM_HOSPITAL_MASTER'.
-- role-special: built directly off HUB_PARTY with a literal role_type_ck
-- ('provider') -- same modelling deviation ratified for Health (M3): a
-- load-time provenance label, not a fabricated business key.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_hm_hospital_master'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMPANELMENT_DATE'
      - 'SPECIALISATION'
      - 'PROVIDER_TYPE'
      - 'NETWORK_INDICATOR'
      - 'PREFERRED_PROVIDER_INDICATOR'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  ROLE_TYPE_CK: '!provider'
  EMPANELMENT_DATE: 'date_of_sup'
  SPECIALISATION: 'hosp_speciality'
  PROVIDER_TYPE: 'hosp_type'
  NETWORK_INDICATOR: 'hos_status'
  PREFERRED_PROVIDER_INDICATOR: 'preferred_flag'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
