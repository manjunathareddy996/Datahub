{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_PROVIDER_CAPABILITY, table 'BJAZ_HM_HOSP_MASTER_EXTN1' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hosp_master_extn1'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACCREDITATION_INDICATOR'
      - 'ACCREDITATION_REFERENCE'
      - 'AVAILABLE_INDICATOR'
      - 'CAPABILITY_REMARKS'
      - 'CAPACITY'
      - 'FACILITY_COUNT'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  FACILITY_CODE_CK: '!'
  ACCREDITATION_INDICATOR: 'nabhcertified'
  ACCREDITATION_REFERENCE: 'stat_lvl_nqas'
  AVAILABLE_INDICATOR: 'opthamology'
  CAPABILITY_REMARKS: 'operatinghrs'
  CAPACITY: 'semitwin'
  FACILITY_COUNT: 'tot_no_doct'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSP_MASTER_EXTN1'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
