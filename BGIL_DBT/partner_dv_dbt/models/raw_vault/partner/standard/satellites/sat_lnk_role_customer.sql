{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF']
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_LNK_ROLE_CUSTOMER (HUB_PARTY grain, role-special: 'customer').

{%- set yaml_metadata -%}
source_model: 'stg2_rolesat_clm_interested_parties__lnk_role_customer'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'CUSTOMER_CATEGORY'
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
