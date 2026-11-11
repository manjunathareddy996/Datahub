-- automate_dv.stage() for SAT_AUG_POLICY_LIFECYCLE, read off central view stitch_v24_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v24_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REFERRAL_DATE'
      - 'REFERRED_BY_RULE_ENGINE_INDICATOR'
      - 'REFERRED_BY_USER_REFERENCE'
      - 'SUBMISSION_DEFICIENCY_REASON'
      - 'SUBMISSION_REJECTION_REASON'
      - 'UNDERWRITER_REFERRAL_REASON'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_LIFECYCLE__REFERRAL_DATE, AUG_POLICY_LIFECYCLE__REFERRED_BY_RULE_ENGINE_INDICATOR, AUG_POLICY_LIFECYCLE__REFERRED_BY_USER_REFERENCE, AUG_POLICY_LIFECYCLE__SUBMISSION_DEFICIENCY_REASON, AUG_POLICY_LIFECYCLE__SUBMISSION_REJECTION_REASON, AUG_POLICY_LIFECYCLE__UNDERWRITER_REFERRAL_REASON) is not null then 'HUB_POLICY|' || POLICY_BK end"
  REFERRAL_DATE: 'AUG_POLICY_LIFECYCLE__REFERRAL_DATE'
  REFERRED_BY_RULE_ENGINE_INDICATOR: 'AUG_POLICY_LIFECYCLE__REFERRED_BY_RULE_ENGINE_INDICATOR'
  REFERRED_BY_USER_REFERENCE: 'AUG_POLICY_LIFECYCLE__REFERRED_BY_USER_REFERENCE'
  SUBMISSION_DEFICIENCY_REASON: 'AUG_POLICY_LIFECYCLE__SUBMISSION_DEFICIENCY_REASON'
  SUBMISSION_REJECTION_REASON: 'AUG_POLICY_LIFECYCLE__SUBMISSION_REJECTION_REASON'
  UNDERWRITER_REFERRAL_REASON: 'AUG_POLICY_LIFECYCLE__UNDERWRITER_REFERRAL_REASON'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v24_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
