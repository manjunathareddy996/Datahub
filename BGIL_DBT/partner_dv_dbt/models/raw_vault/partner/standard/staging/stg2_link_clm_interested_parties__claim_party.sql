{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() -- table 'CLM_INTERESTED_PARTIES', for the new
-- LNK_CLAIM_PARTY link (data_5b -- see docs/PARTNER_BUILD_STATE.md section 1).
-- Party end uses PART_ID (per mapper instruction), NOT 'claimant' -- CLM_INTERESTED_PARTIES
-- carries both as separate HUB_PARTY keys: CLAIMANT is the row's claimant-role party (already
-- used by stg2_rolesat_clm_interested_parties__lnk_role_customer.sql), PART_ID is the general
-- interested-party reference this row's IP_TYPE role actually describes (claimant, insured,
-- surveyor, financier, etc.) -- deliberately a different anchor, not a duplicate formula.

{%- set yaml_metadata -%}
source_model: 'stg_partner__clm_interested_parties'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  CLAIM_HKEY: 'CLAIM_HKEY_NK'
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || part_id"
  CLAIM_HKEY_NK: "'HUB_CLAIM|' || claim_id"
  CLAIM_PARTY_HKEY_NK: "'LNK_CLAIM_PARTY|' || part_id || '|' || claim_id"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!CLM_INTERESTED_PARTIES'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
