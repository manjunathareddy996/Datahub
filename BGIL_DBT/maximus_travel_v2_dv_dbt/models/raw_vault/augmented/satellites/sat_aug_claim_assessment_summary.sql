{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_AUG_CLAIM_ASSESSMENT_SUMMARY.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mtv2_aug_sat_aug_claim_assessment_summary'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ADVISORY_COMMITTEE_REFERRAL_INDICATOR'
  - 'AT_FAULT_PARTY_DESCRIPTION'
  - 'LIVE_VIDEO_SURVEY_INDICATOR'
  - 'NON_MEDICAL_ADMISSIBILITY_COMMENTS'
  - 'NON_MEDICAL_ADMISSIBILITY_INDICATOR'
  - 'SAVINGS_AMOUNT'
  - 'SCRUTINY_STATUS'
  - 'SECTION_64VB_PREMIUM_REALISATION_STATUS'
  - 'SPOT_SURVEY_INDICATOR'
  - 'SURVEY_REQUIRED_INDICATOR'
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
