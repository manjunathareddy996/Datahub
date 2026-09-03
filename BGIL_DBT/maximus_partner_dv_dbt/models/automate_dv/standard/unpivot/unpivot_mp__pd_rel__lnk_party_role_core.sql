{{ config(materialized='view') }}

-- UNPIVOT for SAT_LNK_PARTY_ROLE_CORE from BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION
-- 1 row(s), ONE PER INSTANCE of ROLECODE + ROLESEQUENCE.
-- The instance label is the mapper's own child_key_value, which keeps this in the
-- vocabulary partner_dv_dbt already writes.

    select
        foreign_key as parent_bk,
        stake_name as rolecode,
        '1' as rolesequence,
        cast(null as varchar) as roleenddate,
        start_date as rolestartdate,
        cast(null as varchar) as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION' as record_source
    from {{ ref('stg_maximus__pd_rel') }}
    where nullif(trim(to_varchar(stake_name)), '') is not null or nullif(trim(to_varchar(start_date)), '') is not null
