{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_POLICY_PREMIUM_SUMMARY (HUB_POLICY grain) -- stitch-backed, 18 table(s) joined.
-- Source: stg2_policy_premium_summary.

{%- set yaml_metadata -%}
source_model: 'stg2_policy_premium_summary'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'ADD_ON_PREMIUM'
  - 'BASE_PREMIUM'
  - 'GROSS_PREMIUM'
  - 'GROUP_DISCOUNT_AMOUNT'
  - 'INSTALMENT_COUNT'
  - 'LONG_TERM_DISCOUNT_AMOUNT'
  - 'NET_PREMIUM'
  - 'TERRORISM_PREMIUM'
  - 'TOTAL_PREMIUM_COLLECTED'
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
