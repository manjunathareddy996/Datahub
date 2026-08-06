{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL link() for LNK_CLAIM_PARTY, 1 contributing table.
-- New in data_5b (see docs/PARTNER_BUILD_STATE.md section 1) -- the link itself already
-- existed canonically (HUB_CLAIM + HUB_PARTY) but had no satellite/build until now.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_clm_interested_parties__claim_party'
src_pk: 'CLAIM_PARTY_HKEY'
src_fk:
  - 'PARTY_HKEY'
  - 'CLAIM_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
