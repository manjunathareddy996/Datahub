{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_CLAIM_HEADER.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, single-active.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_sat_claim_header'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CATASTROPHE_CODE'
  - 'CLAIM_CATEGORY'
  - 'CLAIM_HANDLER_REFERENCE'
  - 'CLAIM_REFERENCE_NUMBER'
  - 'CLAIM_STATUS'
  - 'CLAIM_SUB_STATUS'
  - 'CLAIM_TYPE'
  - 'HANDLING_ORG_UNIT_CODE'
  - 'INTIMATED_BY_ROLE'
  - 'INTIMATION_CHANNEL'
  - 'LOSS_DATE'
  - 'NOTIFICATION_DATE'
  - 'PRIORITY_CODE'
  - 'REGISTRATION_DATE'
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
