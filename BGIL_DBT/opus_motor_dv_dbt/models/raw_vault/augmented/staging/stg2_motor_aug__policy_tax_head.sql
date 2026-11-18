-- automate_dv.stage() for SAT_AUG_POLICY_TAX_HEAD, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TAX_HEAD_IDENTIFIER'
      - 'TAX_HEAD_CODE_CK'
derived_columns:
  POLICY_NK: "case when AUG_POLICY_TAX_HEAD__TAX_HEAD_IDENTIFIER is not null then 'HUB_POLICY|' || POLICY_BK end"
  TAX_HEAD_CODE_CK: 'AUG_POLICY_TAX_HEAD__TAX_HEAD_CODE_CK'
  TAX_HEAD_IDENTIFIER: 'AUG_POLICY_TAX_HEAD__TAX_HEAD_IDENTIFIER'
  LOAD_DATETIME: 'AUG_POLICY_TAX_HEAD__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
