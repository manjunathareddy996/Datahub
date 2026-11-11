-- automate_dv.stage() for SAT_POLICY_CLAUSE_ATTACHED, read off central view stitch_v31_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v31_product'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLAUSE_TITLE'
      - 'CLAUSE_CODE_CK'
derived_columns:
  POLICY_NK: "case when POLICY_CLAUSE_ATTACHED__CLAUSE_TITLE is not null then 'HUB_POLICY|' || POLICY_BK end"
  CLAUSE_CODE_CK: 'POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK'
  CLAUSE_TITLE: 'POLICY_CLAUSE_ATTACHED__CLAUSE_TITLE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v31_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
