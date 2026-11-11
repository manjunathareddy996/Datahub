-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_COMMON_CONTACT (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v15_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_common_contact'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'CONTACT_PERSON_DESIGNATION'
  - 'CONTACT_PERSON_NAME'
  - 'CONTACT_POINT'
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
