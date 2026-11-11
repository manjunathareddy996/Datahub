-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CLAIM_TPA_INTERACTION (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v10_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_tpa_interaction'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CASHLESS_REQUEST_STATUS'
  - 'DECISION_NOTIFICATION_SENT_DATE'
  - 'DECISION_NOTIFICATION_SENT_INDICATOR'
  - 'DENIAL_DATE'
  - 'PRE_AUTHORISATION_OPTION_CODE'
  - 'PRE_AUTHORISATION_PROCESS_TYPE'
  - 'PRE_AUTHORISATION_REQUEST_VALID_INDICATOR'
  - 'PROVIDER_PRE_AUTHORISATION_REQUEST_REFERENCE'
  - 'REQUEST_DECLARATION_ACCEPTED_INDICATOR'
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
