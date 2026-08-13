{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stage() pass for stitch_party_individual_demographics -- serves SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS.
-- PARTY_HKEY hashed once here (namespaced: 'HUB_PARTY|' || raw key).

{%- set yaml_metadata -%}
source_model: 'stitch_party_individual_demographics'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ANNUALHOUSEHOLDINCOME'
      - 'ANNUALINCOME'
      - 'DESIGNATION'
      - 'EDUCATIONALQUALIFICATION'
      - 'FATHERNAME'
      - 'MARITALSTATUS'
      - 'NUMBEROFCHILDREN'
      - 'OCCUPATIONCODE'
      - 'OCCUPATIONDESCRIPTION'
      - 'SPOUSENAME'
derived_columns:
  PARTY_NK: "'HUB_PARTY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
