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
  {#-- DM-R1 item 16 fix: 'claimant' is a Y/N indicator flag, NOT a party id
       (verified: claimant holds only 'Y'/'N', so every row collapsed onto two
       bogus parties 'HUB_PARTY|Y' / 'HUB_PARTY|N'). The real party key on
       CLM_INTERESTED_PARTIES is part_id (ratified HUB_PARTY key). Re-keyed to
       part_id so rows attach to the correct party and resolve against the hub. --#}
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  ROLE_TYPE_CK: '!customer'
  CUSTOMER_CATEGORY: 'object_type'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_CLM_INTERESTED_PARTIES'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
