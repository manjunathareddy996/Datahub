-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_DELIVERY (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v26_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_delivery'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'DELIVERY_RECIPIENT_NAME'
  - 'HEALTH_CARD_DISPATCH_ADDRESS_TEXT'
  - 'HEALTH_CARD_DISPATCH_CONTACT_NUMBER'
  - 'HEALTH_CARD_DISPATCH_CONTACT_PERSON'
  - 'HEALTH_CARD_DISPATCH_RECIPIENT_TYPE'
  - 'HEALTH_CARD_OPTION'
  - 'POLICY_DISPATCH_ADDRESS_TEXT'
  - 'POLICY_DISPATCH_CONTACT_NUMBER'
  - 'POLICY_DISPATCH_CONTACT_PERSON'
  - 'POLICY_DISPATCH_RECIPIENT_TYPE'
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
