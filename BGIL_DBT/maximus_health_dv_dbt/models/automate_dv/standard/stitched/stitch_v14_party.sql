-- CENTRAL VIEW v14_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB_MEMBER_DATA
--   MAXI_HLTH_UWR_VW_DATA_MEMBER_RIDER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_PARTY_IDENTITY
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        t0.age as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__ALIAS_NAME,
        cast(null as varchar) as PARTY_IDENTITY__COUNTRY_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__COUNTRY_OF_RESIDENCE,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        t0.date_of_death as PARTY_IDENTITY__DATE_OF_DEATH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        t0.patient_gender as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__GOLDEN_RECORD_INDICATOR,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        t0.insured_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_ORIGINATION_DATE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS_REASON,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__RESIDENT_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__SALUTATION,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('EMPLOYEE:' || nullif(trim(t0.employee_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.employee_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('EMPLOYEE:' || nullif(trim(t0.employee_code),''), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.hospital_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '')) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST_PIVOT_VW
    select
        nullif(t0.stake_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_adjust_pv') }} t0
    where (nullif(t0.stake_code, '')) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.involving_party as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_claim_payment_detail_attrs_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), '')) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY
    select
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null,
        t0.other_name as PARTY_IDENTITY__ALIAS_NAME,
        null, null,
        t0.dateof_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        null,
        t0.first_name as PARTY_IDENTITY__FIRST_NAME,
        t0.sex as PARTY_IDENTITY__GENDER_CODE,
        null,
        t0.last_name as PARTY_IDENTITY__LAST_NAME,
        t0.middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        null,
        t0.business_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        null, null, null, null,
        t0.indv_or_org as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 6: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(t0.member_code),''), '') as PARTY_BK,
        t0.age as PARTY_IDENTITY__AGE,
        null, null, null,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        null, null,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        null, null, null, null,
        t0.party_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    where (nullif(nullif(trim(t0.member_code),''), '')) is not null

    union all

    -- branch 7: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.nominee_name,'') || '#' || coalesce(t0.nominee_date_of_birth,'')), '#'))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.nominee_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.nominee_name,'') || '#' || coalesce(t0.nominee_date_of_birth,'')), '#'))), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(t0.proposer_name), ''))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.proposer_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(t0.proposer_name), ''))), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        t0.age as PARTY_IDENTITY__AGE,
        null, null, null, null, null, null, null, null, null, null,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        t0.full_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null,
        t0.type_of_customers as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        null, null,
        t0.title as PARTY_IDENTITY__SALUTATION,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 10: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('EMP:' || nullif(trim(t0.bagic_rm_e_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bagic_rm_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.bagic_rm_e_code),''), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('IMD:' || nullif(trim(t0.imd_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.intermediary_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('IMD:' || nullif(trim(t0.imd_code),''), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(nullif(trim(t0.policyholder_code),''), '') as PARTY_BK,
        null, null, null, null,
        t0.policyholder_date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        null,
        t0.policyholder_first_name as PARTY_IDENTITY__FIRST_NAME,
        t0.policyholder_gender as PARTY_IDENTITY__GENDER_CODE,
        null,
        t0.policyholder_last_name_1 as PARTY_IDENTITY__LAST_NAME,
        null, null, null, null, null, null, null, null,
        t0.policy_holder_type as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(nullif(trim(t0.policyholder_code),''), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('SPECIFIED_PERSON:' || nullif(trim(t0.specified_person_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.specified_person_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('SPECIFIED_PERSON:' || nullif(trim(t0.specified_person_code),''), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(t0.sub_imd_party_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_imd_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.sub_imd_party_code, '')) is not null

    union all

    -- branch 15: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
    select
        nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.member_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 16: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as PARTY_BK,
        t0.age as PARTY_IDENTITY__AGE,
        null, null, null,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        null, null,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        null, null, null, null,
        t0.party_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j4.KEY_HASH
    where (nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 17: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.nominee_name,'') || '#' || coalesce(t0.nominee_date_of_birth,'')), '#'))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.nominee_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.nominee_name,'') || '#' || coalesce(t0.nominee_date_of_birth,'')), '#'))), '')) is not null

    union all

    -- branch 18: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(t0.proposer_name), ''))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.proposer_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(t0.proposer_name), ''))), '')) is not null

    union all

    -- branch 19: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        t0.age as PARTY_IDENTITY__AGE,
        null, null,
        t0.country_of_residence as PARTY_IDENTITY__COUNTRY_OF_RESIDENCE,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        null,
        t0.first_name as PARTY_IDENTITY__FIRST_NAME,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        null,
        t0.last_name_1 as PARTY_IDENTITY__LAST_NAME,
        null,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        t0.member_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null,
        t0.type_of_applicant as PARTY_IDENTITY__PARTY_TYPE_CODE,
        t0.residential_status as PARTY_IDENTITY__RESIDENT_STATUS,
        t0.title as PARTY_IDENTITY__SALUTATION,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 20: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
    select
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null,
        t0.other_name as PARTY_IDENTITY__ALIAS_NAME,
        null, null,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        null,
        t0.first_name as PARTY_IDENTITY__FIRST_NAME,
        t0.sex as PARTY_IDENTITY__GENDER_CODE,
        null,
        t0.last_name as PARTY_IDENTITY__LAST_NAME,
        t0.middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        t0.full_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        t0.business_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        null,
        t0.party_status as PARTY_IDENTITY__PARTY_STATUS,
        null, null,
        t0.indv_or_org as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 21: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        t0.age as PARTY_IDENTITY__AGE,
        null,
        t0.country_of_birth as PARTY_IDENTITY__COUNTRY_OF_BIRTH,
        t0.country_of_residence as PARTY_IDENTITY__COUNTRY_OF_RESIDENCE,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        t0.date_of_death as PARTY_IDENTITY__DATE_OF_DEATH,
        null,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        t0.search_from_gc as PARTY_IDENTITY__GOLDEN_RECORD_INDICATOR,
        null, null,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        t0.claim_applicant_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        t0.legal_name_of_business as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        t0.creation_date as PARTY_IDENTITY__PARTY_ORIGINATION_DATE,
        t0.blockunblock_status as PARTY_IDENTITY__PARTY_STATUS,
        t0.reason_for_activationdeactivation as PARTY_IDENTITY__PARTY_STATUS_REASON,
        null, null, null,
        t0.claim_applicant_name_prefix as PARTY_IDENTITY__SALUTATION,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 22: MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB_MEMBER_DATA
    select
        nullif(nullif(trim(t0.member_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.member_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_memd_tab_member_data') }} t0
    where (nullif(nullif(trim(t0.member_code),''), '')) is not null

    union all

    -- branch 23: MAXI_HLTH_UWR_VW_DATA_MEMBER_RIDER_DETAILS
    select
        nullif('MEMBER:' || nullif(trim(j1.policy_number),'') || '#' || t0.member_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.member_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_member_rider_dtls') }} t0
    left join {{ ref('stg_mxh__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif('MEMBER:' || nullif(trim(j1.policy_number),'') || '#' || t0.member_code, '')) is not null

    union all

    -- branch 24: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.name_of_the_premium_payer as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 25: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        nullif('PAYER-REVISED:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payernew,'')), ''))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.name_of_the_premium_payernew as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif('PAYER-REVISED:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payernew,'')), ''))), '')) is not null

    union all

    -- branch 26: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
    select
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null,
        t0.other_name as PARTY_IDENTITY__ALIAS_NAME,
        null, null,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        null,
        t0.first_name as PARTY_IDENTITY__FIRST_NAME,
        t0.sex as PARTY_IDENTITY__GENDER_CODE,
        null,
        t0.last_name as PARTY_IDENTITY__LAST_NAME,
        t0.middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        t0.full_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        t0.business_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        null,
        t0.party_status as PARTY_IDENTITY__PARTY_STATUS,
        null, null,
        t0.indv_or_org as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 27: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        t0.age as PARTY_IDENTITY__AGE,
        null,
        t0.country_of_birth as PARTY_IDENTITY__COUNTRY_OF_BIRTH,
        t0.country_of_residence as PARTY_IDENTITY__COUNTRY_OF_RESIDENCE,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        t0.date_of_death as PARTY_IDENTITY__DATE_OF_DEATH,
        null,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        t0.search_from_gc as PARTY_IDENTITY__GOLDEN_RECORD_INDICATOR,
        null, null,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        t0.claim_applicant_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        t0.legal_name_of_business as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        t0.creation_date as PARTY_IDENTITY__PARTY_ORIGINATION_DATE,
        null,
        t0.reason_for_activationdeactivation as PARTY_IDENTITY__PARTY_STATUS_REASON,
        t0.type_of_insured as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        t0.policy_holder_type as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null,
        t0.claim_applicant_name_prefix as PARTY_IDENTITY__SALUTATION,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 28: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif('EMP:' || nullif(trim(t0.bagic_employee_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bagic_employee_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.bagic_employee_code),''), '')) is not null

)

select
    PARTY_BK,
    first_value(PARTY_IDENTITY__AGE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__AGE,
    first_value(PARTY_IDENTITY__ALIAS_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__ALIAS_NAME,
    first_value(PARTY_IDENTITY__COUNTRY_OF_BIRTH) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__COUNTRY_OF_BIRTH,
    first_value(PARTY_IDENTITY__COUNTRY_OF_RESIDENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__COUNTRY_OF_RESIDENCE,
    first_value(PARTY_IDENTITY__DATE_OF_BIRTH) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__DATE_OF_BIRTH,
    first_value(PARTY_IDENTITY__DATE_OF_DEATH) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__DATE_OF_DEATH,
    first_value(PARTY_IDENTITY__FIRST_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__FIRST_NAME,
    first_value(PARTY_IDENTITY__GENDER_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__GENDER_CODE,
    first_value(PARTY_IDENTITY__GOLDEN_RECORD_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__GOLDEN_RECORD_INDICATOR,
    first_value(PARTY_IDENTITY__LAST_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__LAST_NAME,
    first_value(PARTY_IDENTITY__MIDDLE_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__MIDDLE_NAME,
    first_value(PARTY_IDENTITY__NATIONALITY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__NATIONALITY,
    first_value(PARTY_IDENTITY__PARTY_FULL_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_FULL_NAME,
    first_value(PARTY_IDENTITY__PARTY_LEGAL_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
    first_value(PARTY_IDENTITY__PARTY_ORIGINATION_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_ORIGINATION_DATE,
    first_value(PARTY_IDENTITY__PARTY_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_STATUS,
    first_value(PARTY_IDENTITY__PARTY_STATUS_REASON) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_STATUS_REASON,
    first_value(PARTY_IDENTITY__PARTY_SUB_TYPE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
    first_value(PARTY_IDENTITY__PARTY_TYPE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_TYPE_CODE,
    first_value(PARTY_IDENTITY__RESIDENT_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__RESIDENT_STATUS,
    first_value(PARTY_IDENTITY__SALUTATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__SALUTATION
from merged
