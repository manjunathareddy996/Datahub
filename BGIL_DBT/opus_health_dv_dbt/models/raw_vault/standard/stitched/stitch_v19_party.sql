-- CENTRAL VIEW v19_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_LNK_ROLE_NOMINEE_BENEFICIARY
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_HCP_PROD_8428_GPG_LOADER | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        pd_premium_payer_id as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        md_nominee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1000 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 1: BA_HCP_PROD_8432_ECP_LOADER | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        pd_premium_payer_id as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        md_nominee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 2: BA_HCP_PROD_8433_FHC_LOADER | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        pd_premium_payer_id as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        md_nominee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 3: BA_HCP_PROD_8439_CLH_LOADER | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        pd_premium_payer_id as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        md_nominee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where (pd_premium_payer_id) is not null

    union all

    -- branch 4: BJAZ_BANDHAN_MEDI_CLAM | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        customer_id as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        nominee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where (customer_id) is not null

    union all

    -- branch 5: BJAZ_EC_MEM_DTLS_EXTN | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        member_no as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        nominee_rltn as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where (member_no) is not null

    union all

    -- branch 6: BJAZ_GP_HOSPITAL_CASH | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        user_id as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        nominee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where (user_id) is not null

    union all

    -- branch 7: BJAZ_HCF_MEMBER_DTLS | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        member_no as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        assignee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where (member_no) is not null

    union all

    -- branch 8: BJAZ_HC_PART_EXTN | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        part_id as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        nominee_rltn as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where (part_id) is not null

    union all

    -- branch 9: BJAZ_HDFC_SEC_FHPP | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        client_id as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        nominee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where (client_id) is not null

    union all

    -- branch 10: BJAZ_HLT_ENSURE_MEM_DTLS | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        member_no as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        nominee_rltn as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1010 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where (member_no) is not null

    union all

    -- branch 11: BJAZ_IHG_MEM_DTLS_EXTN | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        member_no as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        nominee_rltn as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1011 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where (member_no) is not null

    union all

    -- branch 12: BJAZ_SH_MEM_DTLS_EXTN | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        member_no as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        nominee_rltn as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        1012 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where (member_no) is not null

)

select
    PARTY_BK,
    ROLE_TYPE_CODE,
    LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
    first_value(LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED) ignore nulls over (partition by PARTY_BK, LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED
from merged
