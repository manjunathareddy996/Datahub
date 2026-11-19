-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_VEHICLE_PRIOR_INSURANCE, read off central view stitch_mxm__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREVIOUS_CLAIM_AMOUNT'
      - 'PREVIOUS_POLICY_PREMIUM'
      - 'PREVIOUS_POLICY_START_DATE'
      - 'PREVIOUS_PRODUCT_NAME'
      - 'PREVIOUS_PRODUCT_REFERENCE'
      - 'LINE_OF_BUSINESS_CK'
      - 'PREVIOUS_POLICY_NUMBER_CK'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_CLAIM_AMOUNT, AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_POLICY_PREMIUM, AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_POLICY_START_DATE, AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_PRODUCT_NAME, AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_PRODUCT_REFERENCE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  LINE_OF_BUSINESS_CK: 'AUG_PARTY_VEHICLE_PRIOR_INSURANCE__LINE_OF_BUSINESS_CK'
  PREVIOUS_POLICY_NUMBER_CK: 'AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_POLICY_NUMBER_CK'
  PREVIOUS_CLAIM_AMOUNT: 'AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_CLAIM_AMOUNT'
  PREVIOUS_POLICY_PREMIUM: 'AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_POLICY_PREMIUM'
  PREVIOUS_POLICY_START_DATE: 'AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_POLICY_START_DATE'
  PREVIOUS_PRODUCT_NAME: 'AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_PRODUCT_NAME'
  PREVIOUS_PRODUCT_REFERENCE: 'AUG_PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_PRODUCT_REFERENCE'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
