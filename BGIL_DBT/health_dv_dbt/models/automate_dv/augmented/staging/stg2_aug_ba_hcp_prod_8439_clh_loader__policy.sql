{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BA_HCP_PROD_8439_CLH_LOADER'.
-- 2 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_PROD_8439_CLH_LOADER carries a verified HUB_POLICY key
-- (POL_SERIAL_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8439_clh_loader'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PLC_EMI_INR'
      - 'MD_PREV_EXPIRY_DATE'
derived_columns:
  PARENT_BK: 'pol_serial_no'
  PARENT_NK: "'HUB_POLICY|' || (pol_serial_no)"
  PLC_EMI_INR: 'plc_emi_inr'
  MD_PREV_EXPIRY_DATE: 'md_prev_expiry_date'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8439_CLH_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
