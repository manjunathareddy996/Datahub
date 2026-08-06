{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_loss_event_detail -- serves SAT_LOSS_EVENT_DETAIL.
-- The ONE place LOSS_EVENT_HK gets hashed for this cluster (namespaced: 'HUB_LOSS_EVENT|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_loss_event_detail'
hashed_columns:
  LOSS_EVENT_HKEY: 'LOSS_EVENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOSS_DATE'
      - 'LOSS_EVENT_TYPE'
derived_columns:
  LOSS_EVENT_NK: "'HUB_LOSS_EVENT|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
