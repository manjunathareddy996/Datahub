{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_GRP_HLT_MATERNITY_DTLS'.
-- 4 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_GRP_HLT_MATERNITY_DTLS carries a verified HUB_POLICY key
-- (REG_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_maternity_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLAIMS_REVIEW_CLAUSE'
      - 'CLAIM_REVIEW_PER'
      - 'CRC_REVIEW_PERIOD'
      - 'REFUND_PER_ANNUALLY'
derived_columns:
  PARENT_BK: 'reg_no'
  PARENT_NK: "'HUB_POLICY|' || (reg_no)"
  CLAIMS_REVIEW_CLAUSE: 'claims_review_clause'
  CLAIM_REVIEW_PER: 'claim_review_per'
  CRC_REVIEW_PERIOD: 'crc_review_period'
  REFUND_PER_ANNUALLY: 'refund_per_annually'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_MATERNITY_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
