{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_PARTY_HEALTH_PROFILE (HUB_PARTY grain).
-- Attribute-level merge across 11 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_party_health_profile.sql stage() model.

select parent_bk, blood_group, body_mass_index, chronic_illness_indicator, family_medical_history_indicator, height, pre_existing_disease_description, tobacco_consumption_detail, weight, record_source
from (
    with t0 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_pre_exi_dis_dis_inf)), '') as pre_existing_disease_description
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by pre_existing_disease_description) = 1
    ),
         t1 as (
        select distinct
            bdr_code as parent_bk,
            nullif(trim(to_varchar(height)), '') as height,
            nullif(trim(to_varchar(weight)), '') as weight
        from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
        where bdr_code is not null
        qualify row_number() over (partition by parent_bk order by height, weight) = 1
    ),
         t2 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(smoke_consump)), '') as tobacco_consumption_detail
        from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by tobacco_consumption_detail) = 1
    ),
         t3 as (
        select distinct
            bdr_code as parent_bk,
            nullif(trim(to_varchar(height)), '') as height,
            nullif(trim(to_varchar(weight)), '') as weight
        from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
        where bdr_code is not null
        qualify row_number() over (partition by parent_bk order by height, weight) = 1
    ),
         t4 as (
        select distinct
            bdr_code as parent_bk,
            nullif(trim(to_varchar(height)), '') as height,
            nullif(trim(to_varchar(weight)), '') as weight
        from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
        where bdr_code is not null
        qualify row_number() over (partition by parent_bk order by height, weight) = 1
    ),
         t5 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(family_hist)), '') as family_medical_history_indicator
        from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by family_medical_history_indicator) = 1
    ),
         t6 as (
        select distinct
            bdr_code as parent_bk,
            nullif(trim(to_varchar(height)), '') as height,
            nullif(trim(to_varchar(weight)), '') as weight
        from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
        where bdr_code is not null
        qualify row_number() over (partition by parent_bk order by height, weight) = 1
    ),
         t7 as (
        select distinct
            bdr_code as parent_bk,
            nullif(trim(to_varchar(height)), '') as height,
            nullif(trim(to_varchar(weight)), '') as weight
        from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
        where bdr_code is not null
        qualify row_number() over (partition by parent_bk order by height, weight) = 1
    ),
         t8 as (
        select distinct
            bdr_code as parent_bk,
            nullif(trim(to_varchar(height)), '') as height,
            nullif(trim(to_varchar(weight)), '') as weight
        from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
        where bdr_code is not null
        qualify row_number() over (partition by parent_bk order by height, weight) = 1
    ),
         t9 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(bmi)), '') as body_mass_index,
            nullif(trim(to_varchar(height_feet)), '') as height,
            nullif(trim(to_varchar(weight)), '') as weight
        from {{ ref('stg_health__bjaz_spp_member_dtls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by body_mass_index, height, weight) = 1
    ),
         t10 as (
        select distinct
            customer_id as parent_bk,
            nullif(trim(to_varchar(height_cm)), '') as height,
            nullif(trim(to_varchar(weight_kg)), '') as weight
        from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
        where customer_id is not null
        qualify row_number() over (partition by parent_bk order by height, weight) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk, t10.parent_bk) as parent_bk,
        cast(null as varchar) as blood_group,
        coalesce(t9.body_mass_index) as body_mass_index,
        cast(null as varchar) as chronic_illness_indicator,
        coalesce(t5.family_medical_history_indicator) as family_medical_history_indicator,
        coalesce(t1.height, t3.height, t4.height, t6.height, t7.height, t8.height, t9.height, t10.height) as height,
        coalesce(t0.pre_existing_disease_description) as pre_existing_disease_description,
        coalesce(t2.tobacco_consumption_detail) as tobacco_consumption_detail,
        coalesce(t1.weight, t3.weight, t4.weight, t6.weight, t7.weight, t8.weight, t9.weight, t10.weight) as weight,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t1.parent_bk is not null then 'BJAZ_ADLD_PREM_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t3.parent_bk is not null then 'BJAZ_FLEXI_CYBER_DATA' end, case when t4.parent_bk is not null then 'BJAZ_GG_PREM_DTLS' end, case when t5.parent_bk is not null then 'BJAZ_HAT_ID_MEM_DETLS' end, case when t6.parent_bk is not null then 'BJAZ_HDFC_FLEXIPA' end, case when t7.parent_bk is not null then 'BJAZ_PNB_GPA_DATA' end, case when t8.parent_bk is not null then 'BJAZ_RR_PREM_DTLS' end, case when t9.parent_bk is not null then 'BJAZ_SPP_MEMBER_DTLS' end, case when t10.parent_bk is not null then 'BJAZ_SUPER_SURAKSHA_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    full outer join t7 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk) = t7.parent_bk
    full outer join t8 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk) = t8.parent_bk
    full outer join t9 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk) = t9.parent_bk
    full outer join t10 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk) = t10.parent_bk
    )
