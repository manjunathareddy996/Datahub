{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for SAT_AUG_AFFINITY_MEMBERSHIP
-- (HUB_PARTY grain), table 'AZBJ_PARTNER_EXTN'.
-- Mapper-approved LOB-local new satellite (P1, MAPPER_REPLIES_PARTNER.md) -- build-side,
-- no modeler round-trip unless this recurs in another LOB.

{%- set yaml_metadata -%}
source_model: 'stg_partner__azbj_partner_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AA_MEMBERSHIP_NUMBER'
      - 'AA_MEMBERSHIP_EXPIRY_DATE'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  AA_MEMBERSHIP_NUMBER: 'aa_membership_number'
  AA_MEMBERSHIP_EXPIRY_DATE: 'aa_membership_expiry_date'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!AZBJ_PARTNER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
