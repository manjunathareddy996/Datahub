-- Intermediate harmonisation view for LNK_PRODUCT_COVERAGE (Product Coverage).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        hcp_seqno as coverage_bk,
        product_code as product_bk,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where hcp_seqno is not null and product_code is not null

    union all

    select distinct
        cover_code as coverage_bk,
        product_4digit_code as product_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where cover_code is not null and product_4digit_code is not null

    union all

    select distinct
        cover_code as coverage_bk,
        product_code as product_bk,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where cover_code is not null and product_code is not null

)

select distinct coverage_bk, product_bk, record_source
from unioned
