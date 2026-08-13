{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for SAT_AUG_LNK_ROLE_CUSTOMER
-- (HUB_PARTY grain, role-special: 'customer'), table 'CLM_INTERESTED_PARTIES'.
-- Reuses the exact PARTY_HKEY formula (claimant) from the matching standard-model
-- stg2_rolesat_*__lnk_role_customer.sql. 

{%- set yaml_metadata -%}
source_model: 'stg_partner__clm_interested_parties'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'IP_TYPE'
derived_columns:
  PARENT_BK: 'claimant'
  PARENT_NK: "'HUB_PARTY|' || (claimant)"
  IP_TYPE: 'ip_type'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!CLM_INTERESTED_PARTIES'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
