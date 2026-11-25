{{ config(materialized='view') }}
-- PARTNER STANDARD-MODEL per-table stage() for LNK_POLICY_LOCATION (Policy Risk Location), table 'OCP_INTERESTED_PARTIES'.
-- BUILD-SIDE: not in the mapper's map. Each non-party leg reuses the exact key expression of its
-- hub's own stage model (stg2_hub_ocp_interested_parties__<hub>), so a leg always matches a hub row.
-- Party leg = part_id space (HUB_PARTY is keyed on part_id). Written by generators/gen_partner_links_extra.py.
{%- set yaml_metadata -%}
source_model: "stg_partner__ocp_interested_parties"
hashed_columns:
  POLICY_HKEY: "POLICY_HKEY_NK"
  LOCATION_HKEY: "LOCATION_HKEY_NK"
  POLICY_LOCATION_HKEY: "POLICY_LOCATION_NK"
derived_columns:
  POLICY_HKEY_NK: "'HUB_POLICY|' || (contract_id)"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || (mailing_address_id)"
  POLICY_LOCATION_NK: "'LNK_POLICY_LOCATION|' || (contract_id) || '|' || (mailing_address_id)"
  LOAD_DATETIME: "INC_JOB_UPDATED_AT"
  RECORD_SOURCE: "!OPUS_PARTNER_OCP_INTERESTED_PARTIES"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
