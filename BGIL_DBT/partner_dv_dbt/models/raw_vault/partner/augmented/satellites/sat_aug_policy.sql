{{ config(materialized='incremental') }}

-- PARTNER AUGMENTED (unconfirmed) ma_sat() for SAT_AUG_POLICY (HUB_POLICY grain).
-- 5 contributing table(s), union. NOT part of the canonical
-- data_5a.js model -- needs mapper review before being treated as equivalent to a
-- standard-model satellite.
-- MULTI-ACTIVE FIX (mapper feedback round 2): rebuilt from sat() to ma_sat() with
-- MEMBER_SEQUENCE as child key -- a policy can have multiple members, each with their own
-- bonus/cumulative values; a single-active sat() would have collapsed them into one row per
-- policy. Tables with no real member column (BJAZ_HM_MEMBER_DTLS, BJAZ_PA_DETL_EXTN) carry a
-- literal '0' placeholder so they still union cleanly.

{%- set yaml_metadata -%}
source_model: 'stg2_aug_union__policy'
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

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
