-- Standard sat() for SAT_PARTY_ORGANISATION_PROFILE (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v10_party.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_PARTY_ORGANISATION_PROFILE | Annual Turnover | None: emits ANNUAL_TURNOVER; withheld ANNUAL_TURNOVER_OF_THE_COMPANY
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__party_organisation_profile'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ANNUAL_TURNOVER'
  - 'BUSINESS_REGISTRATION_NUMBER'
  - 'CIN_NUMBER'
  - 'DATE_OF_INCORPORATION'
  - 'GROUP_NAME'
  - 'INDUSTRY_CODE'
  - 'LEGAL_CONSTITUTION_CODE'
  - 'LEGAL_CONSTITUTION_TYPE'
  - 'MSME_CATEGORY'
  - 'MSME_INDICATOR'
  - 'NATURE_OF_BUSINESS'
  - 'PAID_UP_CAPITAL'
  - 'PARENT_ENTITY_NAME'
  - 'REGISTERED_OFFICE_COUNTRY'
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
