-- automate_dv.stage() for SAT_CLAIM_BILL_DIGITISATION, read off central view stitch_v06_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BILL_REFERENCE'
      - 'INVOICE_STATUS'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_BILL_DIGITISATION__BILL_REFERENCE, CLAIM_BILL_DIGITISATION__INVOICE_STATUS) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'CLAIM_BILL_DIGITISATION__ACTIVE_SEQUENCE_NUMBER_CK'
  BILL_REFERENCE: 'CLAIM_BILL_DIGITISATION__BILL_REFERENCE'
  INVOICE_STATUS: 'CLAIM_BILL_DIGITISATION__INVOICE_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
