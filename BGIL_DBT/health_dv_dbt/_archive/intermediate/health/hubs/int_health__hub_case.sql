-- Intermediate harmonisation view for HUB_CASE.
-- Unions the HUB_CASE business key from every Health source table/column carrying it. (1 of 6 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_case.sql.

with unioned as (

    select distinct
        itrack_no as business_key,
        'BJAZ_HM_HAT_ITRACK_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_hat_itrack_dtls') }}
    where itrack_no is not null

    union all

    select distinct
        allocate_id as business_key,
        'BJAZ_HM_INWARD_AUTOALLOCATION' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_autoallocation') }}
    where allocate_id is not null

    union all

    select distinct
        enhance_ref_id as business_key,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where enhance_ref_id is not null

    union all

    select distinct
        query_ref_id as business_key,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where query_ref_id is not null

    union all

    select distinct
        request_no as business_key,
        'BJAZ_SCR_HLTH_PORTABLE_DTLS' as record_source
    from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
    where request_no is not null

    union all

    -- DISCOVERED
    select distinct
        itrack_no as business_key,
        'BJAZ_TRV_CLM_ITRACK_DTLS' as record_source
    from {{ ref('stg_health__bjaz_trv_clm_itrack_dtls') }}
    where itrack_no is not null

)

select distinct business_key, record_source
from unioned
