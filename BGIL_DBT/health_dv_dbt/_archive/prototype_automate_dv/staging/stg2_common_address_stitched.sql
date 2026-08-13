{{ config(materialized='view') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- The one stage() pass for this whole cluster's HUB_LOCATION key: stitch_common_address.sql
-- deliberately does NOT hash anything (no per-table stage exists for an attribute-joined
-- table) -- this is where LOCATION_HK first gets computed, from LOCATION_CODE_KEY, once,
-- after the join/union has already produced one clean row per location. HASHDIFF is
-- computed here too, over the (possibly COALESCEd) payload.
-- LOCATION_HK is hashed from a namespaced LOCATION_NK ('HUB_LOCATION|' || raw key), not the
-- raw key directly -- preserves the cross-hub collision-prevention guarantee the original
-- dbt_utils.generate_surrogate_key(["'HUB_X'", key]) pattern had (see macros/location_address_key.sql).

{%- set yaml_metadata -%}
source_model: 'stitch_common_address'
hashed_columns:
  LOCATION_HK: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'CITY'
      - 'STATE_CODE'
      - 'POSTAL_CODE'
derived_columns:
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_CODE_KEY"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
