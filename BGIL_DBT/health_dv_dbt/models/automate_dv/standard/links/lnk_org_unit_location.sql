{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_ORG_UNIT_LOCATION, 1 contributing table(s).
-- Member ends: HUB_LOCATION (LOCATION_HKEY), HUB_ORG_UNIT (ORG_UNIT_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_org_unit_location.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_ehh_pol_dtls__org_unit_location'
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
