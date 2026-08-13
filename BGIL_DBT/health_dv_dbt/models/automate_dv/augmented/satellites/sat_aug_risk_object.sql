{{ config(materialized='incremental') }}

-- AUGMENTED (unconfirmed) sat() for SAT_AUG_RISK_OBJECT (HUB_RISK_OBJECT grain).
-- 4 contributing table(s), union (no attribute merge attempted --
-- these columns were never analysed for cross-table overlap, unlike standard-model
-- satellites). NOT part of the canonical data_v4.js model. Needs mapper review before
-- being treated as equivalent to a standard-model satellite -- see docs.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_ba_hcp_prod_8428_gpg_loader__risk_object'
  - 'stg2_aug_ba_hcp_prod_8433_fhc_loader__risk_object'
  - 'stg2_aug_bjaz_ec_mem_dtls_extn__risk_object'
  - 'stg2_aug_bjaz_hcf_member_dtls__risk_object'
src_pk: 'RISK_OBJECT_HK'
src_payload:
  - 'AGE_PROOF_FLAG'
  - 'DECEASE_TREATMENT_DTLS'
  - 'FMLY_HLTH_COMPLAINS'
  - 'MD_SPCL_CONDTN_MEMBER_LEVEL'
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
