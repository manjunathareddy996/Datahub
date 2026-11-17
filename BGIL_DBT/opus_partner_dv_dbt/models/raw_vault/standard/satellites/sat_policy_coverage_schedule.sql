{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_POLICY_COVERAGE_SCHEDULE (HUB_POLICY grain) -- single source.
-- Grain unchanged: single-active on POLICY_HKEY with COVERAGE_SEQUENCE as payload
-- (UPPER_SNAKE name shared with maximus_travel / opus_health on this table).
-- sat_multi_source keeps change detection and the watermark per (POLICY_HKEY, RECORD_SOURCE) on
-- OPUS_PARTNER_* rows only, so the other projects' rows on the shared table are never touched.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_dt_mem__policy_coverage_schedule'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'COVERAGE_SEQUENCE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_sat_ba_hcp_dt_mem__policy_coverage_schedule: 'OPUS_PARTNER'
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
                        'stg2_sat_ba_hcp_dt_mem__policy_coverage_schedule': ['COVERAGE_SEQUENCE']
                    }) }}
