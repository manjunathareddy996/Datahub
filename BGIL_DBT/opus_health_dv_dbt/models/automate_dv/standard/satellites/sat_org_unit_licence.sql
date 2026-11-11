-- Standard sat() for SAT_ORG_UNIT_LICENCE (parent HUB_ORG_UNIT, history SCD2), fed whole from central view stitch_v14_org_unit.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_org_unit_licence'
src_pk: 'ORG_UNIT_HKEY'
src_payload:
  - 'GST_REGISTRATION_NUMBER'
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
