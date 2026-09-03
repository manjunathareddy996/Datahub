{{ config(materialized='view') }}

-- UNPIVOT for SAT_PARTY_DIGITAL_IDENTITY from BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
-- 5 row(s), ONE PER INSTANCE of ACTIVESEQUENCENUMBER.
-- The instance label is the mapper's own child_key_value, which keeps this in the
-- vocabulary partner_dv_dbt already writes.

    select
        bagic_employee_code as parent_bk,
        'PORTAL_LOGIN' as activesequencenumber,
        login_id as loginidentifier,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(login_id)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'REPAIRER_PORTAL' as activesequencenumber,
        repairer_portal_id as loginidentifier,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(repairer_portal_id)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'SURVEYOR_MODULE' as activesequencenumber,
        sur_module_login_id as loginidentifier,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(sur_module_login_id)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'USER_CODE' as activesequencenumber,
        user_code as loginidentifier,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(user_code)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'WEB_PORTAL' as activesequencenumber,
        user_web_id as loginidentifier,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(user_web_id)), '') is not null
