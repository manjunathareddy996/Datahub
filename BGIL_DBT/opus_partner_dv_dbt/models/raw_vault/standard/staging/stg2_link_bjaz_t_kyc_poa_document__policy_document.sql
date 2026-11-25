{{ config(materialized='view') }}
-- PARTNER STANDARD-MODEL per-table stage() for LNK_POLICY_DOCUMENT (Policy Document), table 'BJAZ_T_KYC_POA_DOCUMENT'.
-- BUILD-SIDE: not in the mapper's map. Each non-party leg reuses the exact key expression of its
-- hub's own stage model (stg2_hub_bjaz_t_kyc_poa_document__<hub>), so a leg always matches a hub row.
-- Party leg = part_id space (HUB_PARTY is keyed on part_id). Written by generators/gen_partner_links_extra.py.
{%- set yaml_metadata -%}
source_model: "stg_partner__bjaz_t_kyc_poa_document"
hashed_columns:
  POLICY_HKEY: "POLICY_HKEY_NK"
  DOCUMENT_HKEY: "DOCUMENT_HKEY_NK"
  POLICY_DOCUMENT_HKEY: "POLICY_DOCUMENT_NK"
derived_columns:
  POLICY_HKEY_NK: "'HUB_POLICY|' || (upper(case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end))"
  DOCUMENT_HKEY_NK: "'HUB_DOCUMENT|' || (upper(trim(coalesce(docs_type,''))) || ':' || upper(trim(coalesce(docs_number,''))))"
  POLICY_DOCUMENT_NK: "'LNK_POLICY_DOCUMENT|' || (upper(case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end)) || '|' || (upper(trim(coalesce(docs_type,''))) || ':' || upper(trim(coalesce(docs_number,''))))"
  LOAD_DATETIME: "INC_JOB_UPDATED_AT"
  RECORD_SOURCE: "!OPUS_PARTNER_BJAZ_T_KYC_POA_DOCUMENT"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
