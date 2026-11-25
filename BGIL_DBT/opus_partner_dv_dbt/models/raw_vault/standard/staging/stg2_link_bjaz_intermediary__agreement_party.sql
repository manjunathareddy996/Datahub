{{ config(materialized='view') }}
-- PARTNER STANDARD-MODEL per-table stage() for LNK_AGREEMENT_PARTY (Agreement Party), table 'BJAZ_INTERMEDIARY'.
-- BUILD-SIDE: not in the mapper's map. Each non-party leg reuses the exact key expression of its
-- hub's own stage model (stg2_hub_bjaz_intermediary__<hub>), so a leg always matches a hub row.
-- Party leg = part_id space (HUB_PARTY is keyed on part_id). Written by generators/gen_partner_links_extra.py.
{%- set yaml_metadata -%}
source_model: "stg_partner__bjaz_intermediary"
hashed_columns:
  AGREEMENT_HKEY: "AGREEMENT_HKEY_NK"
  PARTY_HKEY: "PARTY_HKEY_NK"
  AGREEMENT_PARTY_HKEY: "AGREEMENT_PARTY_NK"
derived_columns:
  AGREEMENT_HKEY_NK: "'HUB_AGREEMENT|' || (intermediary_id)"
  PARTY_HKEY_NK: "'HUB_PARTY|' || partner_id"
  AGREEMENT_PARTY_NK: "'LNK_AGREEMENT_PARTY|' || (intermediary_id) || '|' || (partner_id)"
  LOAD_DATETIME: "INC_JOB_UPDATED_AT"
  RECORD_SOURCE: "!OPUS_PARTNER_BJAZ_INTERMEDIARY"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
