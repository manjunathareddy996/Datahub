{{ config(materialized='incremental') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- hub() fed from a LIST of 5 sources (not 7 raw tables):
--  - stg2_common_address_stitched -- covers BJAZ_EHH_POL_DTLS / BJAZ_HM_HCM_EXTRACT /
--    BJAZ_HM_HOSPITAL_MASTER's location keys. These 3 tables are attribute-JOINed
--    (COALESCEd) together for SAT_COMMON_ADDRESS, so this hub reads them ONLY through that
--    stitched output -- listing their individual stage() outputs here too would bypass the
--    coalesce/dedupe and reintroduce the un-merged version of the same 3 tables.
--  - the 4 party-address tables' own stage() outputs, read directly -- these are only
--    UNION'd (not joined) into the stitch, so there's no coalesce to bypass; hub()'s own
--    union already handles them, no need to route through the stitch as well.
-- Both kinds hash LOCATION_HK from the identical LOCATION_CODE_KEY value, which is the
-- mechanism that makes SAT_PARTY_ADDRESS_USAGE.Location Reference resolvable without a join.
-- Scoped subset of production HUB_LOCATION (7 of 18 source tables) -- extending to the
-- rest is adding more entries: another stitch source for any new attribute-joined cluster,
-- another direct stage() entry for anything union-only.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_common_address_stitched'
  - 'stg2_ba_hcp_pp_mem_dtls'
  - 'stg2_bjaz_bandhan_medi_clam_address'
  - 'stg2_bjaz_hat_id_mem_detls'
  - 'stg2_bjaz_tpa_claim_details_ws_payee'
src_pk: 'LOCATION_HK'
src_nk: 'LOCATION_CODE_KEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
