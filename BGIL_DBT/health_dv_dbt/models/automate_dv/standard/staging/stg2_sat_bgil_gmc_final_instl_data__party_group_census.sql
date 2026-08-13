{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_GROUP_CENSUS, table 'BGIL_GMC_FINAL_INSTL_DATA' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bgil_gmc_final_instl_data'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DATE_OF_JOINING'
      - 'DESIGNATION_BAND'
derived_columns:
  PARENT_BK: 'emp_code'
  PARENT_NK: "'HUB_PARTY|' || (emp_code)"
  MEMBER_REFERENCE_CK: '!'
  DATE_OF_JOINING: 'doj'
  DESIGNATION_BAND: 'grade_code'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BGIL_GMC_FINAL_INSTL_DATA'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
