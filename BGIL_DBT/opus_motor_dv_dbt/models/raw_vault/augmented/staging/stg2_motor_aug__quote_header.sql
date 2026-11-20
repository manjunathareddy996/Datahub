-- automate_dv.stage() for SAT_MOTOR_AUG_QUOTE_HEADER, read off central view stitch_motor__v23_quote.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v23_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'QUOTED_GEOGRAPHICAL_SCOPE'
      - 'QUOTED_WAITING_PERIOD'
      - 'RESTRICTED_PRODUCT_POLICY_REQUIRED_INDICATOR'
      - 'SAVED_QUOTE_RETRIEVED_INDICATOR'
      - 'SELECTED_IMT_CLAUSE_CODE_LIST'
      - 'STANDALONE_OD_REQUEST_REASON'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_HEADER__QUOTED_GEOGRAPHICAL_SCOPE, AUG_QUOTE_HEADER__QUOTED_WAITING_PERIOD, AUG_QUOTE_HEADER__RESTRICTED_PRODUCT_POLICY_REQUIRED_INDICATOR, AUG_QUOTE_HEADER__SAVED_QUOTE_RETRIEVED_INDICATOR, AUG_QUOTE_HEADER__SELECTED_IMT_CLAUSE_CODE_LIST, AUG_QUOTE_HEADER__STANDALONE_OD_REQUEST_REASON) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  QUOTED_GEOGRAPHICAL_SCOPE: 'AUG_QUOTE_HEADER__QUOTED_GEOGRAPHICAL_SCOPE'
  QUOTED_WAITING_PERIOD: 'AUG_QUOTE_HEADER__QUOTED_WAITING_PERIOD'
  RESTRICTED_PRODUCT_POLICY_REQUIRED_INDICATOR: 'AUG_QUOTE_HEADER__RESTRICTED_PRODUCT_POLICY_REQUIRED_INDICATOR'
  SAVED_QUOTE_RETRIEVED_INDICATOR: 'AUG_QUOTE_HEADER__SAVED_QUOTE_RETRIEVED_INDICATOR'
  SELECTED_IMT_CLAUSE_CODE_LIST: 'AUG_QUOTE_HEADER__SELECTED_IMT_CLAUSE_CODE_LIST'
  STANDALONE_OD_REQUEST_REASON: 'AUG_QUOTE_HEADER__STANDALONE_OD_REQUEST_REASON'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v23_quote'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
