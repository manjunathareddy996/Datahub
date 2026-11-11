-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_GROUP_RELATION_ELIGIBILITY (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v24_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_group_relation_eligibility'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'AGE_ELIGIBILITY_RESTRICTION'
  - 'ELIGIBLE_LIVES_COUNT'
  - 'MEMBER_RELATIONSHIP_CLASS'
  - 'OTHER_RELATIONSHIP_DESCRIPTION'
  - 'RELATIONSHIP_ELIGIBLE_INDICATOR'
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
