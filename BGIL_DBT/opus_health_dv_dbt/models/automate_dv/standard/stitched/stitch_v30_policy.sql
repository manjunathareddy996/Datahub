-- CENTRAL VIEW v30_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_ILLNESS_BASES_EXTN (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_POLICY_TERMS
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_CTNGY_GC_CONTROL
    select
        nullif(trim(policy_ref),'') as POLICY_BK,
        co_payment as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        cast(null as varchar) as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ctngy_gc_control') }}
    where (nullif(trim(policy_ref),'')) is not null

    union all

    -- branch 1: BA_HCP_PROD_8428_GPG_LOADER
    select
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        plc_special_terms_conditions as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 2: BA_HCP_PROD_8432_ECP_LOADER
    select
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        plc_aggr_deductible as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        plc_special_terms_conditions as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        1002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 3: BA_HCP_PROD_8433_FHC_LOADER
    select
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        plc_special_terms_conditions as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 4: BA_HCP_PROD_8439_CLH_LOADER
    select
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        plc_special_terms_conditions as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 5: BJAZ_GPG_POL_DTLS
    select
        reference_id as POLICY_BK,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        spcl_terms_cond as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where (reference_id) is not null

    union all

    -- branch 6: BJAZ_GRP_HLT_DTLS
    select
        reg_no as POLICY_BK,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        other_conditions as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where (reg_no) is not null

    union all

    -- branch 7: BJAZ_HG_POL_DTLS
    select
        contract_id as POLICY_BK,
        voluntary_co_pay as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        aggregate_deductible as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        cast(null as varchar) as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 8: BJAZ_HLT_ENSURE_MEM_DTLS
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        special_condition as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 9: BJAZ_ILLNESS_BASES_EXTN
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        special_condition as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        1009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_illness_bases_extn') }}
    where (contract_id) is not null

    union all

    -- branch 10: BJAZ_GMC_BASES_EXTN
    select
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        sp_conditions as POLICY_TERMS__SPECIAL_CONDITIONS,
        warrenties as POLICY_TERMS__WARRANTY_CONDITIONS,
        2010 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gmc_bases_extn') }}
    where (nullif(trim(contract_id),'')) is not null

    union all

    -- branch 11: BJAZ_STARPKG_POL_DTLS
    select
        nullif(trim(contract_id),'') as POLICY_BK,
        co_pymt as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        cast(null as varchar) as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WARRANTY_CONDITIONS,
        2011 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}
    where (nullif(trim(contract_id),'')) is not null

)

select
    POLICY_BK,
    first_value(POLICY_TERMS__CO_PAYMENT_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
    first_value(POLICY_TERMS__DEDUCTIBLE_TOTAL) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
    first_value(POLICY_TERMS__SPECIAL_CONDITIONS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__SPECIAL_CONDITIONS,
    first_value(POLICY_TERMS__WARRANTY_CONDITIONS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__WARRANTY_CONDITIONS
from merged
