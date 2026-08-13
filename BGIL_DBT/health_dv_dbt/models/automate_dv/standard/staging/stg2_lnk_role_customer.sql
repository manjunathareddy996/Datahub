{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_lnk_role_customer -- serves SAT_LNK_ROLE_CUSTOMER.
-- The ONE place PARTY_HK gets hashed for this cluster (namespaced: 'HUB_PARTY|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash). Child key column(s) (role_type_ck) pass through unchanged via
-- include_source_columns=true -- this satellite is multi-active.

{%- set yaml_metadata -%}
source_model: 'stitch_lnk_role_customer'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'VIP_INDICATOR'
derived_columns:
  PARTY_NK: "'HUB_PARTY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
