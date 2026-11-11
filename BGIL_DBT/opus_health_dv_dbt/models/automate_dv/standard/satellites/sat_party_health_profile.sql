-- Standard sat() for SAT_PARTY_HEALTH_PROFILE (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v18_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_party_health_profile'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'FAMILY_MEDICAL_HISTORY_INDICATOR'
  - 'PRE_EXISTING_DISEASE_DESCRIPTION'
  - 'TOBACCO_CONSUMPTION_DETAIL'
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
