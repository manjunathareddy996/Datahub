-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_IDENTITY, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'UNIQUE_CUSTOMER_IDENTIFICATION_CODE_INDICATOR'
derived_columns:
  PARTY_NK: "case when AUG_PARTY_IDENTITY__UNIQUE_CUSTOMER_IDENTIFICATION_CODE_INDICATOR is not null then 'HUB_PARTY|' || PARTY_BK end"
  UNIQUE_CUSTOMER_IDENTIFICATION_CODE_INDICATOR: 'AUG_PARTY_IDENTITY__UNIQUE_CUSTOMER_IDENTIFICATION_CODE_INDICATOR'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v10_party'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
