{{ config(materialized='view') }}
-- PARTNER STANDARD-MODEL per-table stage() for LNK_PARTY_ORG_UNIT (Party Serviced By Org Unit), table 'BJAZ_T_CKYC_OTP'.
-- BUILD-SIDE: not in the mapper's map. Each non-party leg reuses the exact key expression of its
-- hub's own stage model (stg2_hub_bjaz_t_ckyc_otp__<hub>), so a leg always matches a hub row.
-- Party leg = part_id space (HUB_PARTY is keyed on part_id). Written by generators/gen_partner_links_extra.py.
{%- set yaml_metadata -%}
source_model: "stage_kyc__bjaz_t_ckyc_otp"
hashed_columns:
  PARTY_HKEY: "PARTY_HKEY_NK"
  ORG_UNIT_HKEY: "ORG_UNIT_HKEY_NK"
  PARTY_ORG_UNIT_HKEY: "PARTY_ORG_UNIT_NK"
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || part_id"
  ORG_UNIT_HKEY_NK: "'HUB_ORG_UNIT|' || (trim(business_unit))"
  PARTY_ORG_UNIT_NK: "'LNK_PARTY_ORG_UNIT|' || (part_id) || '|' || (trim(business_unit))"
  LOAD_DATETIME: "INC_JOB_UPDATED_AT"
  RECORD_SOURCE: "!OPUS_PARTNER_BJAZ_T_CKYC_OTP"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
