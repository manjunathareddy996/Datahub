{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_COMMON_CONTACT, table 'CP_PARTNERS'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__cp_partners'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMAILADDRESS'
      - 'FAXNUMBER'
      - 'LANDLINENUMBER'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  EMAILADDRESS: 'email'
  FAXNUMBER: 'fax'
  LANDLINENUMBER: 'telephone2'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!CP_PARTNERS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
