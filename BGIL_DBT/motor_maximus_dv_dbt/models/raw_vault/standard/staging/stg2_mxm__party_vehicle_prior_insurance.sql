-- automate_dv.stage() for SAT_PARTY_VEHICLE_PRIOR_INSURANCE, read off central view stitch_mxm__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREVIOUS_CLAIM_INDICATOR'
      - 'PREVIOUS_EXPIRY_DATE'
      - 'PREVIOUS_INSURER_ADDRESS'
      - 'PREVIOUS_POLICY_NUMBER'
      - 'PREVIOUS_SUM_INSURED'
      - 'LINE_OF_BUSINESS_CK'
      - 'PREVIOUS_POLICY_NUMBER_CK'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_CLAIM_INDICATOR, PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_EXPIRY_DATE, PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_INSURER_ADDRESS, PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_POLICY_NUMBER, PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_SUM_INSURED) is not null then 'HUB_PARTY|' || PARTY_BK end"
  LINE_OF_BUSINESS_CK: 'PARTY_VEHICLE_PRIOR_INSURANCE__LINE_OF_BUSINESS_CK'
  PREVIOUS_POLICY_NUMBER_CK: 'PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_POLICY_NUMBER_CK'
  PREVIOUS_CLAIM_INDICATOR: 'PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_CLAIM_INDICATOR'
  PREVIOUS_EXPIRY_DATE: 'PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_EXPIRY_DATE'
  PREVIOUS_INSURER_ADDRESS: 'PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_INSURER_ADDRESS'
  PREVIOUS_POLICY_NUMBER: 'PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_POLICY_NUMBER'
  PREVIOUS_SUM_INSURED: 'PARTY_VEHICLE_PRIOR_INSURANCE__PREVIOUS_SUM_INSURED'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
