{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='HASHDIFF'
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_PARTY_BANKING (HUB_PARTY grain) -- union of 5 table(s).

{%- set yaml_metadata -%}
source_model: 'stg2_std_union__party_banking'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ACCOUNTNUMBERMASKED'
  - 'BANKCODE'
  - 'BANKNAME'
  - 'IFSCCODE'
  - 'MICRCODE'
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
