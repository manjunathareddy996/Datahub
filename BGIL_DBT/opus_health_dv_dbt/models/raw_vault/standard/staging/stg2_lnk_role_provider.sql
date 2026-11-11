-- automate_dv.stage() for SAT_LNK_ROLE_PROVIDER, read off central view stitch_v01_agreement.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v01_agreement'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMPANELMENT_DATE'
      - 'EMPANELMENT_STATUS'
      - 'NURSE_TO_PATIENT_RATIO'
      - 'PREFERRED_PROVIDER_INDICATOR'
      - 'PROVIDER_CODE'
      - 'PROVIDER_TYPE'
      - 'SUSPENSION_INDICATOR'
      - 'ROLE_TYPE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(LNK_ROLE_PROVIDER__EMPANELMENT_DATE, LNK_ROLE_PROVIDER__EMPANELMENT_STATUS, LNK_ROLE_PROVIDER__NURSE_TO_PATIENT_RATIO, LNK_ROLE_PROVIDER__PREFERRED_PROVIDER_INDICATOR, LNK_ROLE_PROVIDER__PROVIDER_CODE, LNK_ROLE_PROVIDER__PROVIDER_TYPE, LNK_ROLE_PROVIDER__SUSPENSION_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_TYPE_CK: 'LNK_ROLE_PROVIDER__ROLE_TYPE_CK'
  EMPANELMENT_DATE: 'LNK_ROLE_PROVIDER__EMPANELMENT_DATE'
  EMPANELMENT_STATUS: 'LNK_ROLE_PROVIDER__EMPANELMENT_STATUS'
  NURSE_TO_PATIENT_RATIO: 'LNK_ROLE_PROVIDER__NURSE_TO_PATIENT_RATIO'
  PREFERRED_PROVIDER_INDICATOR: 'LNK_ROLE_PROVIDER__PREFERRED_PROVIDER_INDICATOR'
  PROVIDER_CODE: 'LNK_ROLE_PROVIDER__PROVIDER_CODE'
  PROVIDER_TYPE: 'LNK_ROLE_PROVIDER__PROVIDER_TYPE'
  SUSPENSION_INDICATOR: 'LNK_ROLE_PROVIDER__SUSPENSION_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v01_agreement'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
