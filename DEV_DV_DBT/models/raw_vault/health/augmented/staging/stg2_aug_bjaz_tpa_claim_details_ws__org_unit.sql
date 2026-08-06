{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_ORG_UNIT, table 'BJAZ_TPA_CLAIM_DETAILS_WS'.
-- 2 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_TPA_CLAIM_DETAILS_WS carries a verified HUB_ORG_UNIT key
-- (OPERATING_OFFICE), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  ORG_UNIT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BRANCH_ADDRESS'
      - 'BRANCH_CONTACT_NO'
derived_columns:
  PARENT_BK: 'operating_office'
  PARENT_NK: "'HUB_ORG_UNIT|' || (operating_office)"
  BRANCH_ADDRESS: 'branch_address'
  BRANCH_CONTACT_NO: 'branch_contact_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
