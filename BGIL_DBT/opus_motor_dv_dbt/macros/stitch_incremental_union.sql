{% macro stitch_incremental_union(sources, output_columns, coalesce_rules, unique_key='parent_bk', target_sat=none, source_group=none, child_keys=[]) %}

{#-- stitch_incremental_union: the stitch_incremental behaviour, where one source (one CTE) can be a
     UNION of several tables. stitch_incremental.sql is left exactly as in opus_partner_dv_dbt.

     Same as stitch_incremental: the watermark window finds the changed keys, every source is read at
     full history for those keys, coalesce_rules ranks the sources per column, and the output is one
     row per key with record_source and inc_job_updated_at. The call takes the same arguments, plus
     the optional source_group and child_keys.

     A sources entry is either one table, exactly as for stitch_incremental:
         {'model': ..., 'alias': 't0', 'key_column': ..., 'ldts_column': ..., 'columns': [...], 'source_tag': ...}
     or several tables under one alias, UNION ALL'd into that alias's CTE:
         {'alias': 't0', 'union': [ {'model', 'key_column', 'ldts_column', 'columns', 'source_tag'}, ... ]}
     Members may differ in key expression, columns and ldts column. A column a member does not map is
     NULL for that member. The same table may appear several times, e.g. once per child-key literal.
     Column references in key_column and src are unqualified, as in stitch_incremental.

     Where it differs from stitch_incremental:
     1. Each alias is reduced to one row per key before the join. Per column it takes the first non-null
        value in member order (the first member wins), and inside one member the row with the lowest
        HASH(*) of its stg1 row: the motor central views' first_value(...) ignore nulls order by
        __PREC, __RID. stitch_incremental joins every row of every source and keeps the combination
        whose values sort first. When each table has one row per key, both give the same result.
     2. record_source lists the source_tags of the members that have a row for the key, in member order
        and then alias order. inc_job_updated_at is the newest ldts among the parent key's rows.
     3. child_keys (optional): output columns that, with unique_key, form a multi-active satellite's
        grain. The output is one row per (unique_key, child keys). Changed keys are still found on
        unique_key, so every child of a changed parent is sent again: ma_sat() compares a parent's whole
        child set. inc_job_updated_at is one value per parent, because ma_sat() takes a parent's latest
        group to be its rows with the highest LOAD_DATETIME. Map each child key in the members' columns
        like any column, e.g. {'src': "'IDENTY_PROFF'", 'tgt': 'document_type_ck'}.
     4. Sources are read through ref(), so dbt builds them before the stitch. No depends_on comments needed.
     5. source_group (optional, e.g. 'OPUS_MOTOR') is the RECORD_SOURCE prefix the watermark is scoped to,
        and every source_tag must start with '<source_group>_'. Without it the group is the text before
        the first underscore of the source_tags, as in stitch_incremental ('OPUS' for 'OPUS_MOTOR_...').
     6. If the target sat exists but has no DBT_RUN_TS or RECORD_SOURCE column yet (a shared table another
        project created), the watermark uses the sentinel instead of running a query that would fail.
     7. Config mistakes fail at compile time with a message that names the source. --#}

{#-- 1. Normalise every sources entry into an alias with a list of members, and validate the config. --#}
{%- set ns = namespace(aliases=[], members=[], group=none) -%}
{%- set alias_names = [] -%}
{%- set reserved = [unique_key | lower, '__ldts', '__member', '__rid', '__ldts_max', '__record_source', 'record_source', 'inc_job_updated_at'] -%}
{%- set child_names = child_keys | map('lower') | list -%}
{%- for ck in child_keys -%}
    {%- if (ck | lower) in reserved -%}
        {{ exceptions.raise_compiler_error("stitch_incremental_union: child key '" ~ ck ~ "' uses a reserved name") }}
    {%- endif -%}
    {%- if ck in output_columns -%}
        {{ exceptions.raise_compiler_error("stitch_incremental_union: child key '" ~ ck ~ "' is also in output_columns. Child keys are output on their own, after unique_key.") }}
    {%- endif -%}
{%- endfor -%}
{%- for src in sources -%}
    {%- if 'alias' not in src -%}
        {{ exceptions.raise_compiler_error("stitch_incremental_union: a sources entry has no 'alias'") }}
    {%- endif -%}
    {%- if src['alias'] in alias_names -%}
        {{ exceptions.raise_compiler_error("stitch_incremental_union: alias '" ~ src['alias'] ~ "' is used by two sources entries. To combine tables in one CTE, list them under one 'union'.") }}
    {%- endif -%}
    {%- do alias_names.append(src['alias']) -%}
    {%- if ('union' in src) == ('model' in src) -%}
        {{ exceptions.raise_compiler_error("stitch_incremental_union: source '" ~ src['alias'] ~ "' needs exactly one of 'model' or 'union'") }}
    {%- endif -%}
    {%- set members = src['union'] if 'union' in src else [src] -%}
    {%- if members | length == 0 -%}
        {{ exceptions.raise_compiler_error("stitch_incremental_union: source '" ~ src['alias'] ~ "' has an empty 'union'") }}
    {%- endif -%}
    {%- set a_columns = [] -%}
    {%- set tag_names = [] -%}
    {%- set tag_members = {} -%}
    {%- for m in members -%}
        {%- set member_index = loop.index0 -%}
        {%- for field in ['model', 'key_column', 'ldts_column', 'columns', 'source_tag'] -%}
            {%- if field not in m -%}
                {{ exceptions.raise_compiler_error("stitch_incremental_union: member " ~ member_index ~ " of source '" ~ src['alias'] ~ "' has no '" ~ field ~ "'") }}
            {%- endif -%}
        {%- endfor -%}
        {%- set member_tgts = [] -%}
        {%- for col in m['columns'] -%}
            {%- if 'src' not in col or 'tgt' not in col -%}
                {{ exceptions.raise_compiler_error("stitch_incremental_union: a column of '" ~ m['model'] ~ "' in source '" ~ src['alias'] ~ "' needs both 'src' and 'tgt'") }}
            {%- endif -%}
            {%- if (col['tgt'] | lower) in reserved -%}
                {{ exceptions.raise_compiler_error("stitch_incremental_union: '" ~ m['model'] ~ "' maps a column to the reserved name '" ~ col['tgt'] ~ "'") }}
            {%- endif -%}
            {%- if col['tgt'] in member_tgts -%}
                {{ exceptions.raise_compiler_error("stitch_incremental_union: '" ~ m['model'] ~ "' maps two columns to '" ~ col['tgt'] ~ "' in source '" ~ src['alias'] ~ "'. Combine them in one 'src' expression, e.g. coalesce(a, b).") }}
            {%- endif -%}
            {%- do member_tgts.append(col['tgt']) -%}
            {%- if col['tgt'] not in a_columns and (col['tgt'] | lower) not in child_names -%}
                {%- do a_columns.append(col['tgt']) -%}
            {%- endif -%}
        {%- endfor -%}
        {%- if m['source_tag'] not in tag_names -%}
            {%- do tag_names.append(m['source_tag']) -%}
            {%- do tag_members.update({m['source_tag']: []}) -%}
        {%- endif -%}
        {%- do tag_members[m['source_tag']].append(member_index) -%}
        {%- do ns.members.append(m) -%}
    {%- endfor -%}
    {%- do ns.aliases.append({'alias': src['alias'], 'members': members, 'columns': a_columns,
                              'tag_names': tag_names, 'tag_members': tag_members}) -%}
{%- endfor -%}

{#-- Every child key must be mapped by at least one member. --#}
{%- for ck in child_keys -%}
    {%- set ns_ck = namespace(found=false) -%}
    {%- for m in ns.members -%}
        {%- for c in m['columns'] -%}
            {%- if c['tgt'] == ck -%}
                {%- set ns_ck.found = true -%}
            {%- endif -%}
        {%- endfor -%}
    {%- endfor -%}
    {%- if not ns_ck.found -%}
        {{ exceptions.raise_compiler_error("stitch_incremental_union: child key '" ~ ck ~ "' is not mapped by any member") }}
    {%- endif -%}
{%- endfor -%}

{#-- Every output column needs a coalesce rule, and every alias in a rule must provide that column. --#}
{%- for col in output_columns -%}
    {%- if col not in coalesce_rules -%}
        {{ exceptions.raise_compiler_error("stitch_incremental_union: output column '" ~ col ~ "' has no coalesce_rules entry") }}
    {%- endif -%}
    {%- for alias in coalesce_rules[col] -%}
        {%- set ns_rule = namespace(found=false) -%}
        {%- for a in ns.aliases -%}
            {%- if a['alias'] == alias and col in a['columns'] -%}
                {%- set ns_rule.found = true -%}
            {%- endif -%}
        {%- endfor -%}
        {%- if not ns_rule.found -%}
            {{ exceptions.raise_compiler_error("stitch_incremental_union: coalesce_rules['" ~ col ~ "'] names '" ~ alias ~ "', but no table in that source maps a column to '" ~ col ~ "'") }}
        {%- endif -%}
    {%- endfor -%}
{%- endfor -%}

{#-- When target_sat is provided, use the parameterized watermark window
     (from_date < ldts_column <= to_date). Otherwise keep the original T-1 filter. --#}
{%- if target_sat is not none -%}

    {#-- The source-system group scopes the MAX(DBT_RUN_TS) watermark to this system's rows in the
         shared target sat via RECORD_SOURCE LIKE '<group>_%'. A stitch is single-system by design:
         with source_group, every source_tag must start with it; without it, every source_tag must
         share the text before its first underscore (the stitch_incremental rule). --#}
    {%- for m in ns.members -%}
        {%- if m['source_tag'] is none or '_' not in m['source_tag'] -%}
            {{ exceptions.raise_compiler_error("stitch_incremental_union: source '" ~ m['model'] ~ "' has a missing or malformed source_tag '" ~ (m['source_tag'] | default('')) ~ "' (expected '<SYSTEM>_<TABLE>')") }}
        {%- endif -%}
        {%- if source_group is not none -%}
            {%- if not m['source_tag'].startswith(source_group ~ '_') -%}
                {{ exceptions.raise_compiler_error("stitch_incremental_union: source_tag '" ~ m['source_tag'] ~ "' does not start with source_group '" ~ source_group ~ "_'") }}
            {%- endif -%}
        {%- else -%}
            {%- set src_group = m['source_tag'].split('_')[0] -%}
            {%- if ns.group is none -%}
                {%- set ns.group = src_group -%}
            {%- elif src_group != ns.group -%}
                {{ exceptions.raise_compiler_error("stitch_incremental_union: mixed source-system prefixes in one stitch ('" ~ ns.group ~ "' vs '" ~ src_group ~ "'). A stitch must be single-system.") }}
            {%- endif -%}
        {%- endif -%}
    {%- endfor -%}
    {%- set wm_group = source_group if source_group is not none else ns.group -%}

    {#-- Resolve to_date. var('to_date') overrides; otherwise convert run_started_at (UTC) to IST in SQL
         via CONVERT_TIMEZONE so it is guaranteed IST regardless of run_started_at's rendered timezone.
         Stored as a SQL expression string (not a quoted literal) so it is used directly in the filter. --#}
    {%- if var('to_date', none) is not none -%}
        {%- set to_date_expr = "CAST('" ~ var('to_date') ~ "' AS TIMESTAMP_NTZ)" -%}
    {%- else -%}
        {%- set to_date_expr = "CAST(CONVERT_TIMEZONE('UTC','Asia/Kolkata', '" ~ run_started_at.strftime('%Y-%m-%d %H:%M:%S') ~ "'::timestamp_ntz) AS TIMESTAMP_NTZ)" -%}
    {%- endif -%}

    {#-- Resolve from_date: var override -> MAX(DBT_RUN_TS) from sat -> sentinel --#}
    {%- set sentinel = '1900-01-01' -%}
    {%- if var('from_date', none) is not none -%}
        {%- set from_date = "'" ~ var('from_date') ~ "'" -%}
    {%- elif not execute -%}
        {%- set from_date = "'" ~ sentinel ~ "'" -%}
    {%- else -%}
        {%- set sat_rel = adapter.get_relation(
                database=this.database if this else target.database,
                schema=this.schema if this else target.schema,
                identifier=target_sat) -%}
        {%- set sat_columns = [] if sat_rel is none else (adapter.get_columns_in_relation(sat_rel) | map(attribute='name') | map('upper') | list) -%}
        {%- if 'DBT_RUN_TS' not in sat_columns or 'RECORD_SOURCE' not in sat_columns -%}
            {%- set from_date = "'" ~ sentinel ~ "'" -%}
        {%- else -%}
            {%- set wm_query -%}
                SELECT COALESCE(MAX(DBT_RUN_TS), TO_TIMESTAMP_NTZ('{{ sentinel }}')) AS mx
                FROM {{ sat_rel }}
                WHERE RECORD_SOURCE LIKE '{{ wm_group }}_%'
            {%- endset -%}
            {%- set results = run_query(wm_query) -%}
            {%- if results and (results.rows | length) > 0 and results.rows[0][0] is not none -%}
                {%- set from_date = "'" ~ results.rows[0][0] ~ "'" -%}
            {%- else -%}
                {%- set from_date = "'" ~ sentinel ~ "'" -%}
            {%- endif -%}
        {%- endif -%}
    {%- endif -%}

{%- endif -%}

{#-- Grain inside one alias: unique_key plus the child keys. Row order: member order, then row hash. --#}
{%- set ns_g = namespace(r=['r.' ~ unique_key], plain=[unique_key]) -%}
{%- for ck in child_keys -%}
    {%- do ns_g.r.append('r.' ~ ck) -%}
    {%- do ns_g.plain.append(ck) -%}
{%- endfor %}
WITH affected_keys AS (
    {%- for m in ns.members %}
    SELECT DISTINCT {{ m['key_column'] }} AS {{ unique_key }}
    FROM {{ ref(m['model']) }}
    WHERE {{ m['key_column'] }} IS NOT NULL
    {%- if target_sat is not none %}
      AND {{ m['ldts_column'] }} >  CAST({{ from_date }} AS TIMESTAMP_NTZ)
      AND {{ m['ldts_column'] }} <= {{ to_date_expr }}
    {%- else %}
      AND {{ m['ldts_column'] }} >= DATEADD(DAY, -1, CURRENT_DATE())
    {%- endif %}
    {%- if not loop.last %}
    UNION
    {%- endif %}
    {%- endfor %}
),
{%- for a in ns.aliases %}
{#-- Every member of the alias at full history, for the changed keys only. --#}
{{ a['alias'] }}_rows AS (
    {%- for m in a['members'] %}
    SELECT
        {{ m['key_column'] }} AS {{ unique_key }},
        {%- for col in child_keys + a['columns'] %}
        {%- set ns_col = namespace(expr=none) %}
        {%- for c in m['columns'] %}{% if c['tgt'] == col %}{% set ns_col.expr = c['src'] %}{% endif %}{% endfor %}
        {%- if ns_col.expr is not none %}
        NULLIF(TRIM(TO_VARCHAR({{ ns_col.expr }})), '') AS {{ col }},
        {%- else %}
        CAST(NULL AS VARCHAR) AS {{ col }},
        {%- endif %}
        {%- endfor %}
        CAST({{ m['ldts_column'] }} AS TIMESTAMP_NTZ) AS __ldts,
        {{ loop.index0 }} AS __member,
        HASH(*) AS __rid
    FROM {{ ref(m['model']) }}
    WHERE {{ m['key_column'] }} IS NOT NULL
      AND {{ m['key_column'] }} IN (SELECT {{ unique_key }} FROM affected_keys)
    {%- if not loop.last %}
    UNION ALL
    {%- endif %}
    {%- endfor %}
),
{#-- One row per grain for the alias: first non-null value per column, in row order. --#}
{{ a['alias'] }} AS (
    SELECT
        {%- for g in ns_g.r %}
        {{ g }},
        {%- endfor %}
        {%- for col in a['columns'] %}
        FIRST_VALUE(r.{{ col }}) IGNORE NULLS OVER (
            PARTITION BY {{ ns_g.r | join(', ') }} ORDER BY r.__member, r.__rid
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS {{ col }},
        {%- endfor %}
        MAX(r.__ldts) OVER (PARTITION BY r.{{ unique_key }}) AS __ldts_max,
        ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(
            {%- for tag in a['tag_names'] %}
            IFF(MAX(IFF(r.__member IN ({{ a['tag_members'][tag] | join(', ') }}), 1, 0)) OVER (PARTITION BY {{ ns_g.r | join(', ') }}) = 1, '{{ tag }}', NULL){% if not loop.last %},{% endif %}
            {%- endfor %}
        ), ', ') AS __record_source
    FROM {{ a['alias'] }}_rows AS r
    QUALIFY ROW_NUMBER() OVER (PARTITION BY {{ ns_g.r | join(', ') }} ORDER BY r.__member, r.__rid) = 1
),
{%- endfor %}
{#-- Every grain value any alias holds. All aliases read only the changed keys, so this is the
     changed keys (and, with child_keys, all children of each changed parent). --#}
all_keys AS (
    {%- for a in ns.aliases %}
    SELECT {{ ns_g.plain | join(', ') }} FROM {{ a['alias'] }}
    {%- if not loop.last %}
    UNION
    {%- endif %}
    {%- endfor %}
),
final AS (
    SELECT
        {%- for g in ns_g.plain %}
        ak.{{ g }} AS {{ g }},
        {%- endfor %}
        {%- for col in output_columns %}
        {% if coalesce_rules[col] | length == 1 %}{{ coalesce_rules[col][0] }}.{{ col }}{% else %}COALESCE({% for alias in coalesce_rules[col] %}{{ alias }}.{{ col }}{% if not loop.last %}, {% endif %}{% endfor %}){% endif %} AS {{ col }},
        {%- endfor %}
        {%- if ns.aliases | length == 1 %}
        {{ ns.aliases[0]['alias'] }}.__record_source AS record_source,
        MAX({{ ns.aliases[0]['alias'] }}.__ldts_max) OVER (PARTITION BY ak.{{ unique_key }}) AS inc_job_updated_at
        {%- else %}
        ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT({% for a in ns.aliases %}{{ a['alias'] }}.__record_source{% if not loop.last %}, {% endif %}{% endfor %}), ', ') AS record_source,
        MAX(GREATEST_IGNORE_NULLS({% for a in ns.aliases %}{{ a['alias'] }}.__ldts_max{% if not loop.last %}, {% endif %}{% endfor %})) OVER (PARTITION BY ak.{{ unique_key }}) AS inc_job_updated_at
        {%- endif %}
    FROM all_keys ak
    {%- for a in ns.aliases %}
    LEFT JOIN {{ a['alias'] }}
        ON {{ a['alias'] }}.{{ unique_key }} = ak.{{ unique_key }}
        {%- for ck in child_keys %}
       AND EQUAL_NULL({{ a['alias'] }}.{{ ck }}, ak.{{ ck }})
        {%- endfor %}
    {%- endfor %}
)

SELECT
    {%- for g in ns_g.plain %}
    {{ g }},
    {%- endfor %}
    {%- for col in output_columns %}
    {{ col }},
    {%- endfor %}
    record_source,
    inc_job_updated_at
FROM final

{% endmacro %}
