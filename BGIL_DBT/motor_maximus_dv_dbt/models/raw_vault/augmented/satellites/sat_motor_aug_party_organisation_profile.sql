-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_PARTY_ORGANISATION_PROFILE (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v10_party.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_ORGANISATION_PROFILE | SEZ Registration Date | None: emits SEZ_REGISTRATION_DATE; withheld SEPZ_REGISTRATION_DATE
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_PARTY_ORGANISATION_PROFILE | SEZ Registration Number | None: emits SEZ_REGISTRATION_NO; withheld SEPZ_REGISTRATION_NO
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__party_organisation_profile'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'BUSINESS_REGISTRATION_DATE'
  - 'BUSINESS_SECTOR'
  - 'CONTRACTOR_FIRM_ESTABLISHMENT_YEAR'
  - 'CONTRACTOR_ORIGIN_COUNTRY'
  - 'CONTRACTOR_PROJECT_EXPERTISE_DESCRIPTION'
  - 'DIRECTOR_AND_PARTNER_DETAIL_TEXT'
  - 'INFRASTRUCTURE_SUB_SECTOR'
  - 'OPERATING_AREA_COVERAGE_KILOMETRES'
  - 'OWNERSHIP_TYPE'
  - 'PLACE_OF_OPERATION'
  - 'REGISTERED_BUSINESS_TRUST_INDICATOR'
  - 'REGISTERED_CHARGE_DETAIL_TEXT'
  - 'REGISTERED_COMPANY_INDICATOR'
  - 'SEZ_REGISTRATION_DATE'
  - 'SEZ_REGISTRATION_EXPIRY_DATE'
  - 'SEZ_REGISTRATION_NUMBER'
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
