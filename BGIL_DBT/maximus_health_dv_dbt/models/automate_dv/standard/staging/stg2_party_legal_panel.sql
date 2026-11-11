-- automate_dv.stage() for SAT_PARTY_LEGAL_PANEL, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADVOCATE_TYPE'
      - 'AGREEMENT_STATUS'
      - 'BAR_COUNCIL_NAME'
      - 'BAR_ENROLMENT_NUMBER'
      - 'CASES_HANDLED_COUNT'
      - 'EMPANELMENT_DATE'
      - 'JUNIORS_COUNT'
      - 'PANEL_CATEGORY'
      - 'YEARS_OF_PRACTICE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_LEGAL_PANEL__ADVOCATE_TYPE, PARTY_LEGAL_PANEL__AGREEMENT_STATUS, PARTY_LEGAL_PANEL__BAR_COUNCIL_NAME, PARTY_LEGAL_PANEL__BAR_ENROLMENT_NUMBER, PARTY_LEGAL_PANEL__CASES_HANDLED_COUNT, PARTY_LEGAL_PANEL__EMPANELMENT_DATE, PARTY_LEGAL_PANEL__JUNIORS_COUNT, PARTY_LEGAL_PANEL__PANEL_CATEGORY, PARTY_LEGAL_PANEL__YEARS_OF_PRACTICE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ADVOCATE_TYPE: 'PARTY_LEGAL_PANEL__ADVOCATE_TYPE'
  AGREEMENT_STATUS: 'PARTY_LEGAL_PANEL__AGREEMENT_STATUS'
  BAR_COUNCIL_NAME: 'PARTY_LEGAL_PANEL__BAR_COUNCIL_NAME'
  BAR_ENROLMENT_NUMBER: 'PARTY_LEGAL_PANEL__BAR_ENROLMENT_NUMBER'
  CASES_HANDLED_COUNT: 'PARTY_LEGAL_PANEL__CASES_HANDLED_COUNT'
  EMPANELMENT_DATE: 'PARTY_LEGAL_PANEL__EMPANELMENT_DATE'
  JUNIORS_COUNT: 'PARTY_LEGAL_PANEL__JUNIORS_COUNT'
  PANEL_CATEGORY: 'PARTY_LEGAL_PANEL__PANEL_CATEGORY'
  YEARS_OF_PRACTICE: 'PARTY_LEGAL_PANEL__YEARS_OF_PRACTICE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
