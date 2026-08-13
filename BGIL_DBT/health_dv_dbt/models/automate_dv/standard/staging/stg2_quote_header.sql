{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_quote_header -- serves SAT_QUOTE_HEADER.
-- The ONE place QUOTE_HK gets hashed for this cluster (namespaced: 'HUB_QUOTE|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_quote_header'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'QUOTE_DATE'
      - 'QUOTE_REMARKS'
      - 'QUOTE_STATUS'
      - 'REQUESTED_COVER_START_DATE'
derived_columns:
  QUOTE_NK: "'HUB_QUOTE|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
