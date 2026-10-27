{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 ma_sat() for SAT_PARTY_BANKING.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, PARTY_HKEY, multi-active on ACCOUNT_NUMBER_MASKED.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_sat_party_banking'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'ACCOUNT_NUMBER_MASKED'
src_payload:
  - 'ACCOUNT_HOLDER_NAME'
  - 'ACCOUNT_TYPE'
  - 'BANK_NAME'
  - 'BRANCH_NAME'
  - 'IFSC_CODE'
  - 'MICR_CODE'
  - 'PRIMARY_ACCOUNT_INDICATOR'
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
