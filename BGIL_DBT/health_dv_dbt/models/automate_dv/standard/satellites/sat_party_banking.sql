{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_PARTY_BANKING (HUB_PARTY grain) -- stitch-backed, 4 table(s) joined.
-- Source: stg2_party_banking.

{%- set yaml_metadata -%}
source_model: 'stg2_party_banking'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'ACCOUNT_NUMBER_MASKED_CK'
src_payload:
  - 'ACCOUNT_HOLDER_NAME'
  - 'ACCOUNT_NUMBER_MASKED'
  - 'ACCOUNT_STATUS'
  - 'ACCOUNT_TYPE'
  - 'BANK_NAME'
  - 'IFSC_CODE'
  - 'MICR_CODE'
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
