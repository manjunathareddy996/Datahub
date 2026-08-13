{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_PREMIUM_HEAD, table 'BA_HCP_DT_MEM' (union branch, no attribute-level merge needed).
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): PREMIUM_HEAD_CODE_CK was '!' (a
-- blank literal) on all 5 contributing tables -- a real collision bug: any policy with
-- rows from 2+ of these tables would silently overwrite each other's premium-head amount
-- under AutomateDV's multi-active tracking, since they'd all resolve to the same
-- (POLICY_HK, '') child key. Given a distinct literal per table/column now.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_dt_mem'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BASE_AMOUNT'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  PREMIUM_HEAD_CODE_CK: '!Base Cover'
  BASE_AMOUNT: 'prem_base_cover'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_MEM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
