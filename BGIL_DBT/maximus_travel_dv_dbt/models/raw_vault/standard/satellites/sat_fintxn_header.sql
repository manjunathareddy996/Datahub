{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat() for SAT_FINTXN_HEADER.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- src_pk, grain and src_cdk are the SIBLING's exactly (BUILD_RULES 7.2 / 7.7). The
-- sibling builds this satellite on its standard track; where this map asks for a grain
-- the sibling does not carry, the SIBLING WINS and the difference is a modeller item
-- in the build report -- it is not resolved here.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_sat_fintxn_header'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_payload:
  - 'ORG_UNIT_CODE'
  - 'SOURCE_REFERENCE_NUMBER'
  - 'SOURCE_REFERENCE_TYPE'
  - 'TRANSACTION_CHANNEL'
  - 'TRANSACTION_DATE'
  - 'TRANSACTION_NUMBER'
  - 'TRANSACTION_TYPE'
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
