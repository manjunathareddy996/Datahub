-- automate_dv.stage() for SAT_AUG_POLICY_CERTIFICATE, read off central view stitch_v09_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_claim'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ANNUAL_EMPLOYER_CONTRIBUTION_AMOUNT'
      - 'ELIGIBLE_COVERAGE_DAYS'
      - 'FINAL_PAYABLE_AMOUNT'
      - 'PRO_RATA_EMPLOYER_CONTRIBUTION_AMOUNT'
      - 'PRO_RATA_MEMBER_PREMIUM'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_CERTIFICATE__ANNUAL_EMPLOYER_CONTRIBUTION_AMOUNT, AUG_POLICY_CERTIFICATE__ELIGIBLE_COVERAGE_DAYS, AUG_POLICY_CERTIFICATE__FINAL_PAYABLE_AMOUNT, AUG_POLICY_CERTIFICATE__PRO_RATA_EMPLOYER_CONTRIBUTION_AMOUNT, AUG_POLICY_CERTIFICATE__PRO_RATA_MEMBER_PREMIUM) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ANNUAL_EMPLOYER_CONTRIBUTION_AMOUNT: 'AUG_POLICY_CERTIFICATE__ANNUAL_EMPLOYER_CONTRIBUTION_AMOUNT'
  ELIGIBLE_COVERAGE_DAYS: 'AUG_POLICY_CERTIFICATE__ELIGIBLE_COVERAGE_DAYS'
  FINAL_PAYABLE_AMOUNT: 'AUG_POLICY_CERTIFICATE__FINAL_PAYABLE_AMOUNT'
  PRO_RATA_EMPLOYER_CONTRIBUTION_AMOUNT: 'AUG_POLICY_CERTIFICATE__PRO_RATA_EMPLOYER_CONTRIBUTION_AMOUNT'
  PRO_RATA_MEMBER_PREMIUM: 'AUG_POLICY_CERTIFICATE__PRO_RATA_MEMBER_PREMIUM'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
