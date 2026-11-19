-- CENTRAL VIEW v29_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PORT_WORDINGS (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_POLICY_PORTABILITY_MIGRATION
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_HCP_PORT_WORDINGS
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        prev_insurer as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prev_policy_no as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        prev_si as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1000 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_port_wordings') }}
    where (contract_id) is not null

    union all

    -- branch 1: BA_HCP_PROD_8428_GPG_LOADER
    select
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        md_prev_comp_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        md_prev_policy_number as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        md_prev_sum_insured as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 2: BA_HCP_PROD_8439_CLH_LOADER
    select
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        md_prev_comp_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        md_prev_policy_number as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        md_prev_sum_insured as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 3: BJAZ_EC_MEM_DTLS_EXTN
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        pre_pol_ncb_per as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        prev_company_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prev_policy_dtls as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        prev_sum_insured as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where (contract_id) is not null

    union all

    -- branch 4: BJAZ_GPG_POL_DTLS
    select
        reference_id as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        prev_policy_comp_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prev_pol_no as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where (reference_id) is not null

    union all

    -- branch 5: BJAZ_GRP_HLT_DTLS
    select
        reg_no as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        pre_insurer_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prv_policy_no as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where (reg_no) is not null

    union all

    -- branch 6: BJAZ_HAT_ID_MEM_DETLS
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prev_policy_details as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where (contract_id) is not null

    union all

    -- branch 7: BJAZ_HCF_MEMBER_DTLS
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        previous_si as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 8: BJAZ_HC_PART_EXTN
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        first_policy_ref as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where (contract_id) is not null

    union all

    -- branch 9: BJAZ_HG_POL_DTLS
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        pol_benefit_tran_yn as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prev_policy_no as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        prev_sum_insured as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 10: BJAZ_HLT_ENSURE_MEM_DTLS
    select
        contract_id as POLICY_BK,
        previous_since_noof_years as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        previous_cum_bonus as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        previous_company_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prev_policy_no as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        previous_sum_insured as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1010 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 11: BJAZ_IHG_MEM_DTLS_EXTN
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prev_policy_dtls as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        prev_sum_insured as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1011 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where (contract_id) is not null

    union all

    -- branch 12: BJAZ_SH_MEM_DTLS_EXTN
    select
        contract_id as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prev_policy_dtls as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        prev_sum_insured as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        1012 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where (contract_id) is not null

    union all

    -- branch 13: BJAZ_POLICY_BASES_EXTN
    select
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        prev_insurer_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        prev_policy_no as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        2013 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_policy_bases_extn') }}
    where (nullif(trim(contract_id),'')) is not null

)

select
    POLICY_BK,
    first_value(POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
    first_value(POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
    first_value(POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
    first_value(POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
    first_value(POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
    first_value(POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED
from merged
