{{ config(materialized='view') }}

-- UNPIVOT for SAT_LNK_PARTY_ROLE_CORE from BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- 9 row(s), ONE PER INSTANCE of ROLECODE + ROLESEQUENCE.
-- The instance label is the mapper's own child_key_value, which keeps this in the
-- vocabulary partner_dv_dbt already writes.

    select
        bagic_employee_code as parent_bk,
        'DFADVOCATE#1' as role_code,
        '1' as role_sequence,
        cast(null as varchar) as role_end_date,
        date_of_joiningdfadvocate as role_start_date,
        cast(null as varchar) as role_type,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joiningdfadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'HCADVOCATE#1' as role_code,
        '1' as role_sequence,
        cast(null as varchar) as role_end_date,
        date_of_joininghcadvocate as role_start_date,
        cast(null as varchar) as role_type,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joininghcadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LAWYER#1' as role_code,
        '1' as role_sequence,
        cast(null as varchar) as role_end_date,
        date_of_joininglawyer as role_start_date,
        cast(null as varchar) as role_type,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joininglawyer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'RETAINER#1' as role_code,
        '1' as role_sequence,
        cast(null as varchar) as role_end_date,
        date_of_joiningretainer as role_start_date,
        cast(null as varchar) as role_type,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joiningretainer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'STADVOCATE#1' as role_code,
        '1' as role_sequence,
        cast(null as varchar) as role_end_date,
        date_of_joiningstadvocate as role_start_date,
        cast(null as varchar) as role_type,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joiningstadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'TRADVOCATE#1' as role_code,
        '1' as role_sequence,
        cast(null as varchar) as role_end_date,
        date_of_joiningtradvocate as role_start_date,
        cast(null as varchar) as role_type,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_joiningtradvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        '{COALESCE(PARTY_FUNCTION,DEFAULT_ROLE)}#1' as role_code,
        '1' as role_sequence,
        cancel_on as role_end_date,
        date_of_start as role_start_date,
        intermediary_type as role_type,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_start)), '') is not null or nullif(trim(to_varchar(cancel_on)), '') is not null or nullif(trim(to_varchar(intermediary_type)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        default_role as role_code,
        '1' as role_sequence,
        cast(null as varchar) as role_end_date,
        cast(null as varchar) as role_start_date,
        cast(null as varchar) as role_type,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(default_role)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        party_function as role_code,
        '1' as role_sequence,
        cast(null as varchar) as role_end_date,
        cast(null as varchar) as role_start_date,
        cast(null as varchar) as role_type,
        rec_refresh_at as rec_refresh_at,
        'MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(party_function)), '') is not null
