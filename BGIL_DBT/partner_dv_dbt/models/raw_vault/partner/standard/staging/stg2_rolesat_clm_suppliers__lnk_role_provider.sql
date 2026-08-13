{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_LNK_ROLE_PROVIDER, table 'CLM_SUPPLIERS'.
-- role-special: built directly off HUB_PARTY with a literal role_type_ck
-- ('provider') -- same modelling deviation ratified for Health (M3): a
-- load-time provenance label, not a fabricated business key.

{%- set yaml_metadata -%}
source_model: 'stg_partner__clm_suppliers'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMPANELMENT_DATE'
      - 'RE_EMPANELMENT_DUE_DATE'
      - 'EMPANELMENT_STATUS'
      - 'PROVIDER_TYPE'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  ROLE_TYPE_CK: '!provider'
  EMPANELMENT_DATE: 'eff_date'
  RE_EMPANELMENT_DUE_DATE: 'exp_date'
  EMPANELMENT_STATUS: 'supp_status'
  PROVIDER_TYPE: 'supp_type'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!CLM_SUPPLIERS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
