{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_PARTY_KYC_REFERENCE (HUB_PARTY grain) -- 2 source table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_cp_part_hist__party_kyc_reference'
  - 'stg2_sat_cp_partners__party_kyc_reference'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'KYCREFERENCETYPE'
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
