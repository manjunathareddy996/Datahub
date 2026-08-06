{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_party_claim_history -- serves SAT_PARTY_CLAIM_HISTORY.
-- The ONE place PARTY_HK gets hashed for this cluster (namespaced: 'HUB_PARTY|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_party_claim_history'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TOTAL_CLAIM_AMOUNT'
      - 'TOTAL_CLAIM_COUNT'
derived_columns:
  PARTY_NK: "'HUB_PARTY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
