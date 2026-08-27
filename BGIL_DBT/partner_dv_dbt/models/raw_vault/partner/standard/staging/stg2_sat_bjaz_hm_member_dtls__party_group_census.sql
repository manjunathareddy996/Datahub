{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_PARTY_GROUP_CENSUS, table 'BJAZ_HM_MEMBER_DTLS'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_hm_member_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DESIGNATIONBAND'
      - 'EMPLOYEEID'
      - 'LOCATIONREFERENCE'
      - 'MEMBERREFERENCE'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  DESIGNATIONBAND: 'grade'
  EMPLOYEEID: 'hat_empcode'
  LOCATIONREFERENCE: 'employee_location'
  MEMBERREFERENCE: 'member_id'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_HM_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
