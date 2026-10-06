{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC STANDARD-MODEL sat() for SAT_POLICY_PREMIUM_SUMMARY (HUB_POLICY grain) -- union of 2 branch(es).
-- data_7: hist 'SCD2', childkey '', anchor parent 'HUB_POLICY'.
-- Payload rendered GLUED (DEC-01, anchor kind HUB read from data_7's parent field).
--
-- KNOWN DESTRUCTIVE OVERWRITE, BUILT AS MAPPED AND RAISED (5.7). 1 attribute(s)
-- of this SINGLE-ACTIVE satellite are written by more than one source table
-- under a byte-identical HUB_POLICY key with an EMPTY discriminator, so whichever
-- branch loads last wins: Gross Premium.
-- The builder refuses to invent a discriminator. One modeller answer unblocks it.
--
-- opus_partner_dv_dbt: written in this project's pattern -- incremental append, sat_multi_source, src_record_source_map OPUS, src_column_map per source; source_model listed once each.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_t_kyc_incoming__policy_premium_summary'
  - 'stg2_sat_bjaz_t_kyc_ocr__policy_premium_summary'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'GROSSPREMIUM'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_sat_bjaz_t_kyc_incoming__policy_premium_summary: 'OPUS'
  stg2_sat_bjaz_t_kyc_ocr__policy_premium_summary: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_sat_bjaz_t_kyc_incoming__policy_premium_summary': ['GROSSPREMIUM'],
                        'stg2_sat_bjaz_t_kyc_ocr__policy_premium_summary': ['GROSSPREMIUM']
                    }) }}
