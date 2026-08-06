{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_FIN_CHARGE_RATE, table 'BJAZ_GRP_TPA_EXTN' (single contributing table).
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): data_7 made this satellite
-- multi-active, child key 'Charge Type'. Both columns on this table (SERVICE_CHARGE_AMT/
-- SERVICE_CHARGE_RATE) are the same charge concept, so CHARGE_TYPE_CK is a literal
-- derived from the source column name, not fabricated data.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_tpa_extn'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHARGE_AMOUNT'
      - 'CHARGE_RATE'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  CHARGE_TYPE_CK: '!Service Charge'
  CHARGE_AMOUNT: 'service_charge_amt'
  CHARGE_RATE: 'service_charge_rate'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_TPA_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
