-- Intermediate harmonisation view for LNK_QUOTE_PARTY (Quote Party).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        emp_code as party_bk,
        quote_ref as quote_bk,
        'BJAZ_ECARD_MEMBR_DEL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ecard_membr_del_dtls') }}
    where emp_code is not null and quote_ref is not null

    union all

    select distinct
        rm_code as party_bk,
        quote_sub_no as quote_bk,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where rm_code is not null and quote_sub_no is not null

    union all

    select distinct
        part_id as party_bk,
        quote_ref_no as quote_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where part_id is not null and quote_ref_no is not null

    union all

    select distinct
        emp_code as party_bk,
        quote_ref_no as quote_bk,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where emp_code is not null and quote_ref_no is not null

    union all

    select distinct
        user_id as party_bk,
        quote_no as quote_bk,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where user_id is not null and quote_no is not null

)

select distinct party_bk, quote_bk, record_source
from unioned
