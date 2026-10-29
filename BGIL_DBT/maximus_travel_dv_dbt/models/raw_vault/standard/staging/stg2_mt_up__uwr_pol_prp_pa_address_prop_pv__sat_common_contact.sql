{{ config(materialized='view') }}

-- UNPIVOT STAGE for SAT_COMMON_CONTACT from uwr_pol_prp_pa_address_prop_pv.
-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every
-- column is listed explicitly: a stage that passes its source's columns through makes
-- the satellite's real feeder columns invisible to anything reading the YAML, which is
-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).

{%- set yaml_metadata -%}
source_model: 'up_mt__uwr_pol_prp_pa_address_prop_pv__sat_common_contact'
hashed_columns:
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
  HASHDIFF_COMMON_CONTACT:
    is_hashdiff: true
    columns:
      - 'CONTACT_POINT_TYPE'
      - 'CONTACT_PRIORITY_ORDER'
      - 'ALTERNATE_EMAIL_ADDRESS'
      - 'ALTERNATE_MOBILE_NUMBER'
      - 'CONTACT_POINT_USAGE'
      - 'EMAIL_ADDRESS'
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
      - 'MOBILE_NUMBER'
      - 'SOCIAL_MEDIA_HANDLE'
      - 'STD_CODE'
derived_columns:
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (PARTY_BK__PROPOSER)"
  PARTY_BK__PROPOSER: 'PARTY_BK__PROPOSER'
  CONTACT_POINT_TYPE: 'CONTACT_POINT_TYPE'
  CONTACT_PRIORITY_ORDER: 'CONTACT_PRIORITY_ORDER'
  ALTERNATE_EMAIL_ADDRESS: 'ALTERNATE_EMAIL_ADDRESS'
  ALTERNATE_MOBILE_NUMBER: 'ALTERNATE_MOBILE_NUMBER'
  CONTACT_POINT_USAGE: 'CONTACT_POINT_USAGE'
  EMAIL_ADDRESS: 'EMAIL_ADDRESS'
  FAX_NUMBER: 'FAX_NUMBER'
  LANDLINE_NUMBER: 'LANDLINE_NUMBER'
  MOBILE_NUMBER: 'MOBILE_NUMBER'
  SOCIAL_MEDIA_HANDLE: 'SOCIAL_MEDIA_HANDLE'
  STD_CODE: 'STD_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
