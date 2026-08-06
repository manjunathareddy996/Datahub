{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_PRODUCT_TERMS (HUB_PRODUCT grain).
-- Attribute-level merge across 2 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_product_terms.sql stage() model.

select parent_bk, family_definition, record_source
from (
    with t0 as (
        select distinct
            product as parent_bk,
            nullif(trim(to_varchar(health_prime_rider_fam_def)), '') as family_definition
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where product is not null
        qualify row_number() over (partition by parent_bk order by family_definition) = 1
    ),
         t1 as (
        select distinct
            product as parent_bk,
            nullif(trim(to_varchar(family_definition)), '') as family_definition
        from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
        where product is not null
        qualify row_number() over (partition by parent_bk order by family_definition) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        coalesce(t0.family_definition, t1.family_definition) as family_definition,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_GRP_HLT_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_GRP_HLT_MATERNITY_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    )
