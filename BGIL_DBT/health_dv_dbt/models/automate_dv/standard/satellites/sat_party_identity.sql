{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_PARTY_IDENTITY (HUB_PARTY grain) -- stitch-backed, 48 table(s) joined.
-- Source: stg2_party_identity.

{%- set yaml_metadata -%}
source_model: 'stg2_party_identity'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AGE'
  - 'DATE_OF_BIRTH'
  - 'FIRST_NAME'
  - 'GENDER_CODE'
  - 'LAST_NAME'
  - 'MIDDLE_NAME'
  - 'PARTY_DISPLAY_NAME'
  - 'PARTY_FULL_NAME'
  - 'PARTY_LEGAL_NAME'
  - 'PARTY_STATUS'
  - 'PARTY_STATUS_REASON'
  - 'PARTY_SUB_TYPE_CODE'
  - 'PARTY_TYPE_CODE'
  - 'SALUTATION'
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
