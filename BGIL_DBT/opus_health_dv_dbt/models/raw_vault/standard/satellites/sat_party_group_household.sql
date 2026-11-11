-- Standard sat() for SAT_PARTY_GROUP_HOUSEHOLD (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v27_policy.
{{ config(materialized='incremental') }}

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
