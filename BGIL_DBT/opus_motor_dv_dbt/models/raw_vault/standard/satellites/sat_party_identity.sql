-- Standard sat() for SAT_PARTY_IDENTITY (parent HUB_PARTY, history SCD2), fed whole from central view stitch_motor__v09_party.
-- SINGLE WRITER (G-3) BJAZ_MOT_ONLINE_POL_DTLS | SAT_PARTY_IDENTITY | Gender Code | proposer: emits GENDER; withheld YOUR_GENDER
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__party_identity'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AGE'
  - 'DATE_OF_BIRTH'
  - 'FIRST_NAME'
  - 'GENDER_CODE'
  - 'LAST_NAME'
  - 'MIDDLE_NAME'
  - 'NAME_SUFFIX'
  - 'PARTY_DISPLAY_NAME'
  - 'PARTY_FULL_NAME'
  - 'PARTY_LEGAL_NAME'
  - 'PARTY_SUB_TYPE_CODE'
  - 'PARTY_TYPE_CODE'
  - 'SALUTATION'
  - 'TITLE_CODE'
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
