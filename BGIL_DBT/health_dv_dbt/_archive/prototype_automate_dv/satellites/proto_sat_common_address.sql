{{ config(materialized='incremental') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- Single-active satellite on HUB_LOCATION. The join-stitch (FULL OUTER JOIN + COALESCE)
-- happens upstream in stitched/stitch_common_address.sql, then a second stage() pass
-- computes HASHDIFF on the coalesced result (see stg2_common_address_stitched.sql) --
-- this is the one place in the whole prototype that isn't a plain per-table stage() feed,
-- because AutomateDV has no macro for attribute-level merging across sources (see README).
-- sat() itself only takes over the hashdiff-based change detection, dedup and incremental
-- append that today's hand-written raw_vault model does manually.
-- No src_eff: no source table on this cluster carries an address-effective-from date
-- (gap, not assumed).

{%- set yaml_metadata -%}
source_model: 'stg2_common_address_stitched'
src_pk: 'LOCATION_HK'
src_hashdiff: 'HASHDIFF'
src_payload:
  - 'ADDRESS_LINE_1'
  - 'ADDRESS_LINE_2'
  - 'CITY'
  - 'STATE_CODE'
  - 'POSTAL_CODE'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_payload=metadata_dict['src_payload'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
