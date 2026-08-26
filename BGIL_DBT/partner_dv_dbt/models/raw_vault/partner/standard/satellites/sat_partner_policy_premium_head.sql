{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['POLICY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_POLICY_PREMIUM_HEAD (HUB_POLICY grain) -- 2 source table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_hcf_member_dtls__policy_premium_head'
  - 'stg2_sat_bjaz_starpkg_ff_dtls__policy_premium_head'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'BASEAMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
