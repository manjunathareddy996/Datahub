{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for HUB_POLICY, branch 'BJAZ_T_CKYC_OTP'.
-- Business key verbatim from the map; identifiers localised to the staging aliases.
--
-- BD-04, bespoke layer eav_unpivot_guard: FIELD_TYPE is a SENTINEL, not a
-- payload column. The POLICY% guard is carried verbatim and a build-time
-- assertion refuses any HUB_POLICY key expression that evaluates a bare FIELD_VALUE.
-- STANDING CAVEAT, NOT DISCHARGED: the guard is correct in FORM and unverified in
-- MEANING -- FIELD_TYPE's value vocabulary is open with source and cannot be
-- checked from a schema dump. If the vocabulary differs, policies silently fail
-- to key.
--
-- KNOWN CONSEQUENCE, reported not hidden (BDEC-09): the guard returns NULL on
-- every row whose FIELD_TYPE is not POLICY%, so this feed offers a NULL business
-- key for those rows and AutomateDV will hash one bogus hub row per source. The
-- baseline does exactly this on its own 8 HUB_POLICY branches and the pack reports 29
-- null-keyed rows of this shape; matching a gate-PASS sibling's form was chosen
-- over inventing a filter layer the chain does not have.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_ckyc_otp'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: "case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end"
  PARENT_NK: "'HUB_POLICY|' || (case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_CKYC_OTP'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
