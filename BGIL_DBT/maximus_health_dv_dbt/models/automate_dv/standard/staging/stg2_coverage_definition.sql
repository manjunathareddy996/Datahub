-- automate_dv.stage() for SAT_COVERAGE_DEFINITION, read off central view stitch_v09_financial_transaction.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_financial_transaction'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_CODE'
      - 'COVERAGE_DESCRIPTION'
      - 'COVERAGE_DISPLAY_NAME'
      - 'COVERAGE_GROUP'
      - 'COVERAGE_NAME'
      - 'COVERAGE_TYPE'
      - 'MANDATORY_INDICATOR'
derived_columns:
  COVERAGE_NK: "case when coalesce(COVERAGE_DEFINITION__COVERAGE_CODE, COVERAGE_DEFINITION__COVERAGE_DESCRIPTION, COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME, COVERAGE_DEFINITION__COVERAGE_GROUP, COVERAGE_DEFINITION__COVERAGE_NAME, COVERAGE_DEFINITION__COVERAGE_TYPE, COVERAGE_DEFINITION__MANDATORY_INDICATOR) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  COVERAGE_CODE: 'COVERAGE_DEFINITION__COVERAGE_CODE'
  COVERAGE_DESCRIPTION: 'COVERAGE_DEFINITION__COVERAGE_DESCRIPTION'
  COVERAGE_DISPLAY_NAME: 'COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME'
  COVERAGE_GROUP: 'COVERAGE_DEFINITION__COVERAGE_GROUP'
  COVERAGE_NAME: 'COVERAGE_DEFINITION__COVERAGE_NAME'
  COVERAGE_TYPE: 'COVERAGE_DEFINITION__COVERAGE_TYPE'
  MANDATORY_INDICATOR: 'COVERAGE_DEFINITION__MANDATORY_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_financial_transaction'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
