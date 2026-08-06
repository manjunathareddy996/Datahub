-- Intermediate harmonisation view for SAT_RISK_PERSON_INSURED (HUB_RISK_OBJECT grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 5 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, age_at_entry, body_mass_index, critical_illness_cover_indicator, cumulative_bonus_applicable_indicator, floater_indicator, health_card_number, height, insured_member_name, insured_member_reference, member_risk_loading_percentage, member_type, occupation_risk_class, policy_holder_relationship, pre_existing_disease_description, relationship_to_proposer, smoker_indicator, weight, record_source
from (
    with t0 as (
        select distinct
            pol_serial_no || '|' || md_seq_no as parent_bk,
            nullif(trim(to_varchar(md_height_cm)), '') as height,
            nullif(trim(to_varchar(md_pre_exist_disease_dis_inf)), '') as pre_existing_disease_description,
            nullif(trim(to_varchar(md_weight_kg)), '') as weight
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pol_serial_no is not null and md_seq_no is not null
        qualify row_number() over (partition by parent_bk order by height, pre_existing_disease_description, weight) = 1
    ),
         t1 as (
        select distinct
            pol_serial_no || '|' || md_seq_no as parent_bk,
            nullif(trim(to_varchar(md_bmi)), '') as body_mass_index,
            nullif(trim(to_varchar(md_height_cm)), '') as height,
            nullif(trim(to_varchar(md_pre_exist_disease_dis_inf)), '') as pre_existing_disease_description,
            nullif(trim(to_varchar(md_smoker_tobacco_chewer)), '') as smoker_indicator,
            nullif(trim(to_varchar(md_weight_kg)), '') as weight
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pol_serial_no is not null and md_seq_no is not null
        qualify row_number() over (partition by parent_bk order by body_mass_index, height, pre_existing_disease_description, smoker_indicator, weight) = 1
    ),
         t2 as (
        select distinct
            contract_id || '|' || member_ref_number as parent_bk,
            nullif(trim(to_varchar(family_flagging)), '') as floater_indicator,
            nullif(trim(to_varchar(member_ref_number)), '') as insured_member_reference,
            nullif(trim(to_varchar(relation)), '') as relationship_to_proposer
        from {{ ref('stg_health__bjaz_ctngy_pa_mem_dtls') }}
        where contract_id is not null and member_ref_number is not null
        qualify row_number() over (partition by parent_bk order by floater_indicator, insured_member_reference, relationship_to_proposer) = 1
    ),
         t3 as (
        select distinct
            contract_id || '|' || member_no as parent_bk,
            nullif(trim(to_varchar(height_cm)), '') as height,
            nullif(trim(to_varchar(disease_dtls)), '') as pre_existing_disease_description,
            nullif(trim(to_varchar(relation)), '') as relationship_to_proposer,
            nullif(trim(to_varchar(smoker_yn)), '') as smoker_indicator,
            nullif(trim(to_varchar(weight_kg)), '') as weight
        from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
        where contract_id is not null and member_no is not null
        qualify row_number() over (partition by parent_bk order by height, pre_existing_disease_description, relationship_to_proposer, smoker_indicator, weight) = 1
    ),
         t4 as (
        select distinct
            contract_id || '|' || member_no as parent_bk,
            nullif(trim(to_varchar(load_per)), '') as member_risk_loading_percentage,
            nullif(trim(to_varchar(relation)), '') as relationship_to_proposer,
            nullif(trim(to_varchar(smoker_flag)), '') as smoker_indicator
        from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
        where contract_id is not null and member_no is not null
        qualify row_number() over (partition by parent_bk order by member_risk_loading_percentage, relationship_to_proposer, smoker_indicator) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk) as parent_bk,
        cast(null as varchar) as age_at_entry,
        coalesce(t1.body_mass_index) as body_mass_index,
        cast(null as varchar) as critical_illness_cover_indicator,
        cast(null as varchar) as cumulative_bonus_applicable_indicator,
        coalesce(t2.floater_indicator) as floater_indicator,
        cast(null as varchar) as health_card_number,
        coalesce(t0.height, t1.height, t3.height) as height,
        cast(null as varchar) as insured_member_name,
        coalesce(t2.insured_member_reference) as insured_member_reference,
        coalesce(t4.member_risk_loading_percentage) as member_risk_loading_percentage,
        cast(null as varchar) as member_type,
        cast(null as varchar) as occupation_risk_class,
        cast(null as varchar) as policy_holder_relationship,
        coalesce(t0.pre_existing_disease_description, t1.pre_existing_disease_description, t3.pre_existing_disease_description) as pre_existing_disease_description,
        coalesce(t2.relationship_to_proposer, t3.relationship_to_proposer, t4.relationship_to_proposer) as relationship_to_proposer,
        coalesce(t1.smoker_indicator, t3.smoker_indicator, t4.smoker_indicator) as smoker_indicator,
        coalesce(t0.weight, t1.weight, t3.weight) as weight,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t2.parent_bk is not null then 'BJAZ_CTNGY_PA_MEM_DTLS' end, case when t3.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t4.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    )
