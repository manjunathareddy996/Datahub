{{ config(materialized='view') }}

-- Incremental stitch for SAT_COMMON_CLASSIFICATION (HUB_PARTY grain).
-- affected_keys = changed keys in the window (inc_job_updated_at between from_date and to_date).
-- Sources are LEFT JOINed onto affected_keys (the driver) - no per-source IN filter and no per-source
-- QUALIFY. A single final QUALIFY dedups to one row per parent_bk.
--
-- Window resolution (all IST):
--   to_date   = var('to_date', run_started_at + 5:30)
--   from_date = var('from_date') | MAX(DBT_RUN_TS) from the sat | '1900-01-01' (first run = full load)

{%- set target_sat = 'sat_common_classification_incr' -%}

{#-- to_date: var override or run_started_at shifted UTC->IST --#}
{%- set td = var('to_date', (run_started_at + modules.datetime.timedelta(hours=5, minutes=30)).strftime('%Y-%m-%d %H:%M:%S')) -%}
{%- set to_date = "'" ~ td ~ "'" -%}

{#-- from_date: var override -> MAX(DBT_RUN_TS) from sat -> sentinel --#}
{%- set sentinel = '1900-01-01' -%}
{%- if var('from_date', none) is not none -%}
    {%- set from_date = "'" ~ var('from_date') ~ "'" -%}
{%- elif not execute -%}
    {%- set from_date = "'" ~ sentinel ~ "'" -%}
{%- else -%}
    {%- set sat_rel = adapter.get_relation(database=this.database, schema=this.schema, identifier=target_sat) -%}
    {%- if sat_rel is none -%}
        {%- set from_date = "'" ~ sentinel ~ "'" -%}
    {%- else -%}
        {%- set results = run_query("SELECT COALESCE(MAX(DBT_RUN_TS), TO_TIMESTAMP_NTZ('" ~ sentinel ~ "')) FROM " ~ sat_rel) -%}
        {%- if results and (results.rows | length) > 0 and results.rows[0][0] is not none -%}
            {%- set from_date = "'" ~ results.rows[0][0] ~ "'" -%}
        {%- else -%}
            {%- set from_date = "'" ~ sentinel ~ "'" -%}
        {%- endif -%}
    {%- endif -%}
{%- endif -%}

{%- set db = this.database -%}
{%- set sc = this.schema -%}

with affected_keys as (

    select distinct part_id as parent_bk
    from {{ db }}.{{ sc }}.stg_partner__azbj_partner_extn
    where part_id is not null
      and inc_job_updated_at >  cast({{ from_date }} as timestamp_ntz)
      and inc_job_updated_at <= cast({{ to_date }}   as timestamp_ntz)

    union

    select distinct part_id
    from {{ db }}.{{ sc }}.stg_partner__bjaz_azbj_part_ext_hist
    where part_id is not null
      and inc_job_updated_at >  cast({{ from_date }} as timestamp_ntz)
      and inc_job_updated_at <= cast({{ to_date }}   as timestamp_ntz)

    union

    select distinct partner_id
    from {{ db }}.{{ sc }}.stg_partner__bjaz_hm_member_dtls
    where partner_id is not null
      and inc_job_updated_at >  cast({{ from_date }} as timestamp_ntz)
      and inc_job_updated_at <= cast({{ to_date }}   as timestamp_ntz)

    union

    select distinct intermediary_id
    from {{ db }}.{{ sc }}.stg_partner__bjaz_intermediary
    where intermediary_id is not null
      and inc_job_updated_at >  cast({{ from_date }} as timestamp_ntz)
      and inc_job_updated_at <= cast({{ to_date }}   as timestamp_ntz)

    union

    select distinct intermediary_id
    from {{ db }}.{{ sc }}.stg_partner__bjaz_intermediary_hist
    where intermediary_id is not null
      and inc_job_updated_at >  cast({{ from_date }} as timestamp_ntz)
      and inc_job_updated_at <= cast({{ to_date }}   as timestamp_ntz)
)

select
    ak.parent_bk,
    coalesce(
        nullif(trim(to_varchar(t0.vip_cust)), ''),
        nullif(trim(to_varchar(t1.vip_cust)), ''),
        nullif(trim(to_varchar(t2.vip_flg)),  '')
    ) as prioritycode,
    coalesce(
        nullif(trim(to_varchar(t0.ucic_flag)), ''),
        nullif(trim(to_varchar(t3.flagging)),  ''),
        nullif(trim(to_varchar(t4.flagging)),  '')
    ) as segmentcode,
    array_to_string(array_construct_compact(
        case when t0.part_id         is not null then 'AZBJ_PARTNER_EXTN'       end,
        case when t1.part_id         is not null then 'BJAZ_AZBJ_PART_EXT_HIST' end,
        case when t2.partner_id      is not null then 'BJAZ_HM_MEMBER_DTLS'     end,
        case when t3.intermediary_id is not null then 'BJAZ_INTERMEDIARY'       end,
        case when t4.intermediary_id is not null then 'BJAZ_INTERMEDIARY_HIST'  end
    ), ', ') as record_source
from affected_keys ak
left join {{ db }}.{{ sc }}.stg_partner__azbj_partner_extn       t0 on t0.part_id         = ak.parent_bk
left join {{ db }}.{{ sc }}.stg_partner__bjaz_azbj_part_ext_hist t1 on t1.part_id         = ak.parent_bk
left join {{ db }}.{{ sc }}.stg_partner__bjaz_hm_member_dtls     t2 on t2.partner_id      = ak.parent_bk
left join {{ db }}.{{ sc }}.stg_partner__bjaz_intermediary       t3 on t3.intermediary_id = ak.parent_bk
left join {{ db }}.{{ sc }}.stg_partner__bjaz_intermediary_hist  t4 on t4.intermediary_id = ak.parent_bk

-- history sources can have multiple rows per key; one final QUALIFY keeps a single row per parent_bk,
-- preferring rows that actually carry priority/segment values.
qualify row_number() over (
    partition by ak.parent_bk
    order by
        nullif(trim(to_varchar(t0.vip_cust)),  '') nulls last,
        nullif(trim(to_varchar(t0.ucic_flag)), '') nulls last,
        nullif(trim(to_varchar(t2.vip_flg)),   '') nulls last,
        nullif(trim(to_varchar(t3.flagging)),  '') nulls last,
        nullif(trim(to_varchar(t4.flagging)),  '') nulls last
) = 1
