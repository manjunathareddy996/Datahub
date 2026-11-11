-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_PARTY_CONTACT_ADDRESS_LINK (parent LNK_PARTY_LOCATION, history SCD2), fed whole from central view stitch_v10_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_party_contact_address_link'
src_pk: 'PARTY_LOCATION_HKEY'
src_cdk:
  - 'ADDRESS_USAGE_TYPE_CK'
src_payload:
  - 'SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR'
  - 'SAME_AS_POLICYHOLDER_ADDRESS_INDICATOR'
  - 'SAME_AS_PRIMARY_ADDRESS_INDICATOR'
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
