-- Standard sat() for SAT_CLAIM_ASSESSMENT_SUMMARY (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v01_agreement.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_claim_assessment_summary'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ADMISSIBLE_LOSS_AMOUNT'
  - 'ASSESSMENT_DATE'
  - 'DEDUCTIBLE_APPLIED'
  - 'TOTAL_DEDUCTION_AMOUNT'
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
