{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_PARTY_CONTACT_ADDRESS_LINK, per data_5a.js (parent
-- LNK_PARTY_LOCATION, childkey "Address Usage Type" only -- re-parented from HUB_PARTY,
-- see MODELER_QUESTION_PARTY_CONTACT_ADDRESS_LINK.md / the modeler's fix). Replaces the
-- removed SAT_PARTY_ADDRESS_USAGE; the actual address text lives on SAT_COMMON_ADDRESS,
-- this satellite only carries usage context.
--
-- Payload gap, not an oversight: of this satellite's 8 canonical attributes (Primary
-- Address Indicator, Address From/To Date, Address Ownership Type, Years At Address,
-- Address Proof Type, Address Verified Indicator, plus Address Usage Type itself), only
-- Address Usage Type has real source data across all 5 contributing branches -- the other
-- 7 are genuinely absent from BA_HCP_PP_MEM_DTLS / BJAZ_BANDHAN_MEDI_CLAM /
-- BJAZ_TPA_CLAIM_DETAILS_WS / BJAZ_HAT_ID_MEM_DETLS. Left unbuilt, not fabricated.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_addrusage_ba_hcp_pp_mem_dtls'
  - 'stg2_addrusage_bjaz_bandhan_medi_clam'
  - 'stg2_addrusage_bjaz_tpa_claim_details_ws'
  - 'stg2_addrusage_bjaz_hat_id_mem_detls'
src_pk: 'PARTY_LOCATION_HKEY'
src_cdk:
  - 'ADDRESS_USAGE_TYPE'
src_payload:
  - 'ADDRESS_USAGE_TYPE'
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
