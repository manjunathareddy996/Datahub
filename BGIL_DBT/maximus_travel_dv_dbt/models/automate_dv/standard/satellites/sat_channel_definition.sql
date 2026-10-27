{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_CHANNEL_DEFINITION.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, DISTRIBUTION_CHANNEL_HKEY, single-active.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_sat_channel_definition'
src_pk: 'DISTRIBUTION_CHANNEL_HKEY'
src_payload:
  - 'CHANNEL_NAME'
  - 'CHANNEL_REMARKS'
  - 'CHANNEL_TYPE'
  - 'SUB_CHANNEL_CODE'
  - 'SUB_CHANNEL_EFFECTIVE_DATE'
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
