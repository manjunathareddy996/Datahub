-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_PARTY_LEGAL_PANEL (parent HUB_PARTY, history SCD2), fed whole from central view stitch_v10_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_party_legal_panel'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'CONSUMER_CASES_HANDLED_COUNT'
  - 'COVERED_COURT_LOCATIONS'
  - 'EMPANELLED_COMPANIES_COUNT'
  - 'FIRM_NAME'
  - 'HIGH_COURT_PRACTICE_INDICATOR'
  - 'MACT_CASES_HANDLED_COUNT'
  - 'MACT_CASES_HANDLED_OTHER_COMPANY_COUNT'
  - 'PRACTISING_WITH_HIGH_COURT_INDICATOR'
  - 'SERVICING_INSURER_OFFICE_ADDRESS'
  - 'WC_CASES_HANDLED_COUNT'
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
