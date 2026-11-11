-- automate_dv.stage() for SAT_AUG_DOCUMENT_DEFINITION, read off central view stitch_v01_agreement.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v01_agreement'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_REMARKS'
      - 'ORIGINATING_FAX_NUMBER'
      - 'PROOF_OF_DELIVERY_NUMBER'
      - 'RECEIVED_TIME'
derived_columns:
  DOCUMENT_NK: "case when coalesce(AUG_DOCUMENT_DEFINITION__DOCUMENT_REMARKS, AUG_DOCUMENT_DEFINITION__ORIGINATING_FAX_NUMBER, AUG_DOCUMENT_DEFINITION__PROOF_OF_DELIVERY_NUMBER, AUG_DOCUMENT_DEFINITION__RECEIVED_TIME) is not null then 'HUB_DOCUMENT|' || DOCUMENT_BK end"
  DOCUMENT_REMARKS: 'AUG_DOCUMENT_DEFINITION__DOCUMENT_REMARKS'
  ORIGINATING_FAX_NUMBER: 'AUG_DOCUMENT_DEFINITION__ORIGINATING_FAX_NUMBER'
  PROOF_OF_DELIVERY_NUMBER: 'AUG_DOCUMENT_DEFINITION__PROOF_OF_DELIVERY_NUMBER'
  RECEIVED_TIME: 'AUG_DOCUMENT_DEFINITION__RECEIVED_TIME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v01_agreement'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
