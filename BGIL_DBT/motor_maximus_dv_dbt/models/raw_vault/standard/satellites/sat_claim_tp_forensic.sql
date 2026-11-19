-- Standard sat() for SAT_CLAIM_TP_FORENSIC (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW | SAT_CLAIM_TP_FORENSIC | FIR Date | None: emits POLICE_REPORT_DATE; withheld POLICE_REPORTED_DATE
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__claim_tp_forensic'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'CHARGESHEET_SECTION'
  - 'FIR_DATE'
  - 'FIR_NUMBER'
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
