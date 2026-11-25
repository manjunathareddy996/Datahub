{{ config(materialized='view') }}
-- PARTNER STANDARD-MODEL per-table stage() for LNK_PARTY_CHANNEL (Party via Channel), table 'BJAZ_CLM_SUPP_EXTN'.
-- BUILD-SIDE: not in the mapper's map. Each non-party leg reuses the exact key expression of its
-- hub's own stage model (stg2_hub_bjaz_clm_supp_extn__<hub>), so a leg always matches a hub row.
-- Party leg = part_id space (HUB_PARTY is keyed on part_id). Written by generators/gen_partner_links_extra.py.
{%- set yaml_metadata -%}
source_model: "stg_partner__bjaz_clm_supp_extn"
hashed_columns:
  PARTY_HKEY: "PARTY_HKEY_NK"
  DISTRIBUTION_CHANNEL_HKEY: "DISTRIBUTION_CHANNEL_HKEY_NK"
  PARTY_CHANNEL_HKEY: "PARTY_CHANNEL_NK"
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || partner_id"
  DISTRIBUTION_CHANNEL_HKEY_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (imd_code)"
  PARTY_CHANNEL_NK: "'LNK_PARTY_CHANNEL|' || (partner_id) || '|' || (imd_code)"
  LOAD_DATETIME: "INC_JOB_UPDATED_AT"
  RECORD_SOURCE: "!OPUS_PARTNER_BJAZ_CLM_SUPP_EXTN"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
