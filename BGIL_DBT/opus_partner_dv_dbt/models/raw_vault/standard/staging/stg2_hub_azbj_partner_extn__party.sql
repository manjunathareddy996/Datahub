{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_PARTY branch 'AZBJ_PARTNER_EXTN'.
-- Provenance: explicit. PART_ID is a verified HUB_PARTY key (same key space as
-- CP_PARTNERS.part_id). Added to close DM-R1 item 6 orphans: ~45.6k AZBJ part_ids
-- are not present in CP_PARTNERS, so CP_PARTNERS alone is NOT the full key set.

{%- set yaml_metadata -%}
source_model: 'stg_partner__azbj_partner_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_AZBJ_PARTNER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
