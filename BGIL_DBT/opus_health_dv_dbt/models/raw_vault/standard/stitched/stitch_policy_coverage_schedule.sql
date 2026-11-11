{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_COVERAGE_SCHEDULE only. Original precedence comments are kept below (from stitch_v25_policy).
-- CENTRAL VIEW v25_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_COVERS_EXT (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BA_HCP_DT_POL_COV (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_STARPKG_COVER_DTLS (opus_health_delta3)
--   OCP_POLICY_COVERS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_COVERAGE_SCHEDULE
--   SAT_POLICY_COVERAGE_SCHEDULE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_covers_ext') }}
-- depends_on: {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hc_part_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hg_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_coverage_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_cover_dtls') }}
-- depends_on: {{ ref('stg_health__ocp_policy_covers') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_covers_ext',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(cover_code, '~') || '|' || coalesce(cover_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_COVERS_EXT',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cover_code', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cover_no', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'cover_code', 'tgt': 'policy_coverage_schedule__coverage_reference'},
        {'src': 'cover_no', 'tgt': 'policy_coverage_schedule__coverage_sequence'},
        {'src': 'cover_prem', 'tgt': 'policy_coverage_schedule__premium_for_coverage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(policy_no),''))) || '|' || 'MATERNITY' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': "nullif(trim(policy_no),'')", 'tgt': 'policy_bk'},
        {'src': "'MATERNITY'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'meternitybenifitavil', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_pol_cov',
      'alias': 't2',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_POL_COV',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'prem_base_cover', 'tgt': 'policy_coverage_schedule__premium_for_coverage'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't3',
      'key_column': "pol_serial_no || '|' || 'INPATIENT_HOSPITALISATION' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'},
        {'src': "'INPATIENT_HOSPITALISATION'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'plc_inpat_hosp_treat_si', 'tgt': 'policy_coverage_schedule__sum_insured'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't4',
      'key_column': "pol_serial_no || '|' || 'AIR_AMBULANCE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'},
        {'src': "'AIR_AMBULANCE'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'plac_air_ambulance_cover', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'},
        {'src': 'plac_air_ambulance_si', 'tgt': 'policy_coverage_schedule__sum_insured'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't5',
      'key_column': "pol_serial_no || '|' || 'INPATIENT_HOSPITALISATION' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pol_serial_no', 'tgt': 'policy_bk'},
        {'src': "'INPATIENT_HOSPITALISATION'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'plc_inpat_hosp_treat_si', 'tgt': 'policy_coverage_schedule__sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't6',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'deductible_amt', 'tgt': 'policy_coverage_schedule__deductible_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't7',
      'key_column': "reg_no || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'children_limit', 'tgt': 'policy_coverage_schedule__sub_limit_amount'},
        {'src': 'si_coverages', 'tgt': 'policy_coverage_schedule__sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't8',
      'key_column': "reg_no || '|' || 'MATERNITY' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'MATERNITY'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'opt_yn', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'},
        {'src': 'maternity_benefit', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't9',
      'key_column': "reg_no || '|' || 'MATERNITY_NORMAL_DELIVERY' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'MATERNITY_NORMAL_DELIVERY'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'normal_delivery', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't10',
      'key_column': "reg_no || '|' || 'MATERNITY_CAESARIAN' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'MATERNITY_CAESARIAN'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'caesarian_delivery', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't11',
      'key_column': "reg_no || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'amount', 'tgt': 'policy_coverage_schedule__sub_limit_amount'},
        {'src': 'nine_mon_waiting_period', 'tgt': 'policy_coverage_schedule__waiting_period'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't12',
      'key_column': "reg_no || '|' || 'PRE_POST_NATAL' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'PRE_POST_NATAL'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'pre_post_natal_exp', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't13',
      'key_column': "reg_no || '|' || 'CHILD_COVER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'CHILD_COVER'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'child_coverage', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't14',
      'key_column': "reg_no || '|' || 'DAY_CARE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'DAY_CARE'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'day_care_procedures', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't15',
      'key_column': "reg_no || '|' || 'ICU' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'ICU'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'icu', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't16',
      'key_column': "reg_no || '|' || 'FAMILY_LIMIT' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'FAMILY_LIMIT'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'per_family_limit', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't17',
      'key_column': "reg_no || '|' || 'PRE_HOSPITALISATION' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'PRE_HOSPITALISATION'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'pre_hospitalization', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't18',
      'key_column': "reg_no || '|' || 'POST_HOSPITALISATION' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'POST_HOSPITALISATION'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'post_hospitalization', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't19',
      'key_column': "reg_no || '|' || 'CORPORATE_BUFFER_CI' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'CORPORATE_BUFFER_CI'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'corporate_buffer_ci', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't20',
      'key_column': "reg_no || '|' || 'FAMILY_LIMIT_CI' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'FAMILY_LIMIT_CI'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'per_family_limit_ci', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't21',
      'key_column': "reg_no || '|' || 'OPD' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'OPD'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'out_patient_treatment', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't22',
      'key_column': "reg_no || '|' || 'DENTAL' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'DENTAL'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'dental_treatment', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't23',
      'key_column': "reg_no || '|' || 'MATERNITY_COPAY' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'MATERNITY_COPAY'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'maternity_copayment_amt', 'tgt': 'policy_coverage_schedule__co_payment_amount'},
        {'src': 'maternity_copayment_per', 'tgt': 'policy_coverage_schedule__co_payment_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't24',
      'key_column': "reg_no || '|' || 'MATERNITY_EXCESS' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'MATERNITY_EXCESS'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'excess_maternity_benefitsamt', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't25',
      'key_column': "reg_no || '|' || 'DOMICILIARY' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'DOMICILIARY'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'domiciliary_hosp_covr', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't26',
      'key_column': "reg_no || '|' || 'CONGENITAL_INTERNAL' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'CONGENITAL_INTERNAL'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'congenital_intrnal_disease_cvr', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't27',
      'key_column': "reg_no || '|' || 'ANNUAL_HEALTH_CHECK' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'ANNUAL_HEALTH_CHECK'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'annual_health_check', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't28',
      'key_column': "reg_no || '|' || 'CORONA_PROTECTION' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'CORONA_PROTECTION'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'corona_protection', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hc_part_extn',
      'alias': 't29',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HC_PART_EXTN',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'waiting_period', 'tgt': 'policy_coverage_schedule__waiting_period'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hg_pol_dtls',
      'alias': 't30',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HG_POL_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'air_ambulance_yn', 'tgt': 'policy_coverage_schedule__coverage_opted_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't31',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'waiting_period', 'tgt': 'policy_coverage_schedule__waiting_period'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't32',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'waiting_period', 'tgt': 'policy_coverage_schedule__waiting_period'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_coverage_dtls',
      'alias': 't33',
      'key_column': "trim(to_varchar(nullif(trim(reg_no),''))) || '|' || 'MATERNITY' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_COVERAGE_DTLS',
      'columns': [
        {'src': "nullif(trim(reg_no),'')", 'tgt': 'policy_bk'},
        {'src': "'MATERNITY'", 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'maternity_benefit', 'tgt': 'policy_coverage_schedule__sub_limit_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_cover_dtls',
      'alias': 't34',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(cover_code, '~') || '|' || coalesce(cover_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_COVER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cover_code', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cover_no', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'cover_code', 'tgt': 'policy_coverage_schedule__coverage_reference'},
        {'src': 'cover_no', 'tgt': 'policy_coverage_schedule__coverage_sequence'},
        {'src': 'cover_prem', 'tgt': 'policy_coverage_schedule__premium_for_coverage'}
      ]
    },
    {
      'model': 'stg_health__ocp_policy_covers',
      'alias': 't35',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(cover_code, '~') || '|' || coalesce(cover_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_OCP_POLICY_COVERS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cover_code', 'tgt': 'policy_coverage_schedule__coverage_reference_ck'},
        {'src': 'cover_no', 'tgt': 'policy_coverage_schedule__coverage_sequence_ck'},
        {'src': 'cover_code', 'tgt': 'policy_coverage_schedule__coverage_reference'},
        {'src': 'cover_no', 'tgt': 'policy_coverage_schedule__coverage_sequence'},
        {'src': 'ftpremium_sys_whole_cover', 'tgt': 'policy_coverage_schedule__premium_for_coverage'},
        {'src': 'sum_insured_whole_cover', 'tgt': 'policy_coverage_schedule__sum_insured'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'policy_coverage_schedule__coverage_reference_ck',
    'policy_coverage_schedule__coverage_sequence_ck',
    'policy_coverage_schedule__coverage_reference',
    'policy_coverage_schedule__coverage_sequence',
    'policy_coverage_schedule__premium_for_coverage',
    'policy_coverage_schedule__coverage_opted_indicator',
    'policy_coverage_schedule__sum_insured',
    'policy_coverage_schedule__deductible_amount',
    'policy_coverage_schedule__sub_limit_amount',
    'policy_coverage_schedule__waiting_period',
    'policy_coverage_schedule__co_payment_amount',
    'policy_coverage_schedule__co_payment_percentage'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35'],
    'policy_coverage_schedule__coverage_reference_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35'],
    'policy_coverage_schedule__coverage_sequence_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29', 't30', 't31', 't32', 't33', 't34', 't35'],
    'policy_coverage_schedule__coverage_reference': ['t0', 't34', 't35'],
    'policy_coverage_schedule__coverage_sequence': ['t0', 't34', 't35'],
    'policy_coverage_schedule__premium_for_coverage': ['t0', 't2', 't34', 't35'],
    'policy_coverage_schedule__coverage_opted_indicator': ['t1', 't4', 't8', 't21', 't22', 't25', 't26', 't27', 't28', 't30'],
    'policy_coverage_schedule__sum_insured': ['t3', 't4', 't5', 't7', 't35'],
    'policy_coverage_schedule__deductible_amount': ['t6'],
    'policy_coverage_schedule__sub_limit_amount': ['t7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't24', 't33'],
    'policy_coverage_schedule__waiting_period': ['t11', 't29', 't31', 't32'],
    'policy_coverage_schedule__co_payment_amount': ['t23'],
    'policy_coverage_schedule__co_payment_percentage': ['t23']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_coverage_schedule_pk',
    target_sat='sat_policy_coverage_schedule'
) }}
