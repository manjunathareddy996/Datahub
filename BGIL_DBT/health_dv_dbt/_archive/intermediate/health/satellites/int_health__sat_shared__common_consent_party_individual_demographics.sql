-- SHARED intermediate view for SAT_COMMON_CONSENT, SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS -- identical (parent hub, grain, contributing tables); built once.
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 4 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, consent_given_indicator, marital_status, occupation_description, record_source
from (
    with t0 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(pd_customer_consent)), '') as consent_given_indicator
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by consent_given_indicator) = 1
    ),
         t1 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(pd_customer_consent)), '') as consent_given_indicator
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by consent_given_indicator) = 1
    ),
         t2 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(pd_customer_consent)), '') as consent_given_indicator
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by consent_given_indicator) = 1
    ),
         t3 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(pd_customer_consent)), '') as consent_given_indicator
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by consent_given_indicator) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        coalesce(t0.consent_given_indicator, t1.consent_given_indicator, t2.consent_given_indicator, t3.consent_given_indicator) as consent_given_indicator,
        cast(null as varchar) as marital_status,
        cast(null as varchar) as occupation_description,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t2.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t3.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    )
