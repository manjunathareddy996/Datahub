{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_claim_tpa_interaction -- serves SAT_CLAIM_TPA_INTERACTION.
-- The ONE place CLAIM_HK gets hashed for this cluster (namespaced: 'HUB_CLAIM|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_claim_tpa_interaction'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AUTHORISATION_MESSAGE'
      - 'AUTHORISATION_REMARKS'
      - 'BILL_SUBMISSION_DATE'
      - 'CLAIMED_PACKAGE_AMOUNT'
      - 'DENIAL_REASON'
      - 'ENHANCEMENT_AMOUNT'
      - 'ENHANCEMENT_REQUEST_INDICATOR'
      - 'FINAL_AUTHORISATION_AMOUNT'
      - 'PRE_AUTH_AMOUNT'
      - 'PRE_AUTH_APPROVED_DATE'
      - 'PRE_AUTH_REQUEST_DATE'
      - 'TPA_REFERENCE'
derived_columns:
  CLAIM_NK: "'HUB_CLAIM|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
