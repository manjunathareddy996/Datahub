-- Standard sat() for SAT_PARTY_LEGAL_PANEL (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v10_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_party_legal_panel'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ADVOCATE_TYPE'
  - 'AGREEMENT_STATUS'
  - 'BAR_COUNCIL_NAME'
  - 'BAR_ENROLMENT_NUMBER'
  - 'CASES_HANDLED_COUNT'
  - 'EMPANELMENT_DATE'
  - 'JUNIORS_COUNT'
  - 'PANEL_CATEGORY'
  - 'YEARS_OF_PRACTICE'
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
