{{ config(materialized='view') }}
-- PARTNER STANDARD-MODEL per-table stage() for LNK_POLICY_ORG_UNIT (Policy Org Unit), table 'BJAZ_T_KYC_POI_DOCUMENT'.
-- BUILD-SIDE: not in the mapper's map. Each non-party leg reuses the exact key expression of its
-- hub's own stage model (stg2_hub_bjaz_t_kyc_poi_document__<hub>), so a leg always matches a hub row.
-- Party leg = part_id space (HUB_PARTY is keyed on part_id). Written by generators/gen_partner_links_extra.py.
{%- set yaml_metadata -%}
source_model: "stg_partner__bjaz_t_kyc_poi_document"
hashed_columns:
  POLICY_HKEY: "POLICY_HKEY_NK"
  ORG_UNIT_HKEY: "ORG_UNIT_HKEY_NK"
  POLICY_ORG_UNIT_HKEY: "POLICY_ORG_UNIT_NK"
derived_columns:
  POLICY_HKEY_NK: "'HUB_POLICY|' || (upper(case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end))"
  ORG_UNIT_HKEY_NK: "'HUB_ORG_UNIT|' || (upper(trim(business_unit)))"
  POLICY_ORG_UNIT_NK: "'LNK_POLICY_ORG_UNIT|' || (upper(case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end)) || '|' || (upper(trim(business_unit)))"
  LOAD_DATETIME: "INC_JOB_UPDATED_AT"
  RECORD_SOURCE: "!OPUS_PARTNER_BJAZ_T_KYC_POI_DOCUMENT"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
