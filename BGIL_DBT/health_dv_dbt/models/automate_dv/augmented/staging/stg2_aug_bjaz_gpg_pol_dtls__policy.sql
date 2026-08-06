{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_GPG_POL_DTLS'.
-- 2 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_GPG_POL_DTLS carries a verified HUB_POLICY key
-- (REFERENCE_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_gpg_pol_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FULL_YR_NET_PREM'
      - 'PREV_POLICY_EXPIRY'
derived_columns:
  PARENT_BK: 'reference_id'
  PARENT_NK: "'HUB_POLICY|' || (reference_id)"
  FULL_YR_NET_PREM: 'full_yr_net_prem'
  PREV_POLICY_EXPIRY: 'prev_policy_expiry'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GPG_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
