-- automate_dv.stage() for SAT_POLICY_CLAUSE_ATTACHED, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLAUSE_CODE'
      - 'CLAUSE_TITLE'
      - 'CLAUSE_CODE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_CLAUSE_ATTACHED__CLAUSE_CODE, POLICY_CLAUSE_ATTACHED__CLAUSE_TITLE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CLAUSE_CODE_CK: 'POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK'
  CLAUSE_CODE: 'POLICY_CLAUSE_ATTACHED__CLAUSE_CODE'
  CLAUSE_TITLE: 'POLICY_CLAUSE_ATTACHED__CLAUSE_TITLE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
