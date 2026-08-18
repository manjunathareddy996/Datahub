{#
    Watermark helpers for parameterized incremental stitching (POC).

    get_to_date()
        Upper bound of the window. Returns a quoted SQL timestamp literal.
        Precedence:  var('to_date')  ->  run_started_at (frozen for the whole dbt run).

    get_from_date(sat_identifier)
        Lower bound of the window. Returns a quoted SQL timestamp literal.
        Precedence:
          1) var('from_date')                          -- explicit backfill / full reload
          2) MAX(DBT_RUN_TS) from the target sat        -- normal incremental watermark
          3) sentinel '1900-01-01'                      -- first run / sat absent / sat empty

        The sat is read via a DIRECT relation lookup (adapter.get_relation), NOT ref(),
        so the stitch->sat dependency does not create a dbt DAG cycle. A missing relation
        (first run) resolves to the sentinel, which makes the single window filter behave
        as a full load.
#}

{% macro get_to_date() %}
    {%- set td = var('to_date', run_started_at.strftime('%Y-%m-%d %H:%M:%S')) -%}
    {{ return("'" ~ td ~ "'") }}
{% endmacro %}


{% macro get_from_date(sat_identifier, sentinel='1900-01-01') %}

    {#-- 1) explicit override wins --#}
    {%- if var('from_date', none) is not none -%}
        {{ return("'" ~ var('from_date') ~ "'") }}
    {%- endif -%}

    {#-- during parse, avoid DB access --#}
    {%- if not execute -%}
        {{ return("'" ~ sentinel ~ "'") }}
    {%- endif -%}

    {#-- 2) read MAX(DBT_RUN_TS) from the sat, located directly (no ref -> no DAG cycle) --#}
    {%- set sat_rel = adapter.get_relation(
            database=this.database,
            schema=this.schema,
            identifier=sat_identifier) -%}

    {%- if sat_rel is none -%}
        {#-- 3) first run: sat does not exist yet -> full load --#}
        {{ return("'" ~ sentinel ~ "'") }}
    {%- endif -%}

    {%- set wm_query -%}
        SELECT COALESCE(MAX(DBT_RUN_TS), TO_TIMESTAMP_NTZ('{{ sentinel }}')) AS mx
        FROM {{ sat_rel }}
    {%- endset -%}

    {%- set results = run_query(wm_query) -%}

    {%- if results and (results.rows | length) > 0 and results.rows[0][0] is not none -%}
        {{ return("'" ~ results.rows[0][0] ~ "'") }}
    {%- else -%}
        {{ return("'" ~ sentinel ~ "'") }}
    {%- endif -%}

{% endmacro %}
