{%- macro get_incremental_filter(sat_database, sat_schema, sat_table, record_source, filter_column='updated_at', ldts_column='LOAD_DATETIME') -%}
{#-- 
  Incremental filter for stg models that look back at a downstream satellite.
  Uses adapter.get_relation() (metadata-only check, no ref()) to avoid circular deps.
  Filters by RECORD_SOURCE so each source gets its OWN watermark independently.
  
  On first run: sat doesn't exist -> no WHERE clause -> all rows pass.
  On subsequent runs: only rows newer than THIS source's max LOAD_DATETIME come through.

  Usage:
    from {{ source('demo_raw', 'TABLE_A') }}
    {{ get_incremental_filter('BAGIC_PREPROD_CURATED_DB', 'BGIL_DEV_DATA_MODEL', 'SAT_A_B', 'TABLE_A') }}
-#}
{%- set sat_relation = adapter.get_relation(
      database=sat_database,
      schema=sat_schema,
      identifier=sat_table
) -%}
{%- if sat_relation %}
where {{ filter_column }} > (
    select max({{ ldts_column }})
    from {{ sat_database }}.{{ sat_schema }}.{{ sat_table }}
    where RECORD_SOURCE = '{{ record_source }}'
)
{%- endif %}
{%- endmacro -%}
