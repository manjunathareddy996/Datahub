{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_ECARD_POL_DTLS_CONFIG'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_ECARD_POL_DTLS_CONFIG carries a verified HUB_POLICY key
-- (POLICY_REF), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ecard_pol_dtls_config'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INCEPTION_WINPRD'
derived_columns:
  PARENT_BK: 'policy_ref'
  PARENT_NK: "'HUB_POLICY|' || (policy_ref)"
  INCEPTION_WINPRD: 'inception_winprd'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_ECARD_POL_DTLS_CONFIG'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
