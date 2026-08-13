{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BA_HCP_PROD_8428_GPG_LOADER'.
-- 2 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_PROD_8428_GPG_LOADER carries a verified HUB_POLICY key
-- (POL_SERIAL_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8428_gpg_loader'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MD_FIRST_POLICY_INCEPTION_DATE'
      - 'MD_PREV_COMP_ADDRESS'
derived_columns:
  PARENT_BK: 'pol_serial_no'
  PARENT_NK: "'HUB_POLICY|' || (pol_serial_no)"
  MD_FIRST_POLICY_INCEPTION_DATE: 'md_first_policy_inception_date'
  MD_PREV_COMP_ADDRESS: 'md_prev_comp_address'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8428_GPG_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
