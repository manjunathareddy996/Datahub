{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_CLAIM_PARTY, 14 contributing table(s).
-- Member ends: HUB_CLAIM (CLAIM_HKEY), HUB_PARTY (PARTY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_claim_party.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_bandhan_medi_clam__claim_party'
  - 'stg2_link_bjaz_hat_case_ocr_dtls__claim_party'
  - 'stg2_link_bjaz_hm_bill_payment__claim_party'
  - 'stg2_link_bjaz_hm_cashless_inward__claim_party'
  - 'stg2_link_bjaz_hm_clm_register__claim_party'
  - 'stg2_link_bjaz_hm_coinsu_clm_dtls__claim_party'
  - 'stg2_link_bjaz_hm_hcm_extract__claim_party'
  - 'stg2_link_bjaz_hm_investi_payment__claim_party'
  - 'stg2_link_bjaz_hm_inward_dtls__claim_party'
  - 'stg2_link_bjaz_hm_preauth_enhance__claim_party'
  - 'stg2_link_bjaz_hm_preauth_query__claim_party'
  - 'stg2_link_bjaz_remedinet_claim_details__claim_party'
  - 'stg2_link_bjaz_tpa_claim_details_ws__claim_party'
  - 'stg2_link_bjaz_clm_pre_auth_hlt_dtls__claim_party'
src_pk: 'CLAIM_PARTY_HKEY'
src_fk:
  - 'CLAIM_HKEY'
  - 'PARTY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
