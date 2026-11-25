{{ config(materialized='incremental') }}
-- PARTNER STANDARD-MODEL link() for LNK_PARTY_CHANNEL (Party via Channel), 2 contributing table(s). BUILD-SIDE: not in the mapper's map.
-- Writes the SAME physical table as the other builds' model of the same name.
{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_clm_supp_extn__party_channel'
  - 'stg2_link_bjaz_intermediary__party_channel'
src_pk: 'PARTY_CHANNEL_HKEY'
src_fk:
  - 'DISTRIBUTION_CHANNEL_HKEY'
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
