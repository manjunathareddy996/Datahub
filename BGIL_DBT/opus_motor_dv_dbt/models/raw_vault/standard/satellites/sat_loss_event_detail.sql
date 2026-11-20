-- Standard sat() for SAT_LOSS_EVENT_DETAIL (parent HUB_LOSS_EVENT, history SCD2), fed whole from central view stitch_motor__v01_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__loss_event_detail'
src_pk:
  - 'LOSS_EVENT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'CAUSE_OF_LOSS'
  - 'ESTIMATED_LOSS_AMOUNT'
  - 'FIR_NUMBER'
  - 'LOSS_DATE'
  - 'LOSS_DESCRIPTION'
  - 'LOSS_EVENT_TYPE'
  - 'LOSS_TIME'
  - 'PERIL_CODE'
  - 'POLICE_STATION_NAME'
  - 'SUB_PERIL_CODE'
  - 'THIRD_PARTY_INVOLVED_INDICATOR'
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
