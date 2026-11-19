-- automate_dv.stage() for SAT_PARTY_PROVIDER_CAPABILITY, read off central view stitch_v18_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v18_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACCREDITATION_INDICATOR'
      - 'ACCREDITATION_REFERENCE'
      - 'AVAILABLE_INDICATOR'
      - 'CAPABILITY_REMARKS'
      - 'CAPACITY'
      - 'FACILITY_CATEGORY'
      - 'FACILITY_COUNT'
      - 'FACILITY_NAME'
      - 'FACILITY_CODE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR, PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE, PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR, PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS, PARTY_PROVIDER_CAPABILITY__CAPACITY, PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY, PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT, PARTY_PROVIDER_CAPABILITY__FACILITY_NAME) is not null then 'HUB_PARTY|' || PARTY_BK end"
  FACILITY_CODE_CK: 'PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK'
  ACCREDITATION_INDICATOR: 'PARTY_PROVIDER_CAPABILITY__ACCREDITATION_INDICATOR'
  ACCREDITATION_REFERENCE: 'PARTY_PROVIDER_CAPABILITY__ACCREDITATION_REFERENCE'
  AVAILABLE_INDICATOR: 'PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR'
  CAPABILITY_REMARKS: 'PARTY_PROVIDER_CAPABILITY__CAPABILITY_REMARKS'
  CAPACITY: 'PARTY_PROVIDER_CAPABILITY__CAPACITY'
  FACILITY_CATEGORY: 'PARTY_PROVIDER_CAPABILITY__FACILITY_CATEGORY'
  FACILITY_COUNT: 'PARTY_PROVIDER_CAPABILITY__FACILITY_COUNT'
  FACILITY_NAME: 'PARTY_PROVIDER_CAPABILITY__FACILITY_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v18_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
