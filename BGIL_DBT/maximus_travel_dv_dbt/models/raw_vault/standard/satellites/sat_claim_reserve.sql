{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat() for SAT_CLAIM_RESERVE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, multi-active on RESERVE_HEAD.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_sat_claim_reserve'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'RESERVE_HEAD'
src_payload:
  - 'CURRENT_RESERVE_AMOUNT'
  - 'INITIAL_RESERVE_AMOUNT'
  - 'OUTSTANDING_RESERVE_AMOUNT'
  - 'PAID_TO_DATE_AMOUNT'
  - 'RESERVE_TYPE'
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
