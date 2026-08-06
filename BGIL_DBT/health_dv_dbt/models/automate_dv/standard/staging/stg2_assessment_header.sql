{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_assessment_header -- serves SAT_ASSESSMENT_HEADER.
-- The ONE place ASSESSMENT_HK gets hashed for this cluster (namespaced: 'HUB_ASSESSMENT|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_assessment_header'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSESSMENT_REFERENCE_NUMBER'
      - 'ASSESSMENT_STATUS'
      - 'ASSESSMENT_TYPE'
      - 'ASSESSOR_REFERENCE'
      - 'COMPLETED_DATE'
      - 'CONDUCTED_DATE'
      - 'COST_OF_ASSESSMENT'
      - 'OUTCOME_SUMMARY'
      - 'PRIORITY'
      - 'SCHEDULED_DATE'
derived_columns:
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
