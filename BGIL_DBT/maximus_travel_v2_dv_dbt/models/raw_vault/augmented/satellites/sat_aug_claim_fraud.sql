{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_AUG_CLAIM_FRAUD.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mtv2_aug_sat_aug_claim_fraud'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ANALYTICS_ALERT_DATE'
  - 'ANALYTICS_TRIGGER_DISPOSITION_DESCRIPTION'
  - 'ANALYTICS_TRIGGER_FEEDBACK'
  - 'FRAUD_APPROVER_REFERENCE'
  - 'FRAUD_APPROVER_REMARKS'
  - 'FRAUD_CLASSIFICATION'
  - 'FRAUD_REFERRAL_RAISED_BY_REFERENCE'
  - 'FRAUD_SEVERITY'
  - 'FRAUD_SEVERITY_GRADE'
  - 'LIFECYCLE_MANAGEMENT_TRIGGER_SELECTED'
  - 'MATERIAL_NON_DISCLOSURE_INDICATOR'
  - 'NON_DISCLOSURE_INDICATOR'
  - 'RISK_ACCEPTANCE_PRIORITY'
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
