-- Intermediate harmonisation view for SAT_POLICY_DISCOUNT_LOADING_APPLIED (HUB_POLICY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 3 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, item_code_ck, amount_applied, percentage_applied, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as item_code_ck,
        nullif(trim(to_varchar(family_disc_amt)), '') as amount_applied,
        nullif(trim(to_varchar(family_disc_rate)), '') as percentage_applied,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where contract_id is not null
    )

union all

select parent_bk, item_code_ck, amount_applied, percentage_applied, record_source from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as item_code_ck,
        nullif(trim(to_varchar(cto_ceo_discount)), '') as amount_applied,
        cast(null as varchar) as percentage_applied,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where contract_id is not null
    )

union all

select parent_bk, item_code_ck, amount_applied, percentage_applied, record_source from (
    select distinct
        policy_ref as parent_bk,
        cast(null as varchar) as item_code_ck,
        nullif(trim(to_varchar(other_discount)), '') as amount_applied,
        nullif(trim(to_varchar(commercial_discount_per)), '') as percentage_applied,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where policy_ref is not null
    )

)
