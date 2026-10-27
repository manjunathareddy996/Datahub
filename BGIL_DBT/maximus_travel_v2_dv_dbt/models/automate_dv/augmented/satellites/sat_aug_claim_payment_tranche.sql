{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 ma_sat() for SAT_AUG_CLAIM_PAYMENT_TRANCHE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, multi-active on TRANCHE_NUMBER.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_aug_sat_aug_claim_payment_tranche'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'TRANCHE_NUMBER'
src_payload:
  - 'AOL_MODE_CODE'
  - 'CASHLESS_CLAIM_TYPE'
  - 'DAMAGE_TYPE_CODE'
  - 'FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME'
  - 'FIXED_DEPOSIT_RECEIPT_TENURE'
  - 'INTEREST_AMOUNT'
  - 'PAYABLE_INDICATOR'
  - 'PAYMENT_AUTHORISATION_DATE'
  - 'PAYMENT_DUE_DATE'
  - 'PAYMENT_NARRATION'
  - 'PAYMENT_REFERENCE_NUMBER'
  - 'PAYMENT_RELEASE_CONFIRMED_INDICATOR'
  - 'PAYMENT_REMARKS'
  - 'POLICY_SECTION_CODE'
  - 'PORTAL_PAYMENT_REFERENCE_NUMBER'
  - 'RESERVE_HEAD_CODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
