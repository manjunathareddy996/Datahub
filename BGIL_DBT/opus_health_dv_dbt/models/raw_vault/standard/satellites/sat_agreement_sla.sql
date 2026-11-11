-- Standard sat() for SAT_AGREEMENT_SLA (parent HUB_AGREEMENT, history SCD2), fed whole from central view stitch_v01_agreement.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_agreement_sla'
src_pk: 'AGREEMENT_HKEY'
src_payload:
  - 'SERVICE_LEVEL_TARGET'
  - 'TAT_COMMITMENT'
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
