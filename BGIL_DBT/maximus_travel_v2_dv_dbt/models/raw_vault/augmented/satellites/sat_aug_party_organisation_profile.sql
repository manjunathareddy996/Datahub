{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_AUG_PARTY_ORGANISATION_PROFILE.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, PARTY_HKEY, single-active.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_aug_sat_aug_party_organisation_profile'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'BUSINESS_REGISTRATION_DATE'
  - 'BUSINESS_TYPE_CODE'
  - 'INFRASTRUCTURE_SUB_SECTOR'
  - 'OTHER_INDUSTRY_TYPE_DESCRIPTION'
  - 'REGISTERED_BUSINESS_TRUST_INDICATOR'
  - 'REGISTERED_COMPANY_DECLARED_INDICATOR'
  - 'TRADE_NAME'
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
