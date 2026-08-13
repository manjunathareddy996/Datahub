{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL ma_sat() for SAT_LNK_CLAIM_PARTY_ROLE, per data_5b (new satellite --
-- see docs/PARTNER_BUILD_STATE.md section 1). Parent LNK_CLAIM_PARTY, canonical childkey
-- "Party Role Type + Role Sequence". This is the claim-side conformed twin of
-- SAT_LNK_POLICY_PARTY_ROLE -- same child-key shape.
-- Only Party Role Type + Role Sequence have real Partner source data (both from
-- CLM_INTERESTED_PARTIES: IP_TYPE, IP_NO). Every other canonical attribute (Role Category,
-- Attribution Percentage, Role Effective/End Date, Primary Indicator, Role Status) is
-- genuinely unmapped -- left unbuilt, not fabricated (same convention as
-- SAT_LNK_POLICY_PARTY_ROLE).

{%- set yaml_metadata -%}
source_model: 'stg2_clmparty_clm_interested_parties'
src_pk: 'CLAIM_PARTY_HKEY'
src_cdk:
  - 'PARTY_ROLE_TYPE'
  - 'ROLE_SEQUENCE'
src_payload:
  - 'PARTY_ROLE_TYPE'
  - 'ROLE_SEQUENCE'
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
