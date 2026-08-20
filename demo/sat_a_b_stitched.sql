{{ config(materialized='incremental', incremental_strategy='append') }}

-- DEMO: Satellite fed by stitched source (Pattern 2).
-- Single stg2 feed (stg2_a_b) — ONE hashdiff timeline, no interleaving, no duplicates.
-- Plain automate_dv.sat() — behaves exactly like a single-source satellite.

{%- set yaml_metadata -%}
source_model: 'stg2_a_b'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'PHONE_1'
  - 'PHONE_2'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
