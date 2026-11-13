{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_LNK_ROLE_CUSTOMER (HUB_PARTY grain, role-special: 'customer').
-- Change detection and watermark are per (PARTY_HKEY, RECORD_SOURCE), so other projects' rows
-- are never touched.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_rolesat_clm_interested_parties__lnk_role_customer'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'CUSTOMER_CATEGORY'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_rolesat_clm_interested_parties__lnk_role_customer: 'OPUS_PARTNER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_rolesat_clm_interested_parties__lnk_role_customer': ['CUSTOMER_CATEGORY']
                    }) }}
