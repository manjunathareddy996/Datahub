{{ config(materialized='incremental') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- Multi-active satellite on HUB_PARTY. src_cdk = [ADDRESS_USAGE_TYPE, SEQUENCE_CK] is the
-- canonical "Address Usage Type + Sequence" child key from data_v4.js. SEQUENCE_CK is a
-- constant '1' -- none of the 4 source tables actually carries more than one address per
-- usage type, so there is nothing genuine to sequence; kept as a placeholder column, not
-- fabricated data.
--
-- payload is ONLY location_hk (the "Location Reference" attribute) -- this is the fix:
-- the raw address text does NOT live here, it lives in SAT_COMMON_ADDRESS keyed by the
-- same LOCATION_HK. Still-unmapped canonical attributes (Role Context, Preferred
-- Indicator, Effective From Date) are genuinely absent from every source table the
-- mapper tagged against this satellite -- left out, not assumed. See build notes /
-- mapper follow-up for the open question.
--
-- source_model is a LIST of 4 per-table stage() outputs, same union-by-macro pattern as
-- hub(). This is a genuine row-union, not attribute merging -- each table contributes its
-- own complete, self-contained (party, usage type) row, nothing to coalesce -- so unlike
-- SAT_COMMON_ADDRESS this doesn't need a stitch step even if it needs multiple tables.
-- UNVERIFIED: every documented ma_sat()/sat() example uses a single source_model string;
-- hub()/link()'s multi-source union is explicitly documented, ma_sat()'s is not confirmed
-- either way without a real dbt compile. If ma_sat() rejects a list, the fallback is a
-- one-line UNION ALL pass-through view over these same 4 stage() outputs (row-stacking
-- only, still not a join) feeding ma_sat() as a single source -- not a redesign.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_ba_hcp_pp_mem_dtls'
  - 'stg2_bjaz_bandhan_medi_clam_address'
  - 'stg2_bjaz_hat_id_mem_detls'
  - 'stg2_bjaz_tpa_claim_details_ws_payee'
src_pk: 'PARTY_HK'
src_cdk:
  - 'ADDRESS_USAGE_TYPE'
  - 'SEQUENCE_CK'
src_payload:
  - 'LOCATION_HK'
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
