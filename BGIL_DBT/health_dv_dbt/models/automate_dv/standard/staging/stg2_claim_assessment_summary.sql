{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_claim_assessment_summary -- serves SAT_CLAIM_ASSESSMENT_SUMMARY.
-- The ONE place CLAIM_HK gets hashed for this cluster (namespaced: 'HUB_CLAIM|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_claim_assessment_summary'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADMISSIBLE_LOSS_AMOUNT'
      - 'ASSESSMENT_DATE'
      - 'DEDUCTIBLE_APPLIED'
      - 'TOTAL_DEDUCTION_AMOUNT'
derived_columns:
  CLAIM_NK: "'HUB_CLAIM|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
