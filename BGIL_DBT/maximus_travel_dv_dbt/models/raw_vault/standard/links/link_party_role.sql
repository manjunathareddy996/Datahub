{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL link() for LNK_PARTY_ROLE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.

{%- set yaml_metadata -%}
source_model: 'lnkfeed_mt_party_role'
src_pk: 'PARTY_ROLE_HKEY'
src_fk:
  - 'PARTY_HKEY'
  - 'PARTY_ROLE_ROLE'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
