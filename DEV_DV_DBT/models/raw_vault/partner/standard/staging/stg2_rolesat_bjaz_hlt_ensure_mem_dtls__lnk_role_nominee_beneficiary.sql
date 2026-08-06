{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_LNK_ROLE_NOMINEE_BENEFICIARY, table 'BJAZ_HLT_ENSURE_MEM_DTLS'.
-- role-special: built directly off HUB_PARTY with a literal role_type_ck
-- ('nominee_beneficiary') -- same modelling deviation ratified for Health (M3): a
-- load-time provenance label, not a fabricated business key.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_hlt_ensure_mem_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPOINTEE_NAME'
      - 'RELATIONSHIP_TO_INSURED'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  ROLE_TYPE_CK: '!nominee_beneficiary'
  APPOINTEE_NAME: 'assignee'
  RELATIONSHIP_TO_INSURED: 'relation'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HLT_ENSURE_MEM_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
