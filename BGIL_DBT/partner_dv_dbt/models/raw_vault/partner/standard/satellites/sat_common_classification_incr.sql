{{ config(materialized='incremental') }}

-- POC: sat() over stg2_common_classification_incr (HUB_PARTY grain).
-- PRIORITYCODE / SEGMENTCODE drive hashdiff change detection.
-- DBT_RUN_TS is carried as a NON-hashdiff extra column (so it never triggers a new version);
-- it is the watermark that stitch_common_classification_incr reads back via MAX(DBT_RUN_TS).

{%- set yaml_metadata -%}
source_model: 'stg2_common_classification_incr'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'PRIORITYCODE'
  - 'SEGMENTCODE'
src_extra_columns:
  - 'DBT_RUN_TS'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_extra_columns=metadata_dict['src_extra_columns'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
