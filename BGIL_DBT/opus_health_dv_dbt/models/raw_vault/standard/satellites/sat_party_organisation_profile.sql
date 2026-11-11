-- Standard sat() for SAT_PARTY_ORGANISATION_PROFILE (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v15_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_party_organisation_profile'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'GROUP_NAME'
  - 'LEGAL_CONSTITUTION_CODE'
  - 'MSME_CATEGORY'
  - 'MSME_INDICATOR'
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
