-- automate_dv.stage() for SAT_AUG_POLICY_GROUP_RELATION_ELIGIBILITY, read off central view stitch_v24_policy.
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
      - 'AGE_ELIGIBILITY_RESTRICTION'
      - 'ELIGIBLE_LIVES_COUNT'
      - 'MEMBER_RELATIONSHIP_CLASS'
      - 'OTHER_RELATIONSHIP_DESCRIPTION'
      - 'RELATIONSHIP_ELIGIBLE_INDICATOR'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_GROUP_RELATION_ELIGIBILITY__AGE_ELIGIBILITY_RESTRICTION, AUG_POLICY_GROUP_RELATION_ELIGIBILITY__ELIGIBLE_LIVES_COUNT, AUG_POLICY_GROUP_RELATION_ELIGIBILITY__MEMBER_RELATIONSHIP_CLASS, AUG_POLICY_GROUP_RELATION_ELIGIBILITY__OTHER_RELATIONSHIP_DESCRIPTION, AUG_POLICY_GROUP_RELATION_ELIGIBILITY__RELATIONSHIP_ELIGIBLE_INDICATOR) is not null then 'HUB_POLICY|' || POLICY_BK end"
  AGE_ELIGIBILITY_RESTRICTION: 'AUG_POLICY_GROUP_RELATION_ELIGIBILITY__AGE_ELIGIBILITY_RESTRICTION'
  ELIGIBLE_LIVES_COUNT: 'AUG_POLICY_GROUP_RELATION_ELIGIBILITY__ELIGIBLE_LIVES_COUNT'
  MEMBER_RELATIONSHIP_CLASS: 'AUG_POLICY_GROUP_RELATION_ELIGIBILITY__MEMBER_RELATIONSHIP_CLASS'
  OTHER_RELATIONSHIP_DESCRIPTION: 'AUG_POLICY_GROUP_RELATION_ELIGIBILITY__OTHER_RELATIONSHIP_DESCRIPTION'
  RELATIONSHIP_ELIGIBLE_INDICATOR: 'AUG_POLICY_GROUP_RELATION_ELIGIBILITY__RELATIONSHIP_ELIGIBLE_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v24_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
