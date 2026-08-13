-- Intermediate harmonisation view for SAT_POLICY_INSTALMENT_SCHEDULE (HUB_POLICY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 1 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, instalment_number_ck, due_date, instalment_amount, outstanding_after_instalment, paid_amount, record_source
from (
    select distinct
        contract_id as parent_bk,
        cast(null as varchar) as instalment_number_ck,
        nullif(trim(to_varchar(inst_date)), '') as due_date,
        nullif(trim(to_varchar(next_inst_amt)), '') as instalment_amount,
        nullif(trim(to_varchar(inst_total_pending_amt)), '') as outstanding_after_instalment,
        nullif(trim(to_varchar(inst_paid_amt)), '') as paid_amount,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where contract_id is not null
    )
