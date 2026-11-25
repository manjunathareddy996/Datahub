{{ config(materialized='incremental', tags=['lnk_extra']) }}
-- MAXIMUS PARTNER link() for LNK_ORG_UNIT_LOCATION. BUILD-SIDE: not in the mapper's map.
-- Writes the SAME physical table as the OPUS build partner_dv_dbt's model of the same name: separate
-- projects, separate pipelines, one shared vault. Declares ONLY this project's own sources.
{%- set yaml_metadata -%}
source_model: 'lnkfeed_mp_org_unit_location'
src_pk: 'ORG_UNIT_LOCATION_HKEY'
src_fk:
  - 'LOCATION_HKEY'
  - 'ORG_UNIT_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
