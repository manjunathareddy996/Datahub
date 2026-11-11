-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_TRANSPORT_LEG (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v05_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_transport_leg'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'COVER_SECTION_CODE_CK'
  - 'TRANSPORT_MODE_CODE_CK'
src_payload:
  - 'AMBULANCE_TYPE'
  - 'JOURNEY_DATE'
  - 'JOURNEY_DESTINATION_CITY'
  - 'JOURNEY_ORIGIN_CITY'
  - 'TRANSPORT_ARRIVAL'
  - 'TRANSPORT_DEPARTURE'
  - 'TRANSPORT_PROVIDER_ADDRESS_TEXT'
  - 'TRANSPORT_PROVIDER_CONTACT_NUMBER'
  - 'TRANSPORT_PROVIDER_NAME'
  - 'TRANSPORT_PROVIDER_STD_CODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
