{{ config(materialized='view') }}

-- UNPIVOT for SAT_LNK_PARTY_ROLE_CORE from BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
-- 9 row(s), ONE PER INSTANCE of ROLECODE + ROLESEQUENCE.
-- The instance label is the mapper's own child_key_value, which keeps this in the
-- vocabulary partner_dv_dbt already writes.

    select
        bagic_employee_code as parent_bk,
        'DFADVOCATE#1' as rolecode,
        '1' as rolesequence,
        cast(null as varchar) as roleenddate,
        date_of_joiningdfadvocate as rolestartdate,
        cast(null as varchar) as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joiningdfadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'HCADVOCATE#1' as rolecode,
        '1' as rolesequence,
        cast(null as varchar) as roleenddate,
        date_of_joininghcadvocate as rolestartdate,
        cast(null as varchar) as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joininghcadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LAWYER#1' as rolecode,
        '1' as rolesequence,
        cast(null as varchar) as roleenddate,
        date_of_joininglawyer as rolestartdate,
        cast(null as varchar) as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joininglawyer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'RETAINER#1' as rolecode,
        '1' as rolesequence,
        cast(null as varchar) as roleenddate,
        date_of_joiningretainer as rolestartdate,
        cast(null as varchar) as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joiningretainer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'STADVOCATE#1' as rolecode,
        '1' as rolesequence,
        cast(null as varchar) as roleenddate,
        date_of_joiningstadvocate as rolestartdate,
        cast(null as varchar) as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joiningstadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'TRADVOCATE#1' as rolecode,
        '1' as rolesequence,
        cast(null as varchar) as roleenddate,
        date_of_joiningtradvocate as rolestartdate,
        cast(null as varchar) as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joiningtradvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        '{COALESCE(PARTY_FUNCTION,DEFAULT_ROLE)}#1' as rolecode,
        '1' as rolesequence,
        cancel_on as roleenddate,
        date_of_start as rolestartdate,
        intermediary_type as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_start)), '') is not null or nullif(trim(to_varchar(cancel_on)), '') is not null or nullif(trim(to_varchar(intermediary_type)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        default_role as rolecode,
        '1' as rolesequence,
        cast(null as varchar) as roleenddate,
        cast(null as varchar) as rolestartdate,
        cast(null as varchar) as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(default_role)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        party_function as rolecode,
        '1' as rolesequence,
        cast(null as varchar) as roleenddate,
        cast(null as varchar) as rolestartdate,
        cast(null as varchar) as roletype,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(party_function)), '') is not null
