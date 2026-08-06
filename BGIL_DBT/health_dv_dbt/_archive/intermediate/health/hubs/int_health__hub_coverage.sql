-- Intermediate harmonisation view for HUB_COVERAGE.
-- Unions the HUB_COVERAGE business key from every Health source table/column carrying it. (5 of 8 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_coverage.sql.

with unioned as (

    -- DISCOVERED
    select distinct
        hcp_seqno as business_key,
        'BA_HCP_DT_MEM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem') }}
    where hcp_seqno is not null

    union all

    select distinct
        hcp_seqno as business_key,
        'BA_HCP_DT_MEM_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
    where hcp_seqno is not null

    union all

    -- DISCOVERED
    select distinct
        hcp_seqno as business_key,
        'BA_HCP_DT_POL_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
    where hcp_seqno is not null

    union all

    -- DISCOVERED
    select distinct
        hcp_seqno as business_key,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where hcp_seqno is not null

    union all

    select distinct
        cover_code as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where cover_code is not null

    union all

    select distinct
        cover_section as business_key,
        'BJAZ_HM_DOCTOR_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
    where cover_section is not null

    union all

    -- DISCOVERED
    select distinct
        cover_section as business_key,
        'BJAZ_HM_DOC_RECOVERY' as record_source
    from {{ ref('stg_health__bjaz_hm_doc_recovery') }}
    where cover_section is not null

    union all

    -- DISCOVERED
    select distinct
        cover_code as business_key,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where cover_code is not null

)

select distinct business_key, record_source
from unioned
