{{ config(materialized='view') }}

-- PARTNER+KYC AUGMENTED (unconfirmed) per-table stage() for HUB_LOCATION, table 'BJAZ_M_KYC_VOTER'.
-- 1 proposed attribute(s) from the mapper's Augmentation sheet, NOT in
-- data_7. Target(s) named by the map: SAT_COMMON_ADDRESS, SAT_COMMON_ADMIN_GEOGRAPHY.
--
-- Member names are UNDERSCORE(Proposed Attribute) -- the augmented track's own
-- convention, measured over the baseline's 147 decidable payload entries (141
-- follow it, 0 counterexamples). This is a CORRECTION to the profile's
-- 'raw source column verbatim'; see gen_pkyc_augmented's docstring.
--
-- Null-padded TO THE SATELLITE (1 of 2): FULL_ADDRESS_TEXT.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_m_kyc_voter'
hashed_columns:
  LOCATION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ELECTORAL_ROLL_PART_NAME'
      - 'FULL_ADDRESS_TEXT'
derived_columns:
  PARENT_BK: "coalesce(nullif(upper(trim(to_varchar(part_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '')"
  PARENT_NK: "'HUB_LOCATION|' || (coalesce(nullif(upper(trim(to_varchar(part_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), ''))"
  ELECTORAL_ROLL_PART_NAME: 'part_name'
  FULL_ADDRESS_TEXT: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_M_KYC_VOTER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
