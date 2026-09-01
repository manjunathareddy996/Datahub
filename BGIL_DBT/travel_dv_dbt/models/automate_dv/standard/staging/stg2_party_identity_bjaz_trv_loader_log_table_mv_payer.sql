{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_PARTY_IDENTITY, table 'BJAZ_TRV_LOADER_LOG_TABLE_MV' (payer anchor).

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'PARTY_LEGAL_NAME'
      - 'DATE_OF_BIRTH'
      - 'FIRST_NAME'
      - 'MIDDLE_NAME'
      - 'GENDER_CODE'
      - 'LAST_NAME'
      - 'TITLE_CODE'
derived_columns:
  PARENT_BK: 'premiumpayerid'
  PARENT_NK: "'HUB_PARTY|' || (premiumpayerid)"
  AGE: 'age'
  PARTY_LEGAL_NAME: 'companyname'
  DATE_OF_BIRTH: 'dateofbirth'
  FIRST_NAME: 'firstname'
  MIDDLE_NAME: 'middlename'
  GENDER_CODE: 'sex'
  LAST_NAME: 'surname'
  TITLE_CODE: 'title'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
