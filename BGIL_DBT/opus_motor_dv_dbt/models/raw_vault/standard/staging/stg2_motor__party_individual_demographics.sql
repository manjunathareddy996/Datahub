-- automate_dv.stage() for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS, read off central view stitch_motor__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ANNUAL_INCOME'
      - 'EDUCATIONAL_QUALIFICATION'
      - 'HOUSE_OWNERSHIP_TYPE'
      - 'INDUSTRY_OF_EMPLOYMENT'
      - 'MARITAL_STATUS'
      - 'NUMBER_OF_CHILDREN'
      - 'OCCUPATION_DESCRIPTION'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_INCOME, PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION, PARTY_INDIVIDUAL_DEMOGRAPHICS__HOUSE_OWNERSHIP_TYPE, PARTY_INDIVIDUAL_DEMOGRAPHICS__INDUSTRY_OF_EMPLOYMENT, PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS, PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_CHILDREN, PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ANNUAL_INCOME: 'PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_INCOME'
  EDUCATIONAL_QUALIFICATION: 'PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION'
  HOUSE_OWNERSHIP_TYPE: 'PARTY_INDIVIDUAL_DEMOGRAPHICS__HOUSE_OWNERSHIP_TYPE'
  INDUSTRY_OF_EMPLOYMENT: 'PARTY_INDIVIDUAL_DEMOGRAPHICS__INDUSTRY_OF_EMPLOYMENT'
  MARITAL_STATUS: 'PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS'
  NUMBER_OF_CHILDREN: 'PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_CHILDREN'
  OCCUPATION_DESCRIPTION: 'PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v09_party'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
