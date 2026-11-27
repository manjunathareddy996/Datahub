{{ config(materialized='view') }}
-- PARTNER STANDARD-MODEL per-table stage() for HUB_CLAIM branch 'CLM_BASES'.
-- Replaces the CLM_INTERESTED_PARTIES branch as the HUB_CLAIM feeder.
-- Same key form as before ('HUB_CLAIM|' || claim_id) so CLAIM_HKEY matches the links.
{%- set yaml_metadata -%}
source_model: 'stg_partner__clm_bases'
hashed_columns:
  CLAIM_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'claim_id'
  PARENT_NK: "'HUB_CLAIM|' || (claim_id)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_PARTNER_CLM_BASES'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
