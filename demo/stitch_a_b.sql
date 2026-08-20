{{ config(materialized='view') }}

-- DEMO: Stitch view for SAT_A_B_STITCHED (grain: id / HUB_PARTY).
-- Merges TABLE_A (phone_1) and TABLE_B (phone_1, phone_2) into one row per key.
-- COALESCE priority: TABLE_A wins for phone_1, TABLE_B is sole source for phone_2.
-- updated_at = GREATEST across both sources (real business timestamp for LOAD_DATETIME).

with t0 as (
    select distinct
        id as parent_bk,
        phone_1,
        updated_at
    from {{ ref('stg_a') }}
    where id is not null
),
t1 as (
    select distinct
        id as parent_bk,
        phone_1,
        phone_2,
        updated_at
    from {{ ref('stg_b') }}
    where id is not null
)

select
    coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
    coalesce(t0.phone_1, t1.phone_1) as phone_1,
    t1.phone_2 as phone_2,
    greatest(
        coalesce(t0.updated_at, '1900-01-01'::timestamp_ntz),
        coalesce(t1.updated_at, '1900-01-01'::timestamp_ntz)
    ) as updated_at,
    array_to_string(array_construct_compact(
        case when t0.parent_bk is not null then 'TABLE_A' end,
        case when t1.parent_bk is not null then 'TABLE_B' end
    ), ', ') as record_source
from t0
full outer join t1 on t0.parent_bk = t1.parent_bk
