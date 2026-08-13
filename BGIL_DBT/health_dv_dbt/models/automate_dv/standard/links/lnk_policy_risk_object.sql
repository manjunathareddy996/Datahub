{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_POLICY_RISK_OBJECT, 5 contributing table(s).
-- Member ends: HUB_POLICY (POLICY_HKEY), HUB_RISK_OBJECT (RISK_OBJECT_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_policy_risk_object.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_prod_8428_gpg_loader__policy_risk_object'
  - 'stg2_link_ba_hcp_prod_8433_fhc_loader__policy_risk_object'
  - 'stg2_link_bjaz_ec_mem_dtls_extn__policy_risk_object'
  - 'stg2_link_bjaz_hcf_member_dtls__policy_risk_object'
  - 'stg2_link_bjaz_ctngy_pa_mem_dtls__policy_risk_object'
src_pk: 'POLICY_RISK_OBJECT_HKEY'
src_fk:
  - 'POLICY_HKEY'
  - 'RISK_OBJECT_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
