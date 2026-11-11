-- automate_dv.stage() for SAT_AUG_QUOTE_HEADER, read off central view stitch_v33_quote.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v33_quote'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LAST_QUOTE_SUBMISSION_DATE'
      - 'QUOTE_BUSINESS_TYPE'
      - 'QUOTE_COPY_REFERENCE'
      - 'QUOTE_DATA_INFORMATION'
      - 'QUOTE_DESCRIPTION'
      - 'QUOTE_PRIORITY'
      - 'QUOTE_RESOLUTION_DATE'
      - 'QUOTE_SUBJECT'
      - 'QUOTE_SUB_STATUS'
      - 'QUOTE_SUB_STATUS_DESCRIPTION'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_HEADER__LAST_QUOTE_SUBMISSION_DATE, AUG_QUOTE_HEADER__QUOTE_BUSINESS_TYPE, AUG_QUOTE_HEADER__QUOTE_COPY_REFERENCE, AUG_QUOTE_HEADER__QUOTE_DATA_INFORMATION, AUG_QUOTE_HEADER__QUOTE_DESCRIPTION, AUG_QUOTE_HEADER__QUOTE_PRIORITY, AUG_QUOTE_HEADER__QUOTE_RESOLUTION_DATE, AUG_QUOTE_HEADER__QUOTE_SUBJECT, AUG_QUOTE_HEADER__QUOTE_SUB_STATUS, AUG_QUOTE_HEADER__QUOTE_SUB_STATUS_DESCRIPTION) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  LAST_QUOTE_SUBMISSION_DATE: 'AUG_QUOTE_HEADER__LAST_QUOTE_SUBMISSION_DATE'
  QUOTE_BUSINESS_TYPE: 'AUG_QUOTE_HEADER__QUOTE_BUSINESS_TYPE'
  QUOTE_COPY_REFERENCE: 'AUG_QUOTE_HEADER__QUOTE_COPY_REFERENCE'
  QUOTE_DATA_INFORMATION: 'AUG_QUOTE_HEADER__QUOTE_DATA_INFORMATION'
  QUOTE_DESCRIPTION: 'AUG_QUOTE_HEADER__QUOTE_DESCRIPTION'
  QUOTE_PRIORITY: 'AUG_QUOTE_HEADER__QUOTE_PRIORITY'
  QUOTE_RESOLUTION_DATE: 'AUG_QUOTE_HEADER__QUOTE_RESOLUTION_DATE'
  QUOTE_SUBJECT: 'AUG_QUOTE_HEADER__QUOTE_SUBJECT'
  QUOTE_SUB_STATUS: 'AUG_QUOTE_HEADER__QUOTE_SUB_STATUS'
  QUOTE_SUB_STATUS_DESCRIPTION: 'AUG_QUOTE_HEADER__QUOTE_SUB_STATUS_DESCRIPTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v33_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
