{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'PHONE_1', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

{%- set yaml_metadata -%}
source_model:
  - 'stg2_a'
  - 'stg2_b'
src_pk: 'PARTY_HKEY'
zsrc_payload:
  - 'PHONE_1'
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

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_column_map=metadata_dict['src_column_map']) }}