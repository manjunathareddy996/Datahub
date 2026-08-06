{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BGIL_GMC_FINAL_INSTL_DATA'.
-- 3 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BGIL_GMC_FINAL_INSTL_DATA carries a verified HUB_POLICY key
-- (POLICY_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bgil_gmc_final_instl_data'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ELIGIBLE_DAYS'
      - 'PRORATA_PREMIUM'
      - 'FINAL_PAYABLE'
derived_columns:
  PARENT_BK: 'policy_no'
  PARENT_NK: "'HUB_POLICY|' || (policy_no)"
  ELIGIBLE_DAYS: 'eligible_days'
  PRORATA_PREMIUM: 'prorata_premium'
  FINAL_PAYABLE: 'final_payable'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BGIL_GMC_FINAL_INSTL_DATA'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
