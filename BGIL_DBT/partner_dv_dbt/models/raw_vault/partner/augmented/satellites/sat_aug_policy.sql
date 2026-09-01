{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['POLICY_HKEY', 'MEMBER_SEQUENCE', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER AUGMENTED (unconfirmed) ma_sat_multi_source() for SAT_AUG_POLICY (HUB_POLICY grain).
-- 5 contributing table(s). NOT part of the canonical data_5a.js model -- needs mapper
-- review before being treated as equivalent to a standard-model satellite.
-- MULTI-ACTIVE: MEMBER_SEQUENCE is the child key -- a policy can have multiple members,
-- each with their own bonus/cumulative values. Uses ma_sat_multi_source so the per-table
-- stg2 models are unioned inside the macro (no separate stg2_aug_union__policy view) while
-- preserving the multi-active grain. Grouping is by (POLICY_HKEY, MEMBER_SEQUENCE,
-- RECORD_SOURCE) so a late-arriving source does not create phantom versions in another
-- source's group.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_bjaz_hlt_ensure_mem_dtls__policy'
  - 'stg2_aug_bjaz_hm_member_dtls__policy'
  - 'stg2_aug_bjaz_pa_detl_extn__policy'
  - 'stg2_aug_bjaz_ec_mem_dtls_extn__policy'
  - 'stg2_aug_bjaz_sh_mem_dtls_extn__policy'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'MEMBER_SEQUENCE'
src_payload:
  - 'CUMMULATIVE_AMT'
  - 'CUMM_BONUS'
  - 'CUMM_BONUS_AMT_COMP'
  - 'CUMM_BONUS_AMT_WIDER'
  - 'CUMM_BONUS_COMP'
  - 'CUMM_BONUS_WIDER'
  - 'INCEPTION_DATE'
  - 'PREVIOUS_CUM_AMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_column_map={
                           'stg2_aug_bjaz_hlt_ensure_mem_dtls__policy': ['PREVIOUS_CUM_AMOUNT'],
                           'stg2_aug_bjaz_hm_member_dtls__policy': ['CUMM_BONUS'],
                           'stg2_aug_bjaz_pa_detl_extn__policy': ['CUMMULATIVE_AMT', 'CUMM_BONUS_AMT_COMP', 'CUMM_BONUS_AMT_WIDER', 'CUMM_BONUS_COMP', 'CUMM_BONUS_WIDER'],
                           'stg2_aug_bjaz_ec_mem_dtls_extn__policy': ['INCEPTION_DATE'],
                           'stg2_aug_bjaz_sh_mem_dtls_extn__policy': ['INCEPTION_DATE']
                       }) }}
