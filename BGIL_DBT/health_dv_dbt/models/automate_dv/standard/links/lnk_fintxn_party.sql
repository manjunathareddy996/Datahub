{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_FINTXN_PARTY, 2 contributing table(s).
-- Member ends: HUB_FINANCIAL_TRANSACTION (FINANCIAL_TRANSACTION_HKEY), HUB_PARTY (PARTY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_fintxn_party.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_hm_hcm_extract__fintxn_party'
  - 'stg2_link_bjaz_tpa_claim_details_ws__fintxn_party'
src_pk: 'FINTXN_PARTY_HKEY'
src_fk:
  - 'FINANCIAL_TRANSACTION_HKEY'
  - 'PARTY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
