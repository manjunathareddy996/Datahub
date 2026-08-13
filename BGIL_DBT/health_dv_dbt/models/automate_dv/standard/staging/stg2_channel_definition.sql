{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_channel_definition -- serves SAT_CHANNEL_DEFINITION.
-- The ONE place DISTRIBUTION_CHANNEL_HK gets hashed for this cluster (namespaced: 'HUB_DISTRIBUTION_CHANNEL|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_channel_definition'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHANNEL_CATEGORY'
      - 'CHANNEL_NAME'
      - 'CHANNEL_TYPE'
      - 'SUB_CHANNEL_CODE'
derived_columns:
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
