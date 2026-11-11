-- automate_dv.stage() for SAT_AUG_POLICY_HEADER, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OTHER_REMARKS'
      - 'POLICYHOLDER_NAME'
      - 'PREMIUM_PAYER_NAME'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_HEADER__OTHER_REMARKS, AUG_POLICY_HEADER__POLICYHOLDER_NAME, AUG_POLICY_HEADER__PREMIUM_PAYER_NAME) is not null then 'HUB_POLICY|' || POLICY_BK end"
  OTHER_REMARKS: 'AUG_POLICY_HEADER__OTHER_REMARKS'
  POLICYHOLDER_NAME: 'AUG_POLICY_HEADER__POLICYHOLDER_NAME'
  PREMIUM_PAYER_NAME: 'AUG_POLICY_HEADER__PREMIUM_PAYER_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
