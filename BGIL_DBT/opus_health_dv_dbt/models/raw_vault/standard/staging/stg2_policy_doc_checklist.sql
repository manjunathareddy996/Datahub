-- automate_dv.stage() for SAT_POLICY_DOC_CHECKLIST, read off central view stitch_v33_quote.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v33_quote'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RECEIVED_INDICATOR'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when POLICY_DOC_CHECKLIST__RECEIVED_INDICATOR is not null then 'HUB_POLICY|' || POLICY_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK'
  RECEIVED_INDICATOR: 'POLICY_DOC_CHECKLIST__RECEIVED_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v33_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
