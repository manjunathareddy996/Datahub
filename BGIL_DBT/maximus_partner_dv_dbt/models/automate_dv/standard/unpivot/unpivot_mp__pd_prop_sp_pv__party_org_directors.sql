{{ config(materialized='view') }}

-- UNPIVOT for SAT_PARTY_ORG_DIRECTORS from BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
-- 9 row(s), ONE PER INSTANCE of PERSONROLE.
-- The instance label is the mapper's own child_key_value, which keeps this in the
-- vocabulary partner_dv_dbt already writes.

    select
        bagic_employee_code as parent_bk,
        'AUTHORISED_SIGNATORY' as personrole,
        cast(null as varchar) as cessationdate,
        authorized_signature as directorname,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(authorized_signature)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'EMPLOYEE' as personrole,
        cast(null as varchar) as cessationdate,
        name_of_the_employee as directorname,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(name_of_the_employee)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'HEAD_FRAUD_PREVENTION_LOSS_MITIGATION' as personrole,
        cast(null as varchar) as cessationdate,
        name_of_the_head_fraud_prevention_and_loss_mitigation as directorname,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(name_of_the_head_fraud_prevention_and_loss_mitigation)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'INVESTIGATION_OFFICER' as personrole,
        cast(null as varchar) as cessationdate,
        name_of_the_investigation_officer as directorname,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(name_of_the_investigation_officer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'MARKETING_HEAD' as personrole,
        cast(null as varchar) as cessationdate,
        marketing_head_name as directorname,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(marketing_head_name)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'MEDICAL_DIRECTOR' as personrole,
        cast(null as varchar) as cessationdate,
        medical_director_name as directorname,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(medical_director_name)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'MEDICAL_SUPERINTENDENT' as personrole,
        cast(null as varchar) as cessationdate,
        medical_superintendent_name as directorname,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(medical_superintendent_name)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'OWNER' as personrole,
        cast(null as varchar) as cessationdate,
        owners_full_name as directorname,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(owners_full_name)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        type_of_principal as personrole,
        date_of_acceptance_of_resignation as cessationdate,
        cast(null as varchar) as directorname,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(date_of_acceptance_of_resignation)), '') is not null or nullif(trim(to_varchar(type_of_principal)), '') is not null
