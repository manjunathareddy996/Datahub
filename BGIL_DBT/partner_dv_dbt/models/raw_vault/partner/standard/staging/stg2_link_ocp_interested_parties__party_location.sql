{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() -- table 'OCP_INTERESTED_PARTIES'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__ocp_interested_parties'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || partner_id"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || mailing_address_id"
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || partner_id || '|' || mailing_address_id"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OCP_INTERESTED_PARTIES'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
