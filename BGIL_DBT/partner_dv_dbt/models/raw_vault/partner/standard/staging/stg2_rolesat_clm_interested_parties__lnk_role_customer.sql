{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_LNK_ROLE_CUSTOMER, table 'CLM_INTERESTED_PARTIES'.
-- role-special: built directly off HUB_PARTY with a literal role_type_ck
-- ('customer') -- same modelling deviation ratified for Health (M3): a
-- load-time provenance label, not a fabricated business key.

{%- set yaml_metadata -%}
source_model: 'stg_partner__clm_interested_parties'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUSTOMER_CATEGORY'
derived_columns:
  PARENT_BK: 'claimant'
  PARENT_NK: "'HUB_PARTY|' || (claimant)"
  ROLE_TYPE_CK: '!customer'
  CUSTOMER_CATEGORY: 'object_type'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!CLM_INTERESTED_PARTIES'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
