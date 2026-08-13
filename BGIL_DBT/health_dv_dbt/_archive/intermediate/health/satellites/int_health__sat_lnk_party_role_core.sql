-- Intermediate harmonisation view for SAT_LNK_PARTY_ROLE_CORE (HUB_PARTY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 4 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, role_code_ck, role_sequence_ck, role_category, role_type, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as role_code_ck,
        cast(null as varchar) as role_sequence_ck,
        cast(null as varchar) as role_category,
        nullif(trim(to_varchar(md_is_proposer_yes_no)), '') as role_type,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, role_code_ck, role_sequence_ck, role_category, role_type, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as role_code_ck,
        cast(null as varchar) as role_sequence_ck,
        cast(null as varchar) as role_category,
        nullif(trim(to_varchar(md_is_proposer_yes_no)), '') as role_type,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, role_code_ck, role_sequence_ck, role_category, role_type, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as role_code_ck,
        cast(null as varchar) as role_sequence_ck,
        cast(null as varchar) as role_category,
        nullif(trim(to_varchar(md_is_proposer_yes_no)), '') as role_type,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_premium_payer_id is not null
    )

union all

select parent_bk, role_code_ck, role_sequence_ck, role_category, role_type, record_source from (
    select distinct
        pd_premium_payer_id as parent_bk,
        cast(null as varchar) as role_code_ck,
        cast(null as varchar) as role_sequence_ck,
        nullif(trim(to_varchar(plc_borrower_type)), '') as role_category,
        nullif(trim(to_varchar(md_is_proposer_yes_no)), '') as role_type,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_premium_payer_id is not null
    )

)
