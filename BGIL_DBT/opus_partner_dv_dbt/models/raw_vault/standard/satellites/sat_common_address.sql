{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_COMMON_ADDRESS (HUB_LOCATION grain) -- stitch-backed, 6 table(s).
-- Source: stg2_common_address.
-- KYC: 1 KYC feed(s) added; converted automate_dv.sat -> sat_multi_source (same payload,
-- grain and hashdiff). Each KYC source supplies only its own columns via src_column_map.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_common_address'
  - 'stg2_kyc_common_address'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'ADDRESSLINE1'
  - 'ADDRESSLINE2'
  - 'ADDRESSLINE3'
  - 'BUILDINGNAME'
  - 'CITY'
  - 'COUNTRYCODE'
  - 'COUNTRYNAME'
  - 'DOORNUMBER'
  - 'POSTALCODE'
  - 'STATENAME'
  - 'STREETNAME'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_extra_columns:
  - 'DBT_RUN_TS'
src_record_source_map:
  stg2_common_address: 'OPUS'
  stg2_kyc_common_address: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_extra_columns=metadata_dict['src_extra_columns'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_common_address': ['ADDRESSLINE1', 'ADDRESSLINE2', 'ADDRESSLINE3', 'BUILDINGNAME', 'CITY', 'COUNTRYCODE', 'COUNTRYNAME', 'DOORNUMBER', 'POSTALCODE', 'STATENAME', 'STREETNAME'],
                        'stg2_kyc_common_address': ['ADDRESSLINE1', 'ADDRESSLINE2', 'ADDRESSLINE3', 'BUILDINGNAME', 'CITY', 'COUNTRYCODE', 'COUNTRYNAME', 'DOORNUMBER', 'POSTALCODE', 'STATENAME', 'STREETNAME']
                    }) }}
