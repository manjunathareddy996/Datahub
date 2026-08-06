{{ config(materialized='incremental') }}

-- AUGMENTED (unconfirmed) sat() for SAT_AUG_ORG_UNIT (HUB_ORG_UNIT grain).
-- 3 contributing table(s), union (no attribute merge attempted --
-- these columns were never analysed for cross-table overlap, unlike standard-model
-- satellites). NOT part of the canonical data_v4.js model. Needs mapper review before
-- being treated as equivalent to a standard-model satellite -- see docs.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_ba_hcp_prod_8428_gpg_loader__org_unit'
  - 'stg2_aug_ba_hcp_prod_8439_clh_loader__org_unit'
  - 'stg2_aug_bjaz_tpa_claim_details_ws__org_unit'
src_pk: 'ORG_UNIT_HK'
src_payload:
  - 'BRANCH_ADDRESS'
  - 'BRANCH_CONTACT_NO'
  - 'MLAC_EMI_PC_BANK_BRANCH_ADD'
  - 'PLC_BRANCH_ADDRESS'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
