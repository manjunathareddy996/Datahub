{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_agreement_definition -- serves SAT_AGREEMENT_DEFINITION.
-- The ONE place AGREEMENT_HK gets hashed for this cluster (namespaced: 'HUB_AGREEMENT|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_agreement_definition'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGREEMENT_CATEGORY'
      - 'AGREEMENT_NAME'
      - 'AGREEMENT_STATUS'
      - 'AGREEMENT_TYPE'
      - 'EFFECTIVE_DATE'
      - 'EXECUTION_DATE'
      - 'EXPIRY_DATE'
derived_columns:
  AGREEMENT_NK: "'HUB_AGREEMENT|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
