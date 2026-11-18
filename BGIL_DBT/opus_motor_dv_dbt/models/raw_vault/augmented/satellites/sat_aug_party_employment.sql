-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PARTY_EMPLOYMENT (parent HUB_PARTY, history SCD2), fed whole from central view stitch_motor__v10_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__party_employment'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'EMPLOYER_COMPANY_CODE'
  - 'EMPLOYER_RELATIONSHIP_TYPE'
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
