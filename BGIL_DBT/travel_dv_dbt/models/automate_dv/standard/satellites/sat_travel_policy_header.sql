{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_POLICY_HEADER (parent HUB_POLICY).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_policy_header_ba_trv_data_policy_dtls_mv'
  - 'stg2_policy_header_bjaz_trv_loader_data_mv'
  - 'stg2_policy_header_bjaz_trv_loader_log_table_mv'
  - 'stg2_policy_header_bjaz_trv_rider_dtls_mv'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'COVER_NOTE_DATE'
  - 'COVER_NOTE_REFERENCE'
  - 'ISSUE_DATE'
  - 'MASTER_POLICY_REFERENCE'
  - 'NUMBER_OF_LIVES_COVERED'
  - 'POLICY_NUMBER'
  - 'POLICY_TYPE'
  - 'RISK_EXPIRY_DATE'
  - 'RISK_INCEPTION_DATE'
  - 'RURAL_SECTOR_POLICY_INDICATOR'
  - 'SUM_INSURED_TOTAL'
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
