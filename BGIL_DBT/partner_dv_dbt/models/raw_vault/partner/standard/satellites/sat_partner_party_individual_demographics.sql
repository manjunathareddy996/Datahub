{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='HASHDIFF'
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS (HUB_PARTY grain) -- stitch-backed, 10 table(s).
-- Source: stg2_party_individual_demographics.

{%- set yaml_metadata -%}
source_model: 'stg2_party_individual_demographics'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ANNUALHOUSEHOLDINCOME'
  - 'ANNUALINCOME'
  - 'DESIGNATION'
  - 'EDUCATIONALQUALIFICATION'
  - 'FATHERNAME'
  - 'MARITALSTATUS'
  - 'NUMBEROFCHILDREN'
  - 'OCCUPATIONCODE'
  - 'OCCUPATIONDESCRIPTION'
  - 'SPOUSENAME'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_extra_columns:
  - 'DBT_RUN_TS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_extra_columns=metadata_dict['src_extra_columns'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
