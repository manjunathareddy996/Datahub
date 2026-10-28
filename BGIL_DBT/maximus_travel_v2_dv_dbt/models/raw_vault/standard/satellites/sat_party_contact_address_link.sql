{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 ma_sat() for SAT_PARTY_CONTACT_ADDRESS_LINK.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, PARTY_LOCATION_HKEY, multi-active on ADDRESS_USAGE_TYPE.

{%- set yaml_metadata -%}
source_model: 'satfeed_mtv2_sat_party_contact_address_link'
src_pk: 'PARTY_LOCATION_HKEY'
src_cdk:
  - 'ADDRESS_USAGE_TYPE'
src_payload:
  - 'ADDRESS_PROOF_TYPE'
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
