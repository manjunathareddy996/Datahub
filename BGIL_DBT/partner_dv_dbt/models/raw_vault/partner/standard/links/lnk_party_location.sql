{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL link() for LNK_PARTY_LOCATION, 8 contributing table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_azbj_partner_extn__party_location'
  - 'stg2_link_bjaz_azbj_part_ext_hist__party_location'
  - 'stg2_link_bjaz_clm_supp_extn__party_location'
  - 'stg2_link_bjaz_cp_address_link__party_location'
  - 'stg2_link_bjaz_cp_part_hist__party_location'
  - 'stg2_link_clm_suppliers__party_location'
  - 'stg2_link_cp_partners__party_location'
  - 'stg2_link_ocp_interested_parties__party_location'
src_pk: 'PARTY_LOCATION_HKEY'
src_fk:
  - 'PARTY_HKEY'
  - 'LOCATION_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
