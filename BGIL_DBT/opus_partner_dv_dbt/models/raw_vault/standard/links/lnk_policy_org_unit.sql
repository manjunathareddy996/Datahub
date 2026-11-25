{{ config(materialized='incremental') }}
-- PARTNER STANDARD-MODEL link() for LNK_POLICY_ORG_UNIT (Policy Org Unit), 10 contributing table(s). BUILD-SIDE: not in the mapper's map.
-- Writes the SAME physical table as the other builds' model of the same name.
{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_t_ckyc_otp__policy_org_unit'
  - 'stg2_link_bjaz_t_ckyc_search__policy_org_unit'
  - 'stg2_link_bjaz_t_ekyc__policy_org_unit'
  - 'stg2_link_bjaz_t_kyc_auth__policy_org_unit'
  - 'stg2_link_bjaz_t_kyc_details__policy_org_unit'
  - 'stg2_link_bjaz_t_kyc_incoming__policy_org_unit'
  - 'stg2_link_bjaz_t_kyc_name_match__policy_org_unit'
  - 'stg2_link_bjaz_t_kyc_ocr__policy_org_unit'
  - 'stg2_link_bjaz_t_kyc_poa_document__policy_org_unit'
  - 'stg2_link_bjaz_t_kyc_poi_document__policy_org_unit'
src_pk: 'POLICY_ORG_UNIT_HKEY'
src_fk:
  - 'ORG_UNIT_HKEY'
  - 'POLICY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
