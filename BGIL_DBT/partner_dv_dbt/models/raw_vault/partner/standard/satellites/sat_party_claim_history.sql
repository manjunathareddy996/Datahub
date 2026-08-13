{{ config(materialized='incremental') }}

-- PARTNER STANDARD-MODEL sat() for SAT_PARTY_CLAIM_HISTORY (HUB_PARTY grain) -- stitch-backed, 6 table(s).
-- Source: stg2_party_claim_history.

{%- set yaml_metadata -%}
source_model: 'stg2_party_claim_history'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'TOTALCLAIMAMOUNT'
  - 'TOTALCLAIMCOUNT'
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
