{{ config(materialized='view') }}
-- PARTNER STANDARD-MODEL per-table stage() for LNK_CLAIM_RISK_OBJECT (Claim Risk Object), table 'CLM_INTERESTED_PARTIES'.
-- BUILD-SIDE: not in the mapper's map. Each non-party leg reuses the exact key expression of its
-- hub's own stage model (stg2_hub_clm_interested_parties__<hub>), so a leg always matches a hub row.
-- Party leg = part_id space (HUB_PARTY is keyed on part_id). Written by generators/gen_partner_links_extra.py.
{%- set yaml_metadata -%}
source_model: "stg_partner__clm_interested_parties"
hashed_columns:
  CLAIM_HKEY: "CLAIM_HKEY_NK"
  RISK_OBJECT_HKEY: "RISK_OBJECT_HKEY_NK"
  CLAIM_RISK_OBJECT_HKEY: "CLAIM_RISK_OBJECT_NK"
derived_columns:
  CLAIM_HKEY_NK: "'HUB_CLAIM|' || (claim_id)"
  RISK_OBJECT_HKEY_NK: "'HUB_RISK_OBJECT|' || (ins_obj_uid)"
  CLAIM_RISK_OBJECT_NK: "'LNK_CLAIM_RISK_OBJECT|' || (claim_id) || '|' || (ins_obj_uid)"
  LOAD_DATETIME: "INC_JOB_UPDATED_AT"
  RECORD_SOURCE: "!OPUS_PARTNER_CLM_INTERESTED_PARTIES"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
