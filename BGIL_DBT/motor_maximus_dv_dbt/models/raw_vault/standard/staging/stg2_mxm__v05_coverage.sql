-- automate_dv.stage() over central view stitch_mxm__v05_coverage: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v05_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
derived_columns:
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v05_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
