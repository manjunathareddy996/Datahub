-- Standard sat() for SAT_CLAIM_RECOVERY_SALVAGE (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_motor__v02_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__claim_recovery_salvage'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'RECOVERY_EXPENSE'
  - 'SALVAGE_DISPOSAL_METHOD'
  - 'SALVAGE_REALISED_AMOUNT'
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
