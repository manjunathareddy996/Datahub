{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_ACCOUNT_DEFINITION (HUB_FINANCIAL_ACCOUNT grain).
-- Attribute-level merge across 2 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_account_definition.sql stage() model.

select parent_bk, account_category, account_type, closing_date, record_source
from (
    with t0 as (
        select distinct
            mlac_emi_pc_loan_account_no as parent_bk,
            nullif(trim(to_varchar(mlac_emi_pc_type_of_loan)), '') as account_type
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where mlac_emi_pc_loan_account_no is not null
        qualify row_number() over (partition by parent_bk order by account_type) = 1
    ),
         t1 as (
        select distinct
            plc_loan_acc_no as parent_bk,
            nullif(trim(to_varchar(plc_oth_type_of_loan)), '') as account_category,
            nullif(trim(to_varchar(plc_type_of_loan)), '') as account_type,
            nullif(trim(to_varchar(plc_loan_end_date)), '') as closing_date
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where plc_loan_acc_no is not null
        qualify row_number() over (partition by parent_bk order by account_category, account_type, closing_date) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        coalesce(t1.account_category) as account_category,
        coalesce(t0.account_type, t1.account_type) as account_type,
        coalesce(t1.closing_date) as closing_date,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    )
