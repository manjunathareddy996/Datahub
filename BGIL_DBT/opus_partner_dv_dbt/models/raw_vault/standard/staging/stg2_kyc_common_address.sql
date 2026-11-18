{{ config(materialized='view') }}

-- PARTNER+KYC stage() pass over stitch_kyc_common_address -- serves SAT_COMMON_ADDRESS and feeds
-- HUB_LOCATION. LOCATION_HKEY hashed once here, namespaced with a PIPE
-- ('HUB_LOCATION|' || raw key), which is the sibling's form: 344 pipe, 0 colon.
--
-- This is the ONLY HUB_LOCATION feed for the KYC scope. There is no per-table hub
-- feed because there is no 'KEY: HUB_LOCATION' row for any KYC table; the 8 instance
-- branches fan in through the stitch view instead (BD-08 + BD-09).

{%- set yaml_metadata -%}
source_model: 'stitch_kyc_common_address'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'ADDRESS_LINE_3'
      - 'BUILDING_NAME'
      - 'CAREOFNAME'
      - 'CITY'
      - 'COUNTRY_CODE'
      - 'COUNTRY_NAME'
      - 'DOOR_NUMBER'
      - 'POSTAL_CODE'
      - 'STATE_NAME'
      - 'STREET_NAME'
derived_columns:
  LOCATION_NK: "'HUB_LOCATION|' || PARENT_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
