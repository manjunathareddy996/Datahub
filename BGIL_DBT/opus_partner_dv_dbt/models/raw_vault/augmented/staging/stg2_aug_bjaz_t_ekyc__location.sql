{{ config(materialized='view') }}

-- PARTNER+KYC AUGMENTED (unconfirmed) per-table stage() for HUB_LOCATION, table 'BJAZ_T_EKYC'.
-- 1 proposed attribute(s) from the mapper's Augmentation sheet, NOT in
-- data_7. Target(s) named by the map: SAT_COMMON_ADDRESS, SAT_COMMON_ADMIN_GEOGRAPHY.
--
-- Member names are UNDERSCORE(Proposed Attribute) -- the augmented track's own
-- convention, measured over the baseline's 147 decidable payload entries (141
-- follow it, 0 counterexamples). This is a CORRECTION to the profile's
-- 'raw source column verbatim'; see gen_pkyc_augmented's docstring.
--
-- Null-padded TO THE SATELLITE (1 of 2): ELECTORAL_ROLL_PART_NAME.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_ekyc'
hashed_columns:
  LOCATION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ELECTORAL_ROLL_PART_NAME'
      - 'FULL_ADDRESS_TEXT'
derived_columns:
  PARENT_BK: "coalesce(nullif(upper(trim(to_varchar(house_number))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(street))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(landmark))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(location))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(post_office))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(sub_district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(vtc_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(country))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin_code))), ''), '')"
  PARENT_NK: "'HUB_LOCATION|' || (coalesce(nullif(upper(trim(to_varchar(house_number))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(street))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(landmark))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(location))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(post_office))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(sub_district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(vtc_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(country))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin_code))), ''), ''))"
  ELECTORAL_ROLL_PART_NAME: "cast(null as varchar)"
  FULL_ADDRESS_TEXT: 'combine_address'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_EKYC'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
