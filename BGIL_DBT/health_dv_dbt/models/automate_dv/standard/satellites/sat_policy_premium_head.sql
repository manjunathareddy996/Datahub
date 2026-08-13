{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_POLICY_PREMIUM_HEAD (HUB_POLICY grain) -- union of 7 branch(es) across 5 table(s), no join needed.
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): child key was already declared
-- (PREMIUM_HEAD_CODE_CK), but every contributing table shared the same blank '!' literal
-- -- a real collision bug (see each stage file's header). Fixed with a distinct literal
-- per table/premium-head concept; BJAZ_GRP_HLT_MATERNITY_DTLS split into two branches
-- (two genuinely different premium heads were forced onto one row).
-- data_7 sync (MAPPER_NOTE_HEALTH_DATA7_SYNC.md): literals aligned to the mapper's exact
-- child-key tokens (Per-Person Basis / Add-On / Surgical Cover); BJAZ_HCF_MEMBER_DTLS
-- split into two branches too -- FLOAT_PREMIUM ('Floater') was sitting unbuilt on this
-- table's own staging model even though ADON_PREMIUM ('Add-On') was already wired in.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_dt_mem__policy_premium_head'
  - 'stg2_sat_bjaz_grp_hlt_dtls__policy_premium_head'
  - 'stg2_sat_bjaz_grp_hlt_maternity_dtls__policy_premium_head'
  - 'stg2_sat_bjaz_grp_hlt_maternity_dtls__policy_premium_head_2'
  - 'stg2_sat_bjaz_hcf_member_dtls__policy_premium_head'
  - 'stg2_sat_bjaz_hcf_member_dtls__policy_premium_head_2'
  - 'stg2_sat_bjaz_health_webservice_info__policy_premium_head'
src_pk: 'POLICY_HK'
src_cdk:
  - 'PREMIUM_HEAD_CODE_CK'
src_payload:
  - 'BASE_AMOUNT'
  - 'NET_HEAD_PREMIUM'
  - 'PREMIUM_BASIS'
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
