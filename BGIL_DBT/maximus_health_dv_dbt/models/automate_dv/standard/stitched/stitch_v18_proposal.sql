-- CENTRAL VIEW v18_proposal -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_PROPOSAL_MEDICAL_SCHEDULING
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PROPOSAL_POLICY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=2D_ECHO
    select
        cast(null as varchar) as POLICY_BK,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        cast(null as number) as __LNK_PROPOSAL_POLICY,
        cast(null as varchar) as PROPOSAL_MEDICAL_SCHEDULING__MEMBER_REFERENCE_CK,
        '2D_ECHO' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.c_2d_echo as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=2D_ECHO_CTMT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        '2D_ECHO_CTMT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.c_2d_echo_ctmt as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=CA_125
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'CA_125' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ca_125 as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 3: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=CBC_COMPLETE_BLOOD_COUNT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'CBC_COMPLETE_BLOOD_COUNT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.cbc_complete_blood_count as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 4: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=CREACTIVE_PROTEIN_CRP
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'CREACTIVE_PROTEIN_CRP' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.creactive_protein_crp as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 5: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=CTMT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'CTMT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ctmt as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 6: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=DERMATOLOGIST_CONSULTATION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'DERMATOLOGIST_CONSULTATION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.dermatologist_consultation as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 7: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ECG_SECOND_OPINION_REPORT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ECG_SECOND_OPINION_REPORT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ecg_second_opinion_report as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ESR
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ESR' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.esr as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=FITNESS_CERTIFICATE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'FITNESS_CERTIFICATE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.fitness_certificate as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=FULL_MEDICAL_REPORT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'FULL_MEDICAL_REPORT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.full_medical_reportfmr as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=HBA1C
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'HBA1C' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.hba1c as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=IMMUNOGLOBULIN_G_IGG
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'IMMUNOGLOBULIN_G_IGG' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.immunoglobulin_g_igg as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=IMMUNOGLOBULIN_M_IGM
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'IMMUNOGLOBULIN_M_IGM' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.immunoglobulin_m_igm as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=LFT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'LFT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.lft as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 15: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=MAMMOGRAPHY
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'MAMMOGRAPHY' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.mammography as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 16: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=MANTOUX_TEST_TUBERCULIN_TEST
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'MANTOUX_TEST_TUBERCULIN_TEST' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.mantoux_test_tuberculin_test as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 17: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=MCHC_MEAN_CORPUSCULAR_HAEMOGLOBIN_CONCENTRATION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'MCHC_MEAN_CORPUSCULAR_HAEMOGLOBIN_CONCENTRATION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.mchc_mean_corpuscular_haemoglobin_concentration as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 18: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=MCH_MEAN_CORPUSCULAR_HAEMOGLOBIN
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'MCH_MEAN_CORPUSCULAR_HAEMOGLOBIN' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.mch_mean_corpuscular_haemoglobin as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 19: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=MCV_MEAN_CORPUSCULAR_VOLUME
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'MCV_MEAN_CORPUSCULAR_VOLUME' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.mcv_mean_corpuscular_volume as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 20: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=MEDICAL_FITNESS
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'MEDICAL_FITNESS' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.medical_fitness as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 21: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=MG_MAGNESIUM
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'MG_MAGNESIUM' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.mg_magnesium as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 22: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=MICROALBUMIN_URINE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'MICROALBUMIN_URINE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.microalbumin_urine as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 23: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=NEPHROLOGIST_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'NEPHROLOGIST_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.nephrologist_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 24: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=NEUROLOGIST_CONSULTATION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'NEUROLOGIST_CONSULTATION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.neurologist_consultation as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 25: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=NEUROLOGIST_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'NEUROLOGIST_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.neurologist_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 26: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=OPHTHALMIC_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'OPHTHALMIC_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ophthalmic_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 27: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=OPTHALMIC_CHECK_UP
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'OPTHALMIC_CHECK_UP' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.opthalmic_check_up as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 28: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ORHTOPAEDIC_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ORHTOPAEDIC_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.orhtopaedic_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 29: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ORTHOPEDIC_CONSULTATION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ORTHOPEDIC_CONSULTATION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.orthopedic_consultation as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 30: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PAP_SMEAR
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PAP_SMEAR' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.pap_smear as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 31: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PARATHYROID_LEVEL
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PARATHYROID_LEVEL' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.parathyroid_level as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 32: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PCV_HAEMATOCRIT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PCV_HAEMATOCRIT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.pcv_haematocrit as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 33: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PERIPHERAL_BLOOD_SMEAR_MP
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PERIPHERAL_BLOOD_SMEAR_MP' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.peripheral_blood_smear_mp as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 34: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PERIPHERAL_SMEAR_FOR_EXPERT_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PERIPHERAL_SMEAR_FOR_EXPERT_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.peripheral_smear_for_expert_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 35: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PFT_PULMONARY_FUNCTION_TEST_SPIROMETRY
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PFT_PULMONARY_FUNCTION_TEST_SPIROMETRY' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.pft_pulmonary_function_test_spirometry as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 36: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PHOSPHORUS
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PHOSPHORUS' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.phosphorus as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 37: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PHYSICIAN_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PHYSICIAN_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.physician_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 38: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PLATELETS
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PLATELETS' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.platelets as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 39: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=POTASSIUM
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'POTASSIUM' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.potassium as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 40: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PROSTATE_SONOGRAPHY
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PROSTATE_SONOGRAPHY' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.prostate_sonography as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 41: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PROTEINS_ALBUMIN
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PROTEINS_ALBUMIN' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.proteins_albumin as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 42: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PROTEINS_TOTAL
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PROTEINS_TOTAL' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.proteins_total as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 43: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PROTHROMBIN_TIME
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PROTHROMBIN_TIME' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.prothrombin_time as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 44: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PROTHROMBIN_TIME_PT_INR
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PROTHROMBIN_TIME_PT_INR' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.prothrombin_time_pt_inr as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 45: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PSA_PROSTRATE_SPECIFIC_ANTIGEN
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PSA_PROSTRATE_SPECIFIC_ANTIGEN' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.psa_prostrate_specific_antigen as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 46: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=PULMONOLOGIST_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'PULMONOLOGIST_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.pulmonologist_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 47: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=RANDOM_BLOOD_SUGAR_BSL
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'RANDOM_BLOOD_SUGAR_BSL' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.random_blood_sugar_bsl as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 48: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=RA_FACTOR
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'RA_FACTOR' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ra_factor as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 49: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=RBC_RED_BLOOD_CELLS
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'RBC_RED_BLOOD_CELLS' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.rbc_red_blood_cells as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 50: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=RENALKIDNEY_FUNCTION_TEST_SERUM_CREATININE_URINE_ROUTINE_UREA_TOTAL_PROTEINS_CALCIUM_PHOSPHOROUS_CHLORIDE_SODIUM_POTASSIUM
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'RENALKIDNEY_FUNCTION_TEST_SERUM_CREATININE_URINE_ROUTINE_UREA_TOTAL_PROTEINS_CALCIUM_PHOSPHOROUS_CHLORIDE_SODIUM_POTASSIUM' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.renalkidney_function_test_serum_creatinine_urine_routine_urea_total_proteins_calcium_phosphorous_chloride_sodium_potassium as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 51: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERIUM_FERITTIN
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERIUM_FERITTIN' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serium_ferittin as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 52: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_ACID_PHOSPHATASE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_ACID_PHOSPHATASE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_acid_phosphatase as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 53: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_AMYLASE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_AMYLASE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_amylase as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 54: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_CHOLESTEROL
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_CHOLESTEROL' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_cholesterol as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 55: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_CPK_CREATININE_PHOSPHOKINASE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_CPK_CREATININE_PHOSPHOKINASE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_cpk_creatinine_phosphokinase as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 56: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_CREATININE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_CREATININE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_creatinine as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 57: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_ELECTROLYTES
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_ELECTROLYTES' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_electrolytes as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 58: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_LH_LUETENIZING_HORMONE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_LH_LUETENIZING_HORMONE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_lh_luetenizing_hormone as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 59: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_LIPASE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_LIPASE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_lipase as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 60: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_TRIGLYCERIDES
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_TRIGLYCERIDES' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_triglycerides as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 61: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SERUM_URIC_ACID
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SERUM_URIC_ACID' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.serum_uric_acid as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 62: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SGOTAST_SERUM_GLUTAMIC_OXALATE_TRANSAMINASEALANINE_ASPARATE_AMINOTRANSFERASE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SGOTAST_SERUM_GLUTAMIC_OXALATE_TRANSAMINASEALANINE_ASPARATE_AMINOTRANSFERASE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.sgotast_serum_glutamic_oxalate_transaminasealanine_asparate_aminotransferase as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 63: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SGPTALT_SERUM_GLUTAMIC_PYRUVIC_TRANSAMINASEALANINE_AMINOTRANSFERASE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SGPTALT_SERUM_GLUTAMIC_PYRUVIC_TRANSAMINASEALANINE_AMINOTRANSFERASE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.sgptalt_serum_glutamic_pyruvic_transaminasealanine_aminotransferase as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 64: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SODIUM
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SODIUM' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.sodium as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 65: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=SR_CALCIUM
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'SR_CALCIUM' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.sr_calcium as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 66: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=STOOL_MICROSCOPY
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'STOOL_MICROSCOPY' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.stool_microscopy as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 67: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=STOOL_ROUTINE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'STOOL_ROUTINE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.stool_routine as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 68: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=T3_FREE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'T3_FREE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.t3_free as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 69: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=T3_TRIIODOTHYRONINE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'T3_TRIIODOTHYRONINE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.t3_triiodothyronine as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 70: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=T4_FREE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'T4_FREE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.t4_free as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 71: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=T4_THYROXINE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'T4_THYROXINE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.t4_thyroxine as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 72: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=THYROID_PROFILE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'THYROID_PROFILE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.thyroid_profile as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 73: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=TMT_TREAD_MILL_TEST
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'TMT_TREAD_MILL_TEST' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.tmt_tread_mill_test as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 74: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=TOTAL_LEUCOCYTE_COUNT_TLC
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'TOTAL_LEUCOCYTE_COUNT_TLC' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.total_leucocyte_count_tlc as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 75: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=TOTAL_LIPIDS
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'TOTAL_LIPIDS' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.total_lipids as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 76: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=TSH_THYROID_STIMULATING_HORMONE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'TSH_THYROID_STIMULATING_HORMONE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.tsh_thyroid_stimulating_hormone as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 77: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ULTRASOUND_PELVIS
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ULTRASOUND_PELVIS' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ultrasound_pelvis as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 78: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ULTRASOUND_THYROID
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ULTRASOUND_THYROID' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ultrasound_thyroid as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 79: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ULTRASOUND_WHOLE_ABDOMEN
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ULTRASOUND_WHOLE_ABDOMEN' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ultrasound_whole_abdomen as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 80: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ULTRASOUND_WHOLE_ABDOMEN_ULTRASOUND_PELVIS
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ULTRASOUND_WHOLE_ABDOMEN_ULTRASOUND_PELVIS' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ultrasound_whole_abdomen_ultrasound_pelvis as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 81: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ULTRASOUND_WHOLE_ABDOMEN_WITH_KUB
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ULTRASOUND_WHOLE_ABDOMEN_WITH_KUB' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ultrasound_whole_abdomen_with_kub as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 82: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ULTRA_SOUND_OBST
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'ULTRA_SOUND_OBST' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ultra_sound_obst as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 83: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=URIC_ACID
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'URIC_ACID' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.uric_acid as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 84: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=URINE_CULTURE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'URINE_CULTURE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.urine_culture as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 85: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=URINE_MICROSCOPY
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'URINE_MICROSCOPY' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.urine_microscopy as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 86: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=URINE_ROUTINE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'URINE_ROUTINE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.urine_routine as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 87: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=USG_OBST_NT_SCAN_RELATED_TO_PREGNANCY
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'USG_OBST_NT_SCAN_RELATED_TO_PREGNANCY' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.usg_obst_nt_scan_related_to_pregnancy as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 88: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=VDRL_VENEREAL_DISEASE_RESEARCH_LABORATORY
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'VDRL_VENEREAL_DISEASE_RESEARCH_LABORATORY' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.vdrl_venereal_disease_research_laboratory as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 89: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=VITAMIN_B12
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'VITAMIN_B12' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.vitamin_b12 as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 90: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=VITAMIN_D3
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'VITAMIN_D3' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.vitamin_d3 as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 91: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=WBC_WHITE_BLOOD_CELLS
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'WBC_WHITE_BLOOD_CELLS' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.wbc_white_blood_cells as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 92: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=WIDAL_TUBE_METHOD
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'WIDAL_TUBE_METHOD' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.widal_tube_method as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 93: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_BARIUM_SWALLOW
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_BARIUM_SWALLOW' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_barium_swallow as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 94: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_BOTH_KNEE_JOINT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_BOTH_KNEE_JOINT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_both_knee_joint as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 95: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_BOTH_KNEE_JOINT_AND_ORTHO_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_BOTH_KNEE_JOINT_AND_ORTHO_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_both_knee_joint_and_ortho_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 96: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_CHEST_PA_
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_CHEST_PA_' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_chest_pa_ as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 97: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_LEFT_KNEE_AP_LAT_AND_ORTHO_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_LEFT_KNEE_AP_LAT_AND_ORTHO_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_left_knee_ap_lat_and_ortho_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 98: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_LUMBAR_AND_CERVICAL_SPINE_WITH_ORTHOPEDIC_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_LUMBAR_AND_CERVICAL_SPINE_WITH_ORTHOPEDIC_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_lumbar_and_cervical_spine_with_orthopedic_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 99: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_LUMBAR_SPINE_WITH_ORTHOPAEDIC_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_LUMBAR_SPINE_WITH_ORTHOPAEDIC_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_lumbar_spine_with_orthopaedic_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 100: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_RIGHT_ARM_HUMERUS_
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_RIGHT_ARM_HUMERUS_' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_right_arm_humerus_ as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 101: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_RIGHT_HAND_WRIST
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_RIGHT_HAND_WRIST' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_right_hand_wrist as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 102: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_RIGHT_KNEE_AP_LAT_AND_ORTHO_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_RIGHT_KNEE_AP_LAT_AND_ORTHO_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_right_knee_ap_lat_and_ortho_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 103: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_RIGHT_LEG_WITH_ANKLE_AP_AND_LATERAL
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_RIGHT_LEG_WITH_ANKLE_AP_AND_LATERAL' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_right_leg_with_ankle_ap_and_lateral as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 104: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_SPINAL_CORD
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_SPINAL_CORD' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_spinal_cord as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 105: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=XRAY_WRIST
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'XRAY_WRIST' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray_wrist as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 106: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAYHIP_AP_LATERAL
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAYHIP_AP_LATERAL' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_rayhip_ap_lateral as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 107: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAYLUMBAR_SPINE_AP_AND_LATERAL
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAYLUMBAR_SPINE_AP_AND_LATERAL' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_raylumbar_spine_ap_and_lateral as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 108: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAYLUMBAR_SPINE_LATERAL_EXTENSION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAYLUMBAR_SPINE_LATERAL_EXTENSION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_raylumbar_spine_lateral_extension as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 109: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAYLUMBAR_SPINE_LATERAL_FLEXATION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAYLUMBAR_SPINE_LATERAL_FLEXATION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_raylumbar_spine_lateral_flexation as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 110: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAYRIGHT_HIP_AP_LATERAL
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAYRIGHT_HIP_AP_LATERAL' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_rayright_hip_ap_lateral as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 111: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAY_CERVICAL_SPINE_AP_AND_LATERAL_VIEW
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAY_CERVICAL_SPINE_AP_AND_LATERAL_VIEW' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_ray_cervical_spine_ap_and_lateral_view as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 112: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAY_CHEST_SECOND_OPINION
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAY_CHEST_SECOND_OPINION' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_ray_chest_second_opinion as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 113: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAY_LEFT_FOOT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAY_LEFT_FOOT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_ray_left_foot as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 114: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAY_LEFT_HAND_AP_AND_LATERAL_VIEW
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAY_LEFT_HAND_AP_AND_LATERAL_VIEW' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_ray_left_hand_ap_and_lateral_view as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 115: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAY_PELVIS
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAY_PELVIS' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_ray_pelvis as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 116: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAY_RIGHT_FOOT
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAY_RIGHT_FOOT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_ray_right_foot as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 117: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAY_SPINE
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAY_SPINE' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_ray_spine as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 118: MAXI_HLTH_UWR_VW_DATA_MEMBERS_ADDITIONAL_TEST_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAY_THORACIC_SPINE_AP_AND_LATERAL
    select
        null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        'X_RAY_THORACIC_SPINE_AP_AND_LATERAL' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.x_ray_thoracic_spine_ap_and_lateral as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_additional_test_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_additional_test') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 119: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=2D_ECHO
    select
        null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        '2D_ECHO' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.c_2d_eco as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (nullif(t0.foreign_key, '')) is not null

    union all

    -- branch 120: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ANY_OTHER_ADDITIONAL_TEST
    select
        null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        'ANY_OTHER_ADDITIONAL_TEST' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.any_other_additional_test as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (nullif(t0.foreign_key, '')) is not null

    union all

    -- branch 121: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=BMI
    select
        null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        'BMI' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.bmi_decision as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (nullif(t0.foreign_key, '')) is not null

    union all

    -- branch 122: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=CTMT
    select
        null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        'CTMT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ctmt_decision as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (nullif(t0.foreign_key, '')) is not null

    union all

    -- branch 123: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=ECG
    select
        null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        'ECG' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.ecg_decision as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (nullif(t0.foreign_key, '')) is not null

    union all

    -- branch 124: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=FULL_MEDICAL_REPORT
    select
        null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        'FULL_MEDICAL_REPORT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.full_medical_report as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (nullif(t0.foreign_key, '')) is not null

    union all

    -- branch 125: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=LABORATORY_REPORT
    select
        null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        'LABORATORY_REPORT' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.laboratory_report as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (nullif(t0.foreign_key, '')) is not null

    union all

    -- branch 126: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=USG
    select
        null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        'USG' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.usg as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (nullif(t0.foreign_key, '')) is not null

    union all

    -- branch 127: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): PROPOSAL_MEDICAL_SCHEDULING.Test Type=X_RAY
    select
        null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        'X_RAY' as PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
        t0.xray as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (nullif(t0.foreign_key, '')) is not null

    union all

    -- branch 128: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        1 as __LNK_PROPOSAL_POLICY,
        null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_decisions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j4.policy_number),''), ''), nullif(t0.foreign_key, ''))) is not null

)

select
    POLICY_BK,
    PROPOSAL_BK,
    __LNK_PROPOSAL_POLICY,
    PROPOSAL_MEDICAL_SCHEDULING__MEMBER_REFERENCE_CK,
    PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK,
    first_value(PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS) ignore nulls over (partition by PROPOSAL_BK, PROPOSAL_MEDICAL_SCHEDULING__MEMBER_REFERENCE_CK, PROPOSAL_MEDICAL_SCHEDULING__TEST_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_MEDICAL_SCHEDULING__REPORT_STATUS
from merged
