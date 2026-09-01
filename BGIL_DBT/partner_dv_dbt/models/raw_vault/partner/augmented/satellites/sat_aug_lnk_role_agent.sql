{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER AUGMENTED (unconfirmed) sat_multi_source() for SAT_AUG_LNK_ROLE_AGENT
-- (HUB_PARTY grain, role-special: 'agent'). NOT part of the canonical data_5a.js
-- model as such -- SAT_LNK_ROLE_AGENT itself IS canonical (parent LNK_PARTY_ROLE),
-- but these are extra attributes the mapper's Augmentation sheet flagged, built here
-- using the same role-special HUB_PARTY pattern as the standard-model satellite.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_rolesat_bjaz_intermediary__lnk_role_agent'
  - 'stg2_aug_rolesat_bjaz_intermediary_hist__lnk_role_agent'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'INTERMEDIARY_LICENCE_NUMBER'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_column_map={
                        'stg2_aug_rolesat_bjaz_intermediary__lnk_role_agent': ['INTERMEDIARY_LICENCE_NUMBER'],
                        'stg2_aug_rolesat_bjaz_intermediary_hist__lnk_role_agent': ['INTERMEDIARY_LICENCE_NUMBER']
                    }) }}
