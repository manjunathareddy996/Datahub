{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC STANDARD-MODEL sat() for SAT_PARTY_AML_SCREENING (HUB_PARTY grain) -- union of 1 branch(es).
-- data_7: hist 'SCD2', childkey '', anchor parent 'HUB_PARTY'.
-- Payload rendered GLUED (DEC-01, anchor kind HUB read from data_7's parent field).
--
-- opus_partner_dv_dbt: written in this project's pattern -- incremental append, automate_dv.sat.

{%- set yaml_metadata -%}
source_model: 'stg2_sat_bjaz_t_ckyc_personal_dtls__party_aml_screening'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'CRSREPORTABLEINDICATOR'
  - 'TAXRESIDENCYCOUNTRY'
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
