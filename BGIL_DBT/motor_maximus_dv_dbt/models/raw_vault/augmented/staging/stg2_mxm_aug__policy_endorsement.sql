-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_ENDORSEMENT, read off central view stitch_mxm__v13_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v13_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ENDORSEMENT_APPROVED_DATE'
      - 'ENDORSEMENT_REMARKS'
      - 'REVISED_SUM_INSURED_AMOUNT'
      - 'ENDORSEMENT_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_ENDORSEMENT__ENDORSEMENT_APPROVED_DATE, AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS, AUG_POLICY_ENDORSEMENT__REVISED_SUM_INSURED_AMOUNT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ENDORSEMENT_NUMBER_CK: 'AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK'
  ENDORSEMENT_APPROVED_DATE: 'AUG_POLICY_ENDORSEMENT__ENDORSEMENT_APPROVED_DATE'
  ENDORSEMENT_REMARKS: 'AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS'
  REVISED_SUM_INSURED_AMOUNT: 'AUG_POLICY_ENDORSEMENT__REVISED_SUM_INSURED_AMOUNT'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v13_policy'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
