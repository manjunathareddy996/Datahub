-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_EXTENDED_WARRANTY, read off central view stitch_motor__v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v16_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHILD_PRODUCT_CODE'
      - 'WARRANTY_SUB_TYPE'
      - 'WARRANTY_TYPE'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_EXTENDED_WARRANTY__CHILD_PRODUCT_CODE, AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_SUB_TYPE, AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_TYPE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CHILD_PRODUCT_CODE: 'AUG_POLICY_EXTENDED_WARRANTY__CHILD_PRODUCT_CODE'
  WARRANTY_SUB_TYPE: 'AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_SUB_TYPE'
  WARRANTY_TYPE: 'AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_TYPE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v16_policy'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
