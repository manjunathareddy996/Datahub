{{ config(materialized='incremental') }}

-- STANDARD-MODEL sat() for SAT_POLICY_BONUS_TRACKING (HUB_POLICY grain) -- stitch-backed, 6 table(s) joined.
-- Source: stg2_policy_bonus_tracking.

{%- set yaml_metadata -%}
source_model: 'stg2_policy_bonus_tracking'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'BONUS_AMOUNT'
  - 'CUMULATIVE_BONUS_PERCENTAGE'
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
