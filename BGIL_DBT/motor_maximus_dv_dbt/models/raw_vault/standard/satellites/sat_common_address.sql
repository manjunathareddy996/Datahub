-- Standard sat() for SAT_COMMON_ADDRESS (parent HUB_LOCATION, history SCD2), fed whole from central view stitch_mxm__v08_location.
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW | SAT_COMMON_ADDRESS | State Name | claim-address: emits STATE; withheld STATECLAIM
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW | SAT_COMMON_ADDRESS | State Name | workshop: emits WORKSHOP_STATE; withheld STATE_WORKSHOP
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_COMMON_ADDRESS | Country Name | correspondence-local: emits CORRESPONDENCE_LOCAL_ADDRESS_COUNTRY; withheld COUNTRY
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__common_address'
src_pk: 'LOCATION_HKEY'
src_payload:
  - 'ADDRESS_LINE_1'
  - 'ADDRESS_LINE_2'
  - 'ADDRESS_LINE_3'
  - 'ADDRESS_SOURCE_INDICATOR'
  - 'ADDRESS_TYPE_CODE'
  - 'CARE_OF_NAME'
  - 'CITY'
  - 'COUNTRY_CODE'
  - 'COUNTRY_NAME'
  - 'DISTRICT'
  - 'LANDMARK'
  - 'LOCALITY'
  - 'POSTAL_CODE'
  - 'POST_OFFICE_NAME'
  - 'STATE_CODE'
  - 'STATE_NAME'
  - 'STREET_NAME'
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
