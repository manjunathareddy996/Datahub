-- automate_dv.stage() for SAT_PROPOSAL_MEDICAL_SCHEDULING, read off central view stitch_v18_proposal.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v18_proposal'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REPORT_STATUS'
      - 'MEMBER_REFERENCE_CK'
      - 'TEST_TYPE_CK'
derived_columns:
  PROPOSAL_NK: "case when PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  MEMBER_REFERENCE_CK: 'PROPOSAL_MEDICAL_SCHEDULING__MEMBER_REFERENCE_CK'
  TEST_TYPE_CK: 'PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK'
  REPORT_STATUS: 'PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v18_proposal'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
