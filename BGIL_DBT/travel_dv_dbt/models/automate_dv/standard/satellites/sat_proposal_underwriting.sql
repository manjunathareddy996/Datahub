{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL sat() for SAT_PROPOSAL_UNDERWRITING (parent HUB_PROPOSAL).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_proposal_underwriting_ba_trv_data_policy_dtls_mv'
src_pk: 'PROPOSAL_HKEY'
src_payload:
  - 'REFERRAL_DATE'
  - 'REFERRAL_INDICATOR'
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
