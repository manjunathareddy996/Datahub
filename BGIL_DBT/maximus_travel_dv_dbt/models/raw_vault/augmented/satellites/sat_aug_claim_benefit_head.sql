{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat() for SAT_AUG_CLAIM_BENEFIT_HEAD.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, multi-active on BENEFIT_HEAD_CODE.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_claim_benefit_head'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'BENEFIT_HEAD_CODE'
src_payload:
  - 'AMOUNT_IN_EXCESS_OF_SUM_INSURED'
  - 'BENEFIT_LIMIT_AMOUNT_USD'
  - 'CLAIMED_AMOUNT_BREAKUP'
  - 'COVER_SUM_INSURED_AMOUNT'
  - 'COVER_SUM_INSURED_CURRENCY'
  - 'COVER_TAKEN_INDICATOR'
  - 'DEDUCTIBLE_AMOUNT'
  - 'DEDUCTIBLE_COMMENT'
  - 'DEDUCTIBLE_WAIVED_INDICATOR'
  - 'DEDUCTION_AMOUNT_BREAKUP'
  - 'EXTENSION_OR_CLAUSE_APPLICABLE_INDICATOR'
  - 'HEAD_LINE_PARTICULARS'
  - 'HEAD_SUM_INSURED_AMOUNT'
  - 'PANDEMIC_COVER_APPLICABLE_INDICATOR'
  - 'SUM_INSURED_VALIDATION_OVERRIDE_INDICATOR'
  - 'SUM_INSURED_VALIDATION_OVERRIDE_REMARKS'
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
