{{ config(materialized='incremental') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- hub() fed directly from a LIST of 4 per-source-table stage() outputs, unioned and
-- deduped by hub() itself on PARTY_HK -- no custom pre-union SQL. Same pattern the
-- production intermediate hub views already use conceptually (UNION ALL across every
-- table that carries the key), just delegated to hub() instead of hand-written.
-- Scoped subset of production HUB_PARTY (only these 4 tables, vs. ~20 branches in
-- production) -- extending to the rest is adding more entries to this same list.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_ba_hcp_pp_mem_dtls'
  - 'stg2_bjaz_bandhan_medi_clam_address'
  - 'stg2_bjaz_hat_id_mem_detls'
  - 'stg2_bjaz_tpa_claim_details_ws_payee'
src_pk: 'PARTY_HK'
src_nk: 'PARTY_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
