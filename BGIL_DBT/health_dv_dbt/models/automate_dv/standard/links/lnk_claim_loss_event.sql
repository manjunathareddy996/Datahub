{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_CLAIM_LOSS_EVENT, 3 contributing table(s).
-- Member ends: HUB_CLAIM (CLAIM_HKEY), HUB_LOSS_EVENT (LOSS_EVENT_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_claim_loss_event.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_hm_hcm_extract__claim_loss_event'
  - 'stg2_link_bjaz_hm_inward_dtls__claim_loss_event'
  - 'stg2_link_bjaz_tpa_claim_details_ws__claim_loss_event'
src_pk: 'CLAIM_LOSS_EVENT_HKEY'
src_fk:
  - 'CLAIM_HKEY'
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
