-- Intermediate harmonisation view for HUB_QUOTE.
-- Unions the HUB_QUOTE business key from every Health source table/column carrying it. (2 of 14 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_quote.sql.

with unioned as (

    select distinct
        quote_ref as business_key,
        'BJAZ_ECARD_MEMBR_DEL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ecard_membr_del_dtls') }}
    where quote_ref is not null

    union all

    select distinct
        quote_ref as business_key,
        'BJAZ_ECARD_POL_DTLS_CONFIG' as record_source
    from {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
    where quote_ref is not null

    union all

    select distinct
        quote_sub_no as business_key,
        'BJAZ_GRP_HLT_CUST_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_cust_dtls') }}
    where quote_sub_no is not null

    union all

    select distinct
        quote_no as business_key,
        'BJAZ_GRP_HLT_CUST_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_cust_dtls') }}
    where quote_no is not null

    union all

    select distinct
        quote_sub_no as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where quote_sub_no is not null

    union all

    select distinct
        quote_no as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where quote_no is not null

    union all

    select distinct
        quote_ref_no as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where quote_ref_no is not null

    union all

    select distinct
        quote_sub_no as business_key,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where quote_sub_no is not null

    union all

    select distinct
        quote_no as business_key,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where quote_no is not null

    union all

    select distinct
        quote_sub_no as business_key,
        'BJAZ_GRP_HLT_MATERNITY_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
    where quote_sub_no is not null

    union all

    select distinct
        quote_no as business_key,
        'BJAZ_GRP_HLT_MATERNITY_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
    where quote_no is not null

    union all

    select distinct
        quote_ref_no as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where quote_ref_no is not null

    union all

    -- DISCOVERED
    select distinct
        quote_ref_no as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where quote_ref_no is not null

    union all

    -- DISCOVERED
    select distinct
        quote_no as business_key,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where quote_no is not null

)

select distinct business_key, record_source
from unioned
