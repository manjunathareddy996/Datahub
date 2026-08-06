-- Intermediate harmonisation view for LNK_PRODUCT_VARIANT (Product Variant).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        product_code as product_from_bk,
        plan_id as product_to_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where product_code is not null and plan_id is not null

    union all

    select distinct
        schemecode as product_from_bk,
        planid as product_to_bk,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where schemecode is not null and planid is not null

    union all

    select distinct
        plan_id as product_from_bk,
        product_code as product_to_bk,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where plan_id is not null and product_code is not null

)

select distinct product_from_bk, product_to_bk, record_source
from unioned
