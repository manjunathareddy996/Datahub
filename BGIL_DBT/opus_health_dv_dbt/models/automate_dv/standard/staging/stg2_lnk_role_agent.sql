-- automate_dv.stage() for SAT_LNK_ROLE_AGENT, read off central view stitch_v16_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACTIVE_INDICATOR'
      - 'AGENCY_TYPE'
      - 'AGENT_CODE'
      - 'APPOINTMENT_DATE'
      - 'IRDAI_AGENT_LICENCE_NUMBER'
      - 'LICENCE_CATEGORY'
      - 'LICENCE_EXPIRY_DATE'
      - 'LICENCE_ISSUE_DATE'
      - 'SPECIAL_TDS_RATE'
      - 'SUB_INTERMEDIARY_INDICATOR'
      - 'ROLE_TYPE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(LNK_ROLE_AGENT__ACTIVE_INDICATOR, LNK_ROLE_AGENT__AGENCY_TYPE, LNK_ROLE_AGENT__AGENT_CODE, LNK_ROLE_AGENT__APPOINTMENT_DATE, LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER, LNK_ROLE_AGENT__LICENCE_CATEGORY, LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE, LNK_ROLE_AGENT__LICENCE_ISSUE_DATE, LNK_ROLE_AGENT__SPECIAL_TDS_RATE, LNK_ROLE_AGENT__SUB_INTERMEDIARY_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_TYPE_CK: 'LNK_ROLE_AGENT__ROLE_TYPE_CK'
  ACTIVE_INDICATOR: 'LNK_ROLE_AGENT__ACTIVE_INDICATOR'
  AGENCY_TYPE: 'LNK_ROLE_AGENT__AGENCY_TYPE'
  AGENT_CODE: 'LNK_ROLE_AGENT__AGENT_CODE'
  APPOINTMENT_DATE: 'LNK_ROLE_AGENT__APPOINTMENT_DATE'
  IRDAI_AGENT_LICENCE_NUMBER: 'LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER'
  LICENCE_CATEGORY: 'LNK_ROLE_AGENT__LICENCE_CATEGORY'
  LICENCE_EXPIRY_DATE: 'LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE'
  LICENCE_ISSUE_DATE: 'LNK_ROLE_AGENT__LICENCE_ISSUE_DATE'
  SPECIAL_TDS_RATE: 'LNK_ROLE_AGENT__SPECIAL_TDS_RATE'
  SUB_INTERMEDIARY_INDICATOR: 'LNK_ROLE_AGENT__SUB_INTERMEDIARY_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
