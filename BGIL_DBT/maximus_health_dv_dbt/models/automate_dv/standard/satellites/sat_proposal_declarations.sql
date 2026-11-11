-- Standard sat() for SAT_PROPOSAL_DECLARATIONS (parent HUB_PROPOSAL, history SCD2), fed whole from central view stitch_v17_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_proposal_declarations'
src_pk: 'PROPOSAL_HKEY'
src_payload:
  - 'ADVERSE_HEALTH_DECLARATION_INDICATOR'
  - 'EXISTING_POLICY_INDICATOR'
  - 'MEDICAL_HISTORY_DECLARATION_INDICATOR'
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
