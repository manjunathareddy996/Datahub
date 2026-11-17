{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL ma_sat_multi_source() for SAT_POLICY_ENDORSEMENT.
-- Writes the SAME physical table as opus_partner / opus_health: separate projects, separate
-- pipelines, one shared vault. Grain is unchanged: POLICY_HKEY, multi-active on ENDORSEMENT_NUMBER,
-- bare HASHDIFF.
--
-- ma_sat_multi_source groups change detection by (POLICY_HKEY, RECORD_SOURCE) and takes the watermark
-- from MAX(DBT_RUN_TS) of MAXIMUS_TRAVEL_* rows only, so this project never compares against the
-- other projects' rows on the shared table. One satfeed per stage (no UNION).

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mt_sat_policy_endorsement__uwr_pol_endt'
  - 'satfeed_mt_sat_policy_endorsement__uwr_pol_polp_sp_pv'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'ENDORSEMENT_NUMBER'
src_payload:
  - 'EFFECTIVE_DATE'
  - 'ENDORSEMENT_APPROVAL_DATE'
  - 'ENDORSEMENT_INVOICE_REFERENCE'
  - 'ENDORSEMENT_REASON'
  - 'ENDORSEMENT_REMARKS'
  - 'ENDORSEMENT_TYPE'
  - 'ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE'
  - 'PREMIUM_IMPACT_AMOUNT'
  - 'REVISED_SUM_INSURED_AMOUNT'
  - 'SUM_INSURED_IMPACT_AMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  satfeed_mt_sat_policy_endorsement__uwr_pol_endt: 'MAXIMUS_TRAVEL'
  satfeed_mt_sat_policy_endorsement__uwr_pol_polp_sp_pv: 'MAXIMUS_TRAVEL'
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
                        'satfeed_mt_sat_policy_endorsement__uwr_pol_endt': ['EFFECTIVE_DATE', 'ENDORSEMENT_APPROVAL_DATE', 'ENDORSEMENT_INVOICE_REFERENCE', 'ENDORSEMENT_REASON', 'ENDORSEMENT_REMARKS', 'ENDORSEMENT_TYPE', 'ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE', 'PREMIUM_IMPACT_AMOUNT', 'REVISED_SUM_INSURED_AMOUNT', 'SUM_INSURED_IMPACT_AMOUNT'],
                        'satfeed_mt_sat_policy_endorsement__uwr_pol_polp_sp_pv': ['EFFECTIVE_DATE', 'ENDORSEMENT_APPROVAL_DATE', 'ENDORSEMENT_INVOICE_REFERENCE', 'ENDORSEMENT_REASON', 'ENDORSEMENT_REMARKS', 'ENDORSEMENT_TYPE', 'ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE', 'PREMIUM_IMPACT_AMOUNT', 'REVISED_SUM_INSURED_AMOUNT', 'SUM_INSURED_IMPACT_AMOUNT']
                       }) }}
