-- automate_dv.stage() for SAT_AUG_POLICY_RENEWAL, read off central view stitch_v26_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v26_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FIRST_POLICY_REFERENCE'
      - 'FIRST_POLICY_REFERENCE_IN_CONTINUITY_CHAIN'
      - 'PRECEDING_POLICY_EXPIRY_DATE'
      - 'PREVIOUS_YEAR_SUM_INSURED_AMOUNT'
      - 'RENEWAL_BUSINESS_INDICATOR'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_RENEWAL__FIRST_POLICY_REFERENCE, AUG_POLICY_RENEWAL__FIRST_POLICY_REFERENCE_IN_CONTINUITY_CHAIN, AUG_POLICY_RENEWAL__PRECEDING_POLICY_EXPIRY_DATE, AUG_POLICY_RENEWAL__PREVIOUS_YEAR_SUM_INSURED_AMOUNT, AUG_POLICY_RENEWAL__RENEWAL_BUSINESS_INDICATOR) is not null then 'HUB_POLICY|' || POLICY_BK end"
  FIRST_POLICY_REFERENCE: 'AUG_POLICY_RENEWAL__FIRST_POLICY_REFERENCE'
  FIRST_POLICY_REFERENCE_IN_CONTINUITY_CHAIN: 'AUG_POLICY_RENEWAL__FIRST_POLICY_REFERENCE_IN_CONTINUITY_CHAIN'
  PRECEDING_POLICY_EXPIRY_DATE: 'AUG_POLICY_RENEWAL__PRECEDING_POLICY_EXPIRY_DATE'
  PREVIOUS_YEAR_SUM_INSURED_AMOUNT: 'AUG_POLICY_RENEWAL__PREVIOUS_YEAR_SUM_INSURED_AMOUNT'
  RENEWAL_BUSINESS_INDICATOR: 'AUG_POLICY_RENEWAL__RENEWAL_BUSINESS_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v26_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
