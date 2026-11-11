-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_TERMS (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v28_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_terms'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'ATTACHED_CLAUSES_DESCRIPTION'
  - 'BACKDATED_ISSUANCE_ALLOWED_INDICATOR'
  - 'CLAIMS_REVIEW_EXPERIENCE_REFUND_CLAUSE_TERMS'
  - 'CONCURRENT_INSURANCE_DETAILS'
  - 'CONTINUITY_GUIDELINE'
  - 'CRC_CLAUSE_TEXT'
  - 'CRC_PERCENTAGE'
  - 'ENDORSEMENT_ENROLMENT_WINDOW_DAYS'
  - 'EXPIRED_POLICY_CANCELLATION_ALLOWED_INDICATOR'
  - 'GENERIC_CANCELLATION_ALLOWED_INDICATOR'
  - 'INCEPTION_ENROLMENT_WINDOW_DAYS'
  - 'INITIAL_WAITING_PERIOD_ONE_YEAR'
  - 'INITIAL_WAITING_PERIOD_THIRTY_DAY'
  - 'INSTALMENT_IDENTIFIER_ALLOWED_INDICATOR'
  - 'LOCK_IN_PERIOD'
  - 'LONG_TERM_TERM_ALLOWED_INDICATOR'
  - 'MAXIMUM_ADVANCE_ISSUANCE_DAYS'
  - 'MAXIMUM_BACKDATED_ISSUANCE_DAYS'
  - 'MEMBER_ADDITION_GUIDELINE'
  - 'MEMBER_DELETION_GUIDELINE'
  - 'OTHER_CONDITIONS'
  - 'PERMITTED_POLICY_PERIOD_DAYS'
  - 'PERMITTED_POLICY_PERIOD_MONTHS'
  - 'PERMITTED_POLICY_PERIOD_YEARS'
  - 'POLICY_EXCLUSIONS_DESCRIPTION'
  - 'PRE_EXISTING_DISEASE_COVER_BASIS'
  - 'SHORT_PERIOD_TERM_ALLOWED_INDICATOR'
  - 'SPECIAL_PERILS_COVERED_DESCRIPTION'
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
