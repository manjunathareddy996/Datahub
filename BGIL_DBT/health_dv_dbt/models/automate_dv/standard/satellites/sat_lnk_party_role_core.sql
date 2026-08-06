{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_LNK_PARTY_ROLE_CORE (HUB_PARTY grain) -- union of 4 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_prod_8428_gpg_loader__lnk_party_role_core'
  - 'stg2_sat_ba_hcp_prod_8432_ecp_loader__lnk_party_role_core'
  - 'stg2_sat_ba_hcp_prod_8433_fhc_loader__lnk_party_role_core'
  - 'stg2_sat_ba_hcp_prod_8439_clh_loader__lnk_party_role_core'
src_pk: 'PARTY_HK'
src_cdk:
  - 'ROLE_CODE_CK'
  - 'ROLE_SEQUENCE_CK'
src_payload:
  - 'ROLE_CATEGORY'
  - 'ROLE_TYPE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
