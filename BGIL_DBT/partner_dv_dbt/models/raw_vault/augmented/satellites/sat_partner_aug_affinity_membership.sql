{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE']
    )
}}

-- PARTNER AUGMENTED (unconfirmed) sat() for SAT_AUG_AFFINITY_MEMBERSHIP (HUB_PARTY grain) -- single source.
-- Mapper-approved LOB-local new satellite (P1) -- NOT in data_5a.js. 2 attrs
-- (AA Membership Number, AA Membership Expiry Date).
-- Promote to canonical only if this recurs in another LOB.

{%- set yaml_metadata -%}
source_model: 'stg2_aug_azbj_partner_extn__party_affinity'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AA_MEMBERSHIP_NUMBER'
  - 'AA_MEMBERSHIP_EXPIRY_DATE'
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
