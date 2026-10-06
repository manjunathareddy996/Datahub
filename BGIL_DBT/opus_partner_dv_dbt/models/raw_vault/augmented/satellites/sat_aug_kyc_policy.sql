{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC AUGMENTED (unconfirmed) sat() for SAT_AUG_KYC_POLICY (HUB_POLICY grain).
-- 1 contributing table(s). LOB-local satellite for mapper-proposed attributes that are
-- NOT in data_7 (map target: SAT_POLICY_HEADER) -- needs mapper review before being
-- treated as equivalent to a standard-model satellite.
-- Kept separate from sat_aug_policy so its hashdiff is not re-chained.
-- Rows whose FIELD_TYPE is not POLICY% carry a NULL POLICY_HKEY and are dropped by
-- automate_dv.sat's src_pk IS NOT NULL filter.

{%- set yaml_metadata -%}
source_model: 'stg2_aug_bjaz_t_kyc_incoming__policy'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'SALES_ORDER_NUMBER'
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
