{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL hub() for HUB_RISK_OBJECT, 6 contributing branches (5 traveller
-- members on BJAZ_TRV_LOADER_DATA_MV + 1 synthetic per-policy branch on
-- BJAZ_TRV_LOADER_LOG_TABLE_MV -- see stage file headers for the key formulas).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_trv_loader_data_mv__risk_object_member1'
  - 'stg2_hub_bjaz_trv_loader_data_mv__risk_object_member2'
  - 'stg2_hub_bjaz_trv_loader_data_mv__risk_object_member3'
  - 'stg2_hub_bjaz_trv_loader_data_mv__risk_object_member4'
  - 'stg2_hub_bjaz_trv_loader_data_mv__risk_object_member5'
  - 'stg2_hub_bjaz_trv_loader_log_table_mv__risk_object'
src_pk: 'RISK_OBJECT_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
