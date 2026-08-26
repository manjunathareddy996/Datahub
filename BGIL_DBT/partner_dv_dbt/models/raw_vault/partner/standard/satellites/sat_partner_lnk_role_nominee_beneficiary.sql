{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='HASHDIFF'
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_LNK_ROLE_NOMINEE_BENEFICIARY (HUB_PARTY grain, role-special: 'nominee_beneficiary').

{%- set yaml_metadata -%}
source_model: 'stg2_std_union__lnk_role_nominee_beneficiary'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'APPOINTEE_NAME'
  - 'RELATIONSHIP_TO_INSURED'
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
