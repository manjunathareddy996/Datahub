{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'PHONE_1', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- SAT_A_B_MA: Multi-active, multi-source satellite (TABLE_A + TABLE_B) via ma_sat_multi_source.
-- Grain: (PARTY_HKEY, PHONE_1, RECORD_SOURCE).
--   PARTY_HKEY  = parent key (HUB_PARTY).
--   PHONE_1     = child dependent key (CDK) -> a party can have several concurrently-active phones.
--   PHONE_2     = payload attribute for the child row.
-- Change detection is per GROUP (PARTY_HKEY + RECORD_SOURCE): the whole set of a
-- source's child rows for a parent is re-inserted if any member's hashdiff changed
-- OR the member count changed. Each source is its own group (Option B), so a late
-- source never makes another source's group look shrunk.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_a'
  - 'stg2_b'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'PHONE_1'
src_payload:
  - 'PHONE_2'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_column_map:
    stg2_a:
        - 'PHONE_1'
    stg2_b:
        - 'PHONE_1'
        - 'PHONE_2'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_column_map=metadata_dict['src_column_map']) }}
