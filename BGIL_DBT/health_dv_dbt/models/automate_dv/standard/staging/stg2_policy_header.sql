{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_policy_header -- serves SAT_POLICY_HEADER.
-- The ONE place POLICY_HK gets hashed for this cluster (namespaced: 'HUB_POLICY|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_policy_header'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVER_NOTE_DATE'
      - 'COVER_NOTE_REFERENCE'
      - 'FIRST_YEAR_INDICATOR'
      - 'ISSUE_DATE'
      - 'MASTER_POLICY_REFERENCE'
      - 'POLICY_NUMBER'
      - 'POLICY_REMARKS'
      - 'POLICY_STATUS'
      - 'POLICY_TERM'
      - 'POLICY_TERM_DAYS'
      - 'POLICY_TYPE'
      - 'PREMIUM_PAYER_REFERENCE'
      - 'RISK_EXPIRY_DATE'
      - 'RISK_INCEPTION_DATE'
      - 'RISK_START_TIME'
      - 'SUM_INSURED_BASIS'
      - 'SUM_INSURED_TOTAL'
      - 'TOP_UP_POLICY_INDICATOR'
derived_columns:
  POLICY_NK: "'HUB_POLICY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
