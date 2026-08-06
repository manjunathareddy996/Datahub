{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_POLICY_TERMS (HUB_POLICY grain) -- stitch-backed, 9 table(s) joined.
-- Source: stg2_policy_terms.

{%- set yaml_metadata -%}
source_model: 'stg2_policy_terms'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'CO_PAYMENT_PERCENTAGE'
  - 'DEDUCTIBLE_TOTAL'
  - 'SPECIAL_CONDITIONS'
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
