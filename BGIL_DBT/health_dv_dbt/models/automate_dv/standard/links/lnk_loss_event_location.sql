{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_LOSS_EVENT_LOCATION, 2 contributing table(s).
-- Member ends: HUB_LOCATION (LOCATION_HKEY), HUB_LOSS_EVENT (LOSS_EVENT_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_loss_event_location.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_hm_hcm_extract__loss_event_location'
  - 'stg2_link_bjaz_hm_inward_dtls__loss_event_location'
src_pk: 'LOSS_EVENT_LOCATION_HKEY'
src_fk:
  - 'LOCATION_HKEY'
  - 'LOSS_EVENT_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
