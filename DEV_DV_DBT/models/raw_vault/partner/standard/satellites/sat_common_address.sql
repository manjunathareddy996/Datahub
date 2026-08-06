{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL sat() for SAT_COMMON_ADDRESS (HUB_LOCATION grain) -- stitch-backed, 6 table(s).
-- Source: stg2_common_address.

{%- set yaml_metadata -%}
source_model: 'stg2_common_address'
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
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
