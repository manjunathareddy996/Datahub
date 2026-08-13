{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_HM_HCM_EXTRACT'.
-- 3 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_HCM_EXTRACT carries a verified HUB_POLICY key
-- (POLICY), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hcm_extract'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NON_NETWORK_CO_PAY'
      - 'MEMBER_CO_PAY'
      - 'ROOM_RENT_DIFF_CO_PAY'
derived_columns:
  PARENT_BK: 'policy'
  PARENT_NK: "'HUB_POLICY|' || (policy)"
  NON_NETWORK_CO_PAY: 'non_network_co_pay'
  MEMBER_CO_PAY: 'member_co_pay'
  ROOM_RENT_DIFF_CO_PAY: 'room_rent_diff_co_pay'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HCM_EXTRACT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
