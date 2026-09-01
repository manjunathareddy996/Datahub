{{ config(materialized='incremental') }}

-- TRAVEL AUGMENTED (build-side, no modeler round-trip -- see
-- docs/TRAVEL_FIXES_APPLIED.md) sat() for SAT_AUG_PARTY_EMPLOYMENT.


{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_party_employment_ba_trv_data_policy_dtls_mv_cft_emp_no'
  - 'stg2_aug_party_employment_bjaz_trv_loader_log_table_mv_empno'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'EMPLOYEE_NUMBER'
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
