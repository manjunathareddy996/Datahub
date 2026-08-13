{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_POLICY_PORTABILITY_MIGRATION (HUB_POLICY grain) -- stitch-backed, 13 table(s) joined.
-- Source: stg2_policy_portability_migration.

{%- set yaml_metadata -%}
source_model: 'stg2_policy_portability_migration'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'CONTINUITY_PERIOD_GRANTED'
  - 'CUMULATIVE_BONUS_PORTED'
  - 'PORTABILITY_INDICATOR'
  - 'PREVIOUS_INSURER_NAME'
  - 'PREVIOUS_POLICY_NUMBER'
  - 'PREVIOUS_SUM_INSURED'
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
