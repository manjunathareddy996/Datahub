{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_LNK_POLICY_PARTY_ROLE,
-- table 'OCP_INTERESTED_PARTIES'.
-- GAP: "Party Role Type" (the satellite's actual role-type attribute -- policyholder/
-- insured/agent/nominee/etc.) is NOT mapped anywhere in Partner's source mapping. Only
-- "Role Sequence" (IP_NO) is. Built with Role Sequence as the sole childkey component --
-- not fabricating a role-type value. See mapper follow-up note.

{%- set yaml_metadata -%}
source_model: 'stg_partner__ocp_interested_parties'
hashed_columns:
  POLICY_PARTY_HKEY: 'POLICY_PARTY_HKEY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ROLE_SEQUENCE'
derived_columns:
  POLICY_PARTY_HKEY_NK: "'LNK_POLICY_PARTY|' || partner_id || '|' || contract_id"
  ROLE_SEQUENCE: 'ip_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!OCP_INTERESTED_PARTIES'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
