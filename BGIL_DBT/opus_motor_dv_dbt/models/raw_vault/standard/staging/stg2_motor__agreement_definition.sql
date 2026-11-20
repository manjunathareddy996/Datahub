-- automate_dv.stage() for SAT_AGREEMENT_DEFINITION, read off central view stitch_motor__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v12_policy'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGREEMENT_REFERENCE_NUMBER'
      - 'EXECUTION_DATE'
      - 'MASTER_AGREEMENT_REFERENCE'
derived_columns:
  AGREEMENT_NK: "case when coalesce(AGREEMENT_DEFINITION__AGREEMENT_REFERENCE_NUMBER, AGREEMENT_DEFINITION__EXECUTION_DATE, AGREEMENT_DEFINITION__MASTER_AGREEMENT_REFERENCE) is not null then 'HUB_AGREEMENT|' || AGREEMENT_BK end"
  AGREEMENT_REFERENCE_NUMBER: 'AGREEMENT_DEFINITION__AGREEMENT_REFERENCE_NUMBER'
  EXECUTION_DATE: 'AGREEMENT_DEFINITION__EXECUTION_DATE'
  MASTER_AGREEMENT_REFERENCE: 'AGREEMENT_DEFINITION__MASTER_AGREEMENT_REFERENCE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v12_policy'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
