{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_PARTY_BANKING, table 'BJAZ_AZBJ_PART_EXT_HIST'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_azbj_part_ext_hist'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACCOUNTNUMBERMASKED'
      - 'IFSCCODE'
      - 'MICRCODE'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  ACCOUNTNUMBERMASKED: 'account_no'
  IFSCCODE: 'ifsc_code'
  MICRCODE: 'micr_code'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_AZBJ_PART_EXT_HIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
