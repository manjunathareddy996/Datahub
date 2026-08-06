{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_FINTXN_COMMISSION, table 'BJAZ_HEALTH_WEBSERVICE_INFO' (single contributing table).
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): data_7 made this satellite
-- multi-active, child key 'Commission Type + Intermediary Reference'. This table has no
-- real commission-type discriminator (COMM_DISC_RATE is the only commission column), so
-- COMMISSION_TYPE is a literal -- 'Standard' is a judgment call (generic label, not
-- fabricated data) since only one commission concept exists on this table.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  FINANCIAL_TRANSACTION_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMISSION_RATE'
derived_columns:
  PARENT_BK: 'ptransaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (ptransaction_id)"
  COMMISSION_TYPE_CK: '!Standard'
  COMMISSION_RATE: 'comm_disc_rate'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
