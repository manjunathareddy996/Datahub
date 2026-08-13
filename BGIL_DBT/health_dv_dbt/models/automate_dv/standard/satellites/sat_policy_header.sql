{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_POLICY_HEADER (HUB_POLICY grain) -- stitch-backed, 31 table(s) joined.
-- Source: stg2_policy_header.

{%- set yaml_metadata -%}
source_model: 'stg2_policy_header'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'COVER_NOTE_DATE'
  - 'COVER_NOTE_REFERENCE'
  - 'FIRST_YEAR_INDICATOR'
  - 'ISSUE_DATE'
  - 'MASTER_POLICY_REFERENCE'
  - 'POLICY_NUMBER'
  - 'POLICY_REMARKS'
  - 'POLICY_STATUS'
  - 'POLICY_TERM'
  - 'POLICY_TERM_DAYS'
  - 'POLICY_TYPE'
  - 'PREMIUM_PAYER_REFERENCE'
  - 'RISK_EXPIRY_DATE'
  - 'RISK_INCEPTION_DATE'
  - 'RISK_START_TIME'
  - 'SUM_INSURED_BASIS'
  - 'SUM_INSURED_TOTAL'
  - 'TOP_UP_POLICY_INDICATOR'
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
