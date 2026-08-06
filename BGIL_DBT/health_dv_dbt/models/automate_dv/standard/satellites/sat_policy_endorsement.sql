{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_POLICY_ENDORSEMENT (HUB_POLICY grain) -- stitch-backed, 2 table(s) joined.
-- Source: stg2_policy_endorsement.

{%- set yaml_metadata -%}
source_model: 'stg2_policy_endorsement'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'ENDORSEMENT_NUMBER_CK'
src_payload:
  - 'EFFECTIVE_DATE'
  - 'ENDORSEMENT_DATE'
  - 'ENDORSEMENT_NUMBER'
  - 'ENDORSEMENT_TYPE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
