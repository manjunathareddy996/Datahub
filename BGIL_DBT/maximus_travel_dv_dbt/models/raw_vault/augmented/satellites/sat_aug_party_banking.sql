{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat() for SAT_AUG_PARTY_BANKING.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- src_pk, grain and src_cdk are the SIBLING's exactly (BUILD_RULES 7.2 / 7.7). The
-- sibling builds this satellite on its augmented track; where this map asks for a grain
-- the sibling does not carry, the SIBLING WINS and the difference is a modeller item
-- in the build report -- it is not resolved here.
--
-- GRAIN DIVERGENCE, reported not resolved: this map declares multi_active=True with
-- child key ['ACCOUNT_NUMBER_MASKED']; the sibling builds it single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_party_banking'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'APPROVED_OR_REJECTED_BY'
  - 'APPROVED_OR_REJECTED_DATE'
  - 'BANK_DETAIL_REMARKS'
  - 'BANK_VERIFIED_ACCOUNT_HOLDER_NAME'
  - 'NEFT_VERIFICATION_STATUS'
  - 'PENNY_DROP_NAME_MATCH_SCORE'
  - 'PENNY_DROP_WAIVED_INDICATOR'
  - 'REFUND_TO_BANK_GUARANTEE_HOLDER_ACCOUNT_REFERENCE'
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
