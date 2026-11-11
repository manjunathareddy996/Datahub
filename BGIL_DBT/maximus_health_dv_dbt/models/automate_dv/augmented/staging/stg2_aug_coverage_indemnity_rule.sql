-- automate_dv.stage() for SAT_AUG_COVERAGE_INDEMNITY_RULE, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_CLAIM_PAYMENT_OPTION'
      - 'CLAIM_PAYMENT_OPTION'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_INDEMNITY_RULE__ALTERNATE_CLAIM_PAYMENT_OPTION, AUG_COVERAGE_INDEMNITY_RULE__CLAIM_PAYMENT_OPTION) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  ALTERNATE_CLAIM_PAYMENT_OPTION: 'AUG_COVERAGE_INDEMNITY_RULE__ALTERNATE_CLAIM_PAYMENT_OPTION'
  CLAIM_PAYMENT_OPTION: 'AUG_COVERAGE_INDEMNITY_RULE__CLAIM_PAYMENT_OPTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
