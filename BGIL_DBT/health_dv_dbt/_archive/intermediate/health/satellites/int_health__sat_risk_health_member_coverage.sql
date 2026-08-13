-- Intermediate harmonisation view for SAT_RISK_HEALTH_MEMBER_COVERAGE (HUB_RISK_OBJECT grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 2 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, member_reference_ck, corporate_buffer_amount, cumulative_bonus_amount, cumulative_bonus_percentage, loading_reason, member_sum_insured, pre_policy_checkup_indicator, record_source from (
    select distinct
        contract_id || '|' || member_no as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as corporate_buffer_amount,
        cast(null as varchar) as cumulative_bonus_amount,
        cast(null as varchar) as cumulative_bonus_percentage,
        cast(null as varchar) as loading_reason,
        nullif(trim(to_varchar(sum_insured)), '') as member_sum_insured,
        nullif(trim(to_varchar(medical_checkup)), '') as pre_policy_checkup_indicator,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where contract_id is not null and member_no is not null
    )

union all

select parent_bk, member_reference_ck, corporate_buffer_amount, cumulative_bonus_amount, cumulative_bonus_percentage, loading_reason, member_sum_insured, pre_policy_checkup_indicator, record_source from (
    select distinct
        contract_id || '|' || member_no as parent_bk,
        cast(null as varchar) as member_reference_ck,
        cast(null as varchar) as corporate_buffer_amount,
        nullif(trim(to_varchar(cumulative_amt)), '') as cumulative_bonus_amount,
        nullif(trim(to_varchar(cumulative_bnouz_per)), '') as cumulative_bonus_percentage,
        nullif(trim(to_varchar(loading_reason)), '') as loading_reason,
        nullif(trim(to_varchar(sum_insured)), '') as member_sum_insured,
        cast(null as varchar) as pre_policy_checkup_indicator,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where contract_id is not null and member_no is not null
    )

)
