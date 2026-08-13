{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_claim_provider_billing -- serves SAT_CLAIM_PROVIDER_BILLING.
-- The ONE place CLAIM_HK gets hashed for this cluster (namespaced: 'HUB_CLAIM|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash). Child key column(s) (bill_number_ck) pass through unchanged via
-- include_source_columns=true -- this satellite is multi-active.

{%- set yaml_metadata -%}
source_model: 'stitch_claim_provider_billing'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'AUTHORISED_AMOUNT'
      - 'BILL_DATE'
      - 'BILL_NUMBER'
      - 'BILL_STATUS_TYPE'
      - 'BILL_TYPE'
      - 'BILLED_AMOUNT'
      - 'DISALLOWANCE_REASON'
      - 'DISALLOWED_AMOUNT'
derived_columns:
  CLAIM_NK: "'HUB_CLAIM|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
