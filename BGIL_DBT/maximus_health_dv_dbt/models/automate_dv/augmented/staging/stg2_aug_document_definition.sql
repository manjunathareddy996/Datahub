-- automate_dv.stage() for SAT_AUG_DOCUMENT_DEFINITION, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COURIER_PROOF_OF_DELIVERY_NUMBER'
      - 'SECONDARY_DOCUMENT_TYPE'
      - 'SENDER_DESPATCH_REFERENCE_NUMBER'
derived_columns:
  DOCUMENT_NK: "case when coalesce(AUG_DOCUMENT_DEFINITION__COURIER_PROOF_OF_DELIVERY_NUMBER, AUG_DOCUMENT_DEFINITION__SECONDARY_DOCUMENT_TYPE, AUG_DOCUMENT_DEFINITION__SENDER_DESPATCH_REFERENCE_NUMBER) is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  COURIER_PROOF_OF_DELIVERY_NUMBER: 'AUG_DOCUMENT_DEFINITION__COURIER_PROOF_OF_DELIVERY_NUMBER'
  SECONDARY_DOCUMENT_TYPE: 'AUG_DOCUMENT_DEFINITION__SECONDARY_DOCUMENT_TYPE'
  SENDER_DESPATCH_REFERENCE_NUMBER: 'AUG_DOCUMENT_DEFINITION__SENDER_DESPATCH_REFERENCE_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
