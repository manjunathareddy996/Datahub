{{ config(materialized='incremental') }}

-- TRAVEL AUGMENTED (build-side, no modeler round-trip -- see
-- docs/TRAVEL_FIXES_APPLIED.md) sat() for SAT_AUG_LNK_ROLE_CUSTOMER.
-- SAT_LNK_ROLE_CUSTOMER itself IS canonical (parent LNK_PARTY_ROLE) -- this augmented
-- companion carries only the one build-side attribute the mapper hasn't confirmed yet.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_lnk_role_customer_ba_trv_data_policy_dtls_mv_propastraveller'
  - 'stg2_aug_lnk_role_customer_bjaz_trv_loader_data_mv_propastraveller'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'PROPOSER_IS_TRAVELLER_INDICATOR'
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
