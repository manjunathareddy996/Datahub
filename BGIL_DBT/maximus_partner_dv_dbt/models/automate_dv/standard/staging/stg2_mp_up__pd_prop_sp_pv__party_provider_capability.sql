{{ config(materialized='view') }}

-- stage() over the SAT_PARTY_PROVIDER_CAPABILITY unpivot for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1: one hashing pass over all 135 rows.

{%- set yaml_metadata -%}
source_model: 'unpivot_mp__pd_prop_sp_pv__party_provider_capability'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_PARTY_PROVIDER_CAPABILITY:
    is_hashdiff: true
    columns:
      - 'ACCREDITATIONINDICATOR'
      - 'ACCREDITATIONREFERENCE'
      - 'AVAILABLEINDICATOR'
      - 'CAPABILITYREMARKS'
      - 'CAPACITY'
      - 'FACILITYCOUNT'
derived_columns:
  PARTY_BK: "parent_bk"
  PARTY_NK: "'HUB_PARTY|' || (parent_bk)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
