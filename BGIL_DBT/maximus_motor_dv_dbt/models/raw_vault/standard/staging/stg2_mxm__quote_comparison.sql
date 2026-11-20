-- automate_dv.stage() for SAT_QUOTE_COMPARISON, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SELECTED_INDICATOR'
      - 'OPTION_CODE_CK'
derived_columns:
  QUOTE_NK: "case when QUOTE_COMPARISON__SELECTED_INDICATOR is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  OPTION_CODE_CK: 'QUOTE_COMPARISON__OPTION_CODE_CK'
  SELECTED_INDICATOR: 'QUOTE_COMPARISON__SELECTED_INDICATOR'
  LOAD_DATETIME: 'QUOTE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
