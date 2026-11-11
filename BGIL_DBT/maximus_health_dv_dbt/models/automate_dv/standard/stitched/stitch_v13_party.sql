-- CENTRAL VIEW v13_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_COMMON_CONTACT
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_ALTERNATE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        cast(null as varchar) as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        t0.additional_contact_number as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as COMMON_CONTACT__FAX_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__MOBILE_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__PREFERRED_CONTACT_METHOD,
        cast(null as varchar) as COMMON_CONTACT__PREFERRED_CONTACT_TIME,
        cast(null as varchar) as COMMON_CONTACT__STD_CODE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL_ALTERNATE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        'EMAIL_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.additional_email_id as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=2
    select
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null,
        t0.mobile_no1 as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_CONTACT, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.stake_code, '') as PARTY_BK,
        'MOBILE_CONTACT' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.contact_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_adjust_pv') }} t0
    where (nullif(t0.stake_code, '')) is not null

    union all

    -- branch 6: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL_CONTACT, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.stake_code, '') as PARTY_BK,
        'EMAIL_CONTACT' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.contact_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_adjust_pv') }} t0
    where (nullif(t0.stake_code, '')) is not null

    union all

    -- branch 7: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_claim_payment_detail_attrs_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_claim_payment_detail_attrs_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email1 as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=2
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.email2 as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=3
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '3' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email3 as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 15: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.telephone_number as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 16: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=FAX, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'FAX' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null,
        t0.fax_number as COMMON_CONTACT__FAX_NUMBER,
        null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 17: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__clm_cd_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 18: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__clm_cd_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 19: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(t0.member_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    where (nullif(nullif(trim(t0.member_code),''), '')) is not null

    union all

    -- branch 20: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_ALTERNATE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null,
        t0.alternate_number as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 21: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('EMP:' || nullif(trim(t0.bagic_rm_e_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.bagic_rm_email as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.bagic_rm_e_code),''), '')) is not null

    union all

    -- branch 22: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL_CONTACT, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'EMAIL_CONTACT' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.contact_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 23: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_CONTACT, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'MOBILE_CONTACT' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.contact_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 24: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL_CUSTOMER, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'EMAIL_CUSTOMER' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.customer_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 25: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_CUSTOMER, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'MOBILE_CUSTOMER' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.customer_mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 26: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=2
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.emailid as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 27: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 28: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL_ALTERNATE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'EMAIL_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.email_id1 as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 29: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=FAX, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'FAX' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null,
        t0.fax as COMMON_CONTACT__FAX_NUMBER,
        null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 30: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE_HR, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(t0.policyholder_code),''), '') as PARTY_BK,
        'LANDLINE_HR' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.hr_contact_number as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(nullif(trim(t0.policyholder_code),''), '')) is not null

    union all

    -- branch 31: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('IMD:' || nullif(trim(t0.imd_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.intermediary_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('IMD:' || nullif(trim(t0.imd_code),''), '')) is not null

    union all

    -- branch 32: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('IMD:' || nullif(trim(t0.imd_code),''), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.intermediary_mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('IMD:' || nullif(trim(t0.imd_code),''), '')) is not null

    union all

    -- branch 33: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 34: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.phone_number as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null,
        t0.std_code as COMMON_CONTACT__STD_CODE,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 35: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=2
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.phone_number1 as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 36: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_POLICYHOLDER, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(t0.policyholder_code),''), '') as PARTY_BK,
        'MOBILE_POLICYHOLDER' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.policyholder_phone_number_1_mobile as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(nullif(trim(t0.policyholder_code),''), '')) is not null

    union all

    -- branch 37: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE_POLICYHOLDER, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(t0.policyholder_code),''), '') as PARTY_BK,
        'LANDLINE_POLICYHOLDER' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.policyholder_phone_number_2_land_line as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(nullif(trim(t0.policyholder_code),''), '')) is not null

    union all

    -- branch 38: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE_RESIDENCE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(t0.proposer_code, '') as PARTY_BK,
        'LANDLINE_RESIDENCE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.residence_phone_number as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 39: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_ALTERNATE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as PARTY_BK,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null,
        t0.alternatesecondary_contact_number as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null,
        8 as __PREC,
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

    -- branch 40: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.registered_contact_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        8 as __PREC,
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

    -- branch 41: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        9 as __PREC,
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

    -- branch 42: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        10 as __PREC,
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

    -- branch 43: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email1 as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_members_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 44: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=2
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.email2 as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_members_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 45: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=3
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '3' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email3 as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_members_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 46: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_members_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 47: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.telephone_number as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_members_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 48: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=FAX, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'FAX' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null,
        t0.fax_number as COMMON_CONTACT__FAX_NUMBER,
        null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_members_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 49: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_ALTERNATE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null,
        t0.alternate_mob_numberlandline_number as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 50: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_CLAIM, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'MOBILE_CLAIM' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.claim_mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 51: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMERGENCY, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'EMERGENCY' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.emergency_phone_number_val as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 52: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null, null, null, null,
        t0.std_code as COMMON_CONTACT__STD_CODE,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 53: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE_LAWYER, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'LANDLINE_LAWYER' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.phone_detailslawyer as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 54: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.emailid as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 55: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL_ALTERNATE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        'EMAIL_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.email_id1 as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 56: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.phone_number as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 57: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=2
    select
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.phone_number1 as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 58: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email1 as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_proposer_address_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_proposer_address') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '')) is not null

    union all

    -- branch 59: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=2
    select
        nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.email2 as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_proposer_address_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_proposer_address') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '')) is not null

    union all

    -- branch 60: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=3
    select
        nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '3' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email3 as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_proposer_address_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_proposer_address') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '')) is not null

    union all

    -- branch 61: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_proposer_address_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_proposer_address') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '')) is not null

    union all

    -- branch 62: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.telephone_number as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_proposer_address_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_proposer_address') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '')) is not null

    union all

    -- branch 63: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=FAX, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '') as PARTY_BK,
        'FAX' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null,
        t0.fax_number as COMMON_CONTACT__FAX_NUMBER,
        null, null, null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_proposer_address_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_proposer_address') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '')) is not null

    union all

    -- branch 64: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email1 as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 65: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=2
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.email2 as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 66: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL, COMMON_CONTACT.Contact Priority Order=3
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '3' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null,
        t0.email3 as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 67: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 68: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.telephone_number as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 69: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=FAX, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        'FAX' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null,
        t0.fax_number as COMMON_CONTACT__FAX_NUMBER,
        null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 70: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_ALTERNATE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null,
        t0.alternate_mob_numberlandline_number as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 71: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null, null, null,
        t0.best_time_to_call as COMMON_CONTACT__PREFERRED_CONTACT_TIME,
        t0.std_code as COMMON_CONTACT__STD_CODE,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 72: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE_WORK, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'LANDLINE_WORK' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null, null, null,
        t0.best_time_to_callw as COMMON_CONTACT__PREFERRED_CONTACT_TIME,
        null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 73: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_CLAIM, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'MOBILE_CLAIM' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.claim_mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 74: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_CONTACT_PERSON, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'MOBILE_CONTACT_PERSON' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.contact_person_mobile_no_1 as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 75: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE_CONTACT_PERSON, COMMON_CONTACT.Contact Priority Order=2
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'MOBILE_CONTACT_PERSON' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null,
        t0.contact_person_mobile_no_2 as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 76: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMERGENCY, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'EMERGENCY' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.emergency_phone_number_val as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 77: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE_LAWYER, COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        'LANDLINE_LAWYER' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.phone_detailslawyer as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 78: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): COMMON_CONTACT.Contact Priority Order=1
    select
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        t0.preferred_mode_of_contact as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null, null, null,
        t0.preferred_mode_of_contact as COMMON_CONTACT__PREFERRED_CONTACT_METHOD,
        null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

)

select
    PARTY_BK,
    COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
    COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
    first_value(COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
    first_value(COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
    first_value(COMMON_CONTACT__EMAIL_ADDRESS) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__EMAIL_ADDRESS,
    first_value(COMMON_CONTACT__FAX_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__FAX_NUMBER,
    first_value(COMMON_CONTACT__LANDLINE_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__LANDLINE_NUMBER,
    first_value(COMMON_CONTACT__MOBILE_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__MOBILE_NUMBER,
    first_value(COMMON_CONTACT__PREFERRED_CONTACT_METHOD) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__PREFERRED_CONTACT_METHOD,
    first_value(COMMON_CONTACT__PREFERRED_CONTACT_TIME) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__PREFERRED_CONTACT_TIME,
    first_value(COMMON_CONTACT__STD_CODE) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__STD_CODE
from merged
