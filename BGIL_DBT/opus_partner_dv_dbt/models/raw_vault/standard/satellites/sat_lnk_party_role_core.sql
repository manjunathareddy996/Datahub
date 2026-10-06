{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC STANDARD-MODEL ma_sat() for SAT_LNK_PARTY_ROLE_CORE (HUB_PARTY grain) -- union of 1 branch(es).
-- data_7: hist 'Multi-Active SCD2', childkey 'Role Code + Role Sequence', anchor parent 'HUB_PARTY'.
-- Payload rendered GLUED (DEC-01, anchor kind HUB read from data_7's parent field).
--
-- Multi-active: src_cdk ['ROLECODE', 'ROLESEQUENCE'] carries the model's declared child-key leg(s). The
-- child-key VALUE is a literal derived from COLUMN IDENTITY, not from data
-- ordering, so it cannot renumber between reloads (BUILD_RULES.md 5.1).
--
-- opus_partner_dv_dbt: written in this project's pattern -- incremental append, automate_dv.ma_sat.

{%- set yaml_metadata -%}
source_model: 'stg2_sat_bjaz_t_ckyc_rel_persion_dtls__lnk_party_role_core__related_person'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'ROLECODE'
  - 'ROLESEQUENCE'
src_payload:
  - 'ROLESTATUS'
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
