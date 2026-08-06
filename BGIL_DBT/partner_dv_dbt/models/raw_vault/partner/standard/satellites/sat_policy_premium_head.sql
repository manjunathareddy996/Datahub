{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL sat() for SAT_POLICY_PREMIUM_HEAD (HUB_POLICY grain) -- union of 2 table(s).

{%- set yaml_metadata -%}
source_model: 'stg2_std_union__policy_premium_head'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'BASEAMOUNT'
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
