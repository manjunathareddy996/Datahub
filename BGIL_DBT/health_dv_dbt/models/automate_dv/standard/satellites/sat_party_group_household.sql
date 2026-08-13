{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_PARTY_GROUP_HOUSEHOLD (HUB_PARTY grain) -- stitch-backed, 4 table(s) joined.
-- Source: stg2_party_group_household.

{%- set yaml_metadata -%}
source_model: 'stg2_party_group_household'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'MEMBER_COUNT'
  - 'RELATIONSHIP_COMPOSITION'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
