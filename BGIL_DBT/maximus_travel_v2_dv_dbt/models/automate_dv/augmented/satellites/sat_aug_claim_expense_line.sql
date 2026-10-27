{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_AUG_CLAIM_EXPENSE_LINE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, single-active.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_aug_sat_aug_claim_expense_line'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'EXPENSE_AMOUNT'
  - 'EXPENSE_FEE_HEAD_CODE'
  - 'EXPENSE_FEE_HEAD_DESCRIPTION'
  - 'EXPENSE_PAYMENT_AMOUNT'
  - 'EXPENSE_PAYMENT_APPROVER_REFERENCE'
  - 'EXPENSE_PAYMENT_DATE'
  - 'EXPENSE_PAYMENT_MODE'
  - 'EXPENSE_PAYMENT_NARRATION'
  - 'EXPENSE_PAYMENT_PORTAL_REFERENCE_NUMBER'
  - 'EXPENSE_PAYMENT_REFERENCE_NUMBER'
  - 'EXPENSE_PAYMENT_TYPE'
  - 'EXPENSE_TYPE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
