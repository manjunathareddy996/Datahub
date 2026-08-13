-- Intermediate harmonisation view for LNK_QUOTE_PRODUCT (Quote Product).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        product as product_bk,
        quote_sub_no as quote_bk,
        'BJAZ_GRP_HLT_CUST_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_cust_dtls') }}
    where product is not null and quote_sub_no is not null

    union all

    select distinct
        product as product_bk,
        quote_sub_no as quote_bk,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where product is not null and quote_sub_no is not null

    union all

    select distinct
        product as product_bk,
        quote_sub_no as quote_bk,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where product is not null and quote_sub_no is not null

    union all

    select distinct
        product as product_bk,
        quote_sub_no as quote_bk,
        'BJAZ_GRP_HLT_MATERNITY_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
    where product is not null and quote_sub_no is not null

    union all

    select distinct
        product_4digit_code as product_bk,
        quote_ref_no as quote_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where product_4digit_code is not null and quote_ref_no is not null

    union all

    select distinct
        product_4digit_code as product_bk,
        quote_ref_no as quote_bk,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where product_4digit_code is not null and quote_ref_no is not null

    union all

    select distinct
        product_code as product_bk,
        quote_no as quote_bk,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where product_code is not null and quote_no is not null

)

select distinct product_bk, quote_bk, record_source
from unioned
