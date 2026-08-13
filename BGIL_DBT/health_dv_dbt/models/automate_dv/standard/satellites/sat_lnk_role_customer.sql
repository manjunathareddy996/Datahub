{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_LNK_ROLE_CUSTOMER (HUB_PARTY grain) -- stitch-backed, 3 table(s) joined.
-- Source: stg2_lnk_role_customer.

{%- set yaml_metadata -%}
source_model: 'stg2_lnk_role_customer'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'ROLE_TYPE_CK'
src_payload:
  - 'VIP_INDICATOR'
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
