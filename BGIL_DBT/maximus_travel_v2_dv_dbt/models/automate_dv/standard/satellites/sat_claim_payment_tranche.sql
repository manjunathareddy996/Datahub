{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 ma_sat() for SAT_CLAIM_PAYMENT_TRANCHE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, multi-active on TRANCHE_NUMBER.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_sat_claim_payment_tranche'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'TRANCHE_NUMBER'
src_payload:
  - 'APPROVAL_REFERENCE'
  - 'FINAL_INDICATOR'
  - 'GROSS_AMOUNT'
  - 'HOLD_INDICATOR'
  - 'HOLD_REASON'
  - 'NET_AMOUNT'
  - 'PAYMENT_DATE'
  - 'PAYMENT_MODE'
  - 'PAYMENT_TYPE'
  - 'STATUS'
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
