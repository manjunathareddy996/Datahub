{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_LNK_ROLE_NOMINEE_BENEFICIARY, table 'BJAZ_TRV_LOADER_DATA_MV' (payer anchor).

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RELATIONSHIP_TO_INSURED'
derived_columns:
  PARENT_BK: 'premiumpayerid'
  PARENT_NK: "'HUB_PARTY|' || (premiumpayerid)"
  ROLE_TYPE_CK: '!nominee-beneficiary'
  RELATIONSHIP_TO_INSURED: 'nomineerelationship'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
