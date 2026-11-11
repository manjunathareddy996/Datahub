-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_GROUP (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v33_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_group'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'CKYC_CAPTURE_REQUIRED_INDICATOR'
  - 'CORONA_COVER_VARIANT_ENABLED_INDICATOR'
  - 'DEPENDENT_MEMBER_COUNT'
  - 'ELIGIBLE_RELATIONSHIP_SET'
  - 'EMPLOYER_CONTRIBUTION_AMOUNT'
  - 'EXPIRING_MEMBER_COUNT'
  - 'FAMILY_DEFINITION_DESCRIPTION'
  - 'FAMILY_FLOATER_DETAILS_CAPTURED_INDICATOR'
  - 'FAMILY_INCLUSION_DEFINITION'
  - 'FINAL_MEMBER_COUNT_AT_EXPIRY'
  - 'GROUP_CONTRACT_PORTAL_LOGIN_IDENTIFIER'
  - 'GROUP_COVER_DAY_COUNT_MULTIPLIER'
  - 'GROUP_COVER_DAY_COUNT_YEARS_MULTIPLIER'
  - 'GROUP_NUMBER'
  - 'GROUP_SCHEME_CODE'
  - 'HEALTH_ASSESSMENT_TOOL_REFERRAL_INDICATOR'
  - 'ISSUANCE_WITH_MEMBER_DATA_INDICATOR'
  - 'MASTER_CONTRACT_CONFIGURATION_ACTIVE_INDICATOR'
  - 'MAXIMUM_MEMBERS_PER_FAMILY'
  - 'MEMBERS_ADDED_IN_YEAR'
  - 'MEMBERS_DELETED_IN_YEAR'
  - 'MEMBER_AGE_BAND'
  - 'MEMBER_BMI_CALCULATION_INDICATOR'
  - 'MEMBER_BULK_LOADER_ENABLED_INDICATOR'
  - 'MEMBER_BULK_LOADER_FORMAT'
  - 'MEMBER_DOB_RATING_AGE_VALIDATION_INDICATOR'
  - 'MEMBER_LEVEL_DATA_CAPTURED_INDICATOR'
  - 'MOBILE_CAPTURE_BYPASS_ALLOWED_INDICATOR'
  - 'PARENTAL_SUM_INSURED_RESTRICTION'
  - 'PRIMARY_MEMBER_COUNT'
  - 'REMAPPED_MASTER_POLICY_REFERENCE'
  - 'SUM_INSURED_RATING_FACTOR_INDICATOR'
  - 'UNDERWRITING_REMARKS_CAPTURED_INDICATOR'
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
