-- automate_dv.stage() for SAT_RISK_PERSON_MEMBER, read off central view stitch_v03_assessment.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v03_assessment'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RELATIONSHIP_TO_PROPOSER'
      - 'MEMBER_SEQUENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when RISK_PERSON_MEMBER__RELATIONSHIP_TO_PROPOSER is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  MEMBER_SEQUENCE_CK: 'RISK_PERSON_MEMBER__MEMBER_SEQUENCE_CK'
  RELATIONSHIP_TO_PROPOSER: 'RISK_PERSON_MEMBER__RELATIONSHIP_TO_PROPOSER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v03_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
