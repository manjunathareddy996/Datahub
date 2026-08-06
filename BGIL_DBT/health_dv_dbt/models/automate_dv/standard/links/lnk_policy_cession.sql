{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_POLICY_CESSION, 1 contributing table(s).
-- Member ends: HUB_POLICY (POLICY_HKEY), HUB_REINSURANCE_TREATY (REINSURANCE_TREATY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_policy_cession.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_gpg_pol_dtls__policy_cession'
src_pk: 'POLICY_CESSION_HKEY'
src_fk:
  - 'POLICY_HKEY'
  - 'REINSURANCE_TREATY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
