{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC STANDARD-MODEL ma_sat() for SAT_POLICY_CLASSIFICATION (HUB_POLICY grain) -- union of 4 branch(es).
-- data_7: hist 'Multi-Active SCD2', childkey 'Classification Type', anchor parent 'HUB_POLICY'.
-- Payload rendered GLUED (DEC-01, anchor kind HUB read from data_7's parent field).
--
-- Multi-active: src_cdk ['CLASSIFICATIONTYPE'] carries the model's declared child-key leg(s). The
-- child-key VALUE is a literal derived from COLUMN IDENTITY, not from data
-- ordering, so it cannot renumber between reloads (BUILD_RULES.md 5.1).
--
-- opus_partner_dv_dbt: written in this project's pattern -- incremental append, ma_sat_multi_source, src_record_source_map OPUS, src_column_map per source; source_model listed once each.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_t_kyc_details__policy_classification'
  - 'stg2_sat_bjaz_t_kyc_incoming__policy_classification'
  - 'stg2_sat_bjaz_t_kyc_poa_document__policy_classification'
  - 'stg2_sat_bjaz_t_kyc_poi_document__policy_classification'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'CLASSIFICATIONTYPE'
src_payload:
  - 'CLASSIFICATIONVALUE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_sat_bjaz_t_kyc_details__policy_classification: 'OPUS'
  stg2_sat_bjaz_t_kyc_incoming__policy_classification: 'OPUS'
  stg2_sat_bjaz_t_kyc_poa_document__policy_classification: 'OPUS'
  stg2_sat_bjaz_t_kyc_poi_document__policy_classification: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_record_source_map=metadata_dict['src_record_source_map'],
                       src_column_map={
                           'stg2_sat_bjaz_t_kyc_details__policy_classification': ['CLASSIFICATIONVALUE'],
                           'stg2_sat_bjaz_t_kyc_incoming__policy_classification': ['CLASSIFICATIONVALUE'],
                           'stg2_sat_bjaz_t_kyc_poa_document__policy_classification': ['CLASSIFICATIONVALUE'],
                           'stg2_sat_bjaz_t_kyc_poi_document__policy_classification': ['CLASSIFICATIONVALUE']
                       }) }}
