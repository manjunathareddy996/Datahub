-- Standard sat() for SAT_PARTY_IDENTITY (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v10_party.
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW | SAT_PARTY_IDENTITY | Party Full Name | claimant: emits INSURED_NAME; withheld MEMBER_NAME
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__party_identity'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AGE'
  - 'COUNTRY_OF_BIRTH'
  - 'COUNTRY_OF_RESIDENCE'
  - 'DATE_OF_BIRTH'
  - 'FIRST_NAME'
  - 'GENDER_CODE'
  - 'LAST_NAME'
  - 'MIDDLE_NAME'
  - 'NATIONALITY'
  - 'PARTY_DISPLAY_NAME'
  - 'PARTY_FULL_NAME'
  - 'PARTY_LEGAL_NAME'
  - 'PARTY_ORIGINATION_DATE'
  - 'PARTY_STATUS'
  - 'PARTY_TYPE_CODE'
  - 'SALUTATION'
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
