-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_TERMS, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FRANCHISE_AMOUNT'
      - 'GEOGRAPHICAL_EXTENSION_CODE'
      - 'NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR'
      - 'OWN_DAMAGE_EXTENSION_DAYS'
      - 'PRESENT_QUOTA_LIMIT'
      - 'THIRD_PARTY_EXTENSION_DAYS'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_TERMS__FRANCHISE_AMOUNT, AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE, AUG_POLICY_TERMS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR, AUG_POLICY_TERMS__OWN_DAMAGE_EXTENSION_DAYS, AUG_POLICY_TERMS__PRESENT_QUOTA_LIMIT, AUG_POLICY_TERMS__THIRD_PARTY_EXTENSION_DAYS) is not null then 'HUB_POLICY|' || POLICY_BK end"
  FRANCHISE_AMOUNT: 'AUG_POLICY_TERMS__FRANCHISE_AMOUNT'
  GEOGRAPHICAL_EXTENSION_CODE: 'AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE'
  NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR: 'AUG_POLICY_TERMS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR'
  OWN_DAMAGE_EXTENSION_DAYS: 'AUG_POLICY_TERMS__OWN_DAMAGE_EXTENSION_DAYS'
  PRESENT_QUOTA_LIMIT: 'AUG_POLICY_TERMS__PRESENT_QUOTA_LIMIT'
  THIRD_PARTY_EXTENSION_DAYS: 'AUG_POLICY_TERMS__THIRD_PARTY_EXTENSION_DAYS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v12_policy'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
