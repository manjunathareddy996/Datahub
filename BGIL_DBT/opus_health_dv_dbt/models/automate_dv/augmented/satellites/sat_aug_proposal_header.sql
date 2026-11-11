-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PROPOSAL_HEADER (parent HUB_PROPOSAL, history SCD2), fed whole from central view stitch_v33_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_proposal_header'
src_pk: 'PROPOSAL_HKEY'
src_payload:
  - 'SERVICING_REQUEST_NUMBER'
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
