-- Standard sat() for SAT_CLAIM_FNOL (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__claim_fnol'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'FNOL_CHANNEL'
  - 'FNOL_DATE'
  - 'FNOL_REFERENCE'
  - 'FNOL_TIME'
  - 'LOCATION_OF_LOSS'
  - 'PRELIMINARY_LOSS_DESCRIPTION'
  - 'PRELIMINARY_LOSS_ESTIMATE'
  - 'REPORTED_BY_CONTACT'
  - 'REPORTED_BY_NAME'
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
