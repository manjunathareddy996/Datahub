-- Standard sat() for SAT_COMMON_ADDRESS (parent HUB_LOCATION, history SCD2), fed whole from central view stitch_motor__v07_location.
-- SINGLE WRITER (G-3) BJAZ_MOT_ONLINE_POL_DTLS | SAT_COMMON_ADDRESS | Postal Code | dispatch: emits DISPPOSTCODE; withheld MAILING_PINCODE
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__common_address'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'ADDRESS_LINE_1'
  - 'ADDRESS_LINE_2'
  - 'ADDRESS_LINE_3'
  - 'CARE_OF_NAME'
  - 'CITY'
  - 'COUNTRY_CODE'
  - 'COUNTRY_NAME'
  - 'LANDMARK'
  - 'LOCALITY'
  - 'POSTAL_CODE'
  - 'POST_OFFICE_NAME'
  - 'STATE_CODE'
  - 'STATE_NAME'
  - 'STREET_NAME'
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
