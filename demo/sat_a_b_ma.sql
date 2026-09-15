{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'PHONE_1', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- SAT_A_B_MA: Multi-active satellite via automate_dv.ma_sat (single-source).
-- Grain: (PARTY_HKEY, PHONE_1).
--   PARTY_HKEY = parent key (HUB_PARTY).
--   PHONE_1    = child dependent key (CDK) -> a party can have several concurrently-active phones.
--   PHONE_2    = payload attribute for the child row.
-- NOTE: ma_sat is single-source, so this points at stg2_b only.

{%- set yaml_metadata -%}
source_model: 'stg2_b'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'PHONE_1'
src_payload:
  - 'PHONE_2'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
