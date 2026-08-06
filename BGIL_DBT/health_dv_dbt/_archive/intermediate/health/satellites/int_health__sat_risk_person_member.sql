-- Intermediate harmonisation view for SAT_RISK_PERSON_MEMBER (HUB_RISK_OBJECT grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 2 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, member_sequence_ck, age, date_of_birth, gender, member_addition_indicator, member_name, member_type, passport_number, pre_existing_disease_description, relationship_to_proposer, record_source from (
    select distinct
        pol_serial_no || '|' || md_seq_no as parent_bk,
        cast(null as varchar) as member_sequence_ck,
        cast(null as varchar) as age,
        cast(null as varchar) as date_of_birth,
        cast(null as varchar) as gender,
        cast(null as varchar) as member_addition_indicator,
        cast(null as varchar) as member_name,
        cast(null as varchar) as member_type,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as pre_existing_disease_description,
        nullif(trim(to_varchar(md_relation)), '') as relationship_to_proposer,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pol_serial_no is not null and md_seq_no is not null
    )

union all

select parent_bk, member_sequence_ck, age, date_of_birth, gender, member_addition_indicator, member_name, member_type, passport_number, pre_existing_disease_description, relationship_to_proposer, record_source from (
    select distinct
        pol_serial_no || '|' || md_seq_no as parent_bk,
        cast(null as varchar) as member_sequence_ck,
        cast(null as varchar) as age,
        cast(null as varchar) as date_of_birth,
        cast(null as varchar) as gender,
        cast(null as varchar) as member_addition_indicator,
        cast(null as varchar) as member_name,
        cast(null as varchar) as member_type,
        cast(null as varchar) as passport_number,
        cast(null as varchar) as pre_existing_disease_description,
        nullif(trim(to_varchar(md_relation)), '') as relationship_to_proposer,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pol_serial_no is not null and md_seq_no is not null
    )

)
