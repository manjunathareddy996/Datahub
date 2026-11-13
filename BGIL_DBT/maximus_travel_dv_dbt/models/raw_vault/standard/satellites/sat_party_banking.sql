{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat_multi_source() for SAT_PARTY_BANKING.
-- Writes the SAME physical table as the partner projects (maximus_partner / opus_partner):
-- separate projects, separate pipelines, one shared vault.
--
-- ma_sat_multi_source groups change detection and the watermark by (PARTY_HKEY, RECORD_SOURCE),
-- so MAXIMUS_TRAVEL_* rows never interact with the partners' OPUS_PARTNER_* / MAXIMUS_PARTNER_* rows.
-- Multi-active on the account number (a party can hold several bank accounts).
--
-- Column names deliberately match the partner projects (ACCOUNTNUMBERMASKED, BANKNAME, ...)
-- so the shared table has one set of payload columns. The renames happen in
-- satfeed_mt_sat_party_banking.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mt_sat_party_banking'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'ACCOUNTNUMBERMASKED'
src_payload:
  - 'ACCOUNTHOLDERNAME'
  - 'ACCOUNTTYPE'
  - 'BANKNAME'
  - 'BRANCHNAME'
  - 'IFSCCODE'
  - 'MICRCODE'
  - 'PRIMARYACCOUNTINDICATOR'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mt_sat_party_banking: 'MAXIMUS_TRAVEL'
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
                        'satfeed_mt_sat_party_banking': ['ACCOUNTHOLDERNAME', 'ACCOUNTTYPE', 'BANKNAME', 'BRANCHNAME', 'IFSCCODE', 'MICRCODE', 'PRIMARYACCOUNTINDICATOR']
                       }) }}
