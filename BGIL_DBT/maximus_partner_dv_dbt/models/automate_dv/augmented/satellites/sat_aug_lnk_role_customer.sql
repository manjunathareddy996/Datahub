{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) sat() for SAT_AUG_LNK_ROLE_CUSTOMER, at HUB_PARTY grain.
-- Writes the SAME physical table as partner_dv_dbt's sat_aug_lnk_role_customer.
-- Payload columns are the mapper's PROPOSED ATTRIBUTE names in partner_dv_dbt's own rendering
-- (squashed), not raw Maximus column names -- a shared table must not gain a second column for a
-- fact that already has one. NOT part of the canonical model.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_mp__pd_prop_sp_pv__party'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'INSUREDTYPE'
  - 'MEMBERTYPE'
  - 'PREMIUMPAYERTYPE'
src_hashdiff: 'HASHDIFF_AUG_LNK_ROLE_CUSTOMER'
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
