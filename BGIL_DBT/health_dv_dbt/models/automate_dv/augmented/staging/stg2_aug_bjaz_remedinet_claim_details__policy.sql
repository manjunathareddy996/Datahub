{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_REMEDINET_CLAIM_DETAILS'.
-- 2 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_REMEDINET_CLAIM_DETAILS carries a verified HUB_POLICY key
-- (POLICY_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_remedinet_claim_details'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PATIENT_PAID_AMOUNT'
      - 'COPAY_TYPE'
derived_columns:
  PARENT_BK: 'policy_no'
  PARENT_NK: "'HUB_POLICY|' || (policy_no)"
  PATIENT_PAID_AMOUNT: 'patient_paid_amount'
  COPAY_TYPE: 'copay_type'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_REMEDINET_CLAIM_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
