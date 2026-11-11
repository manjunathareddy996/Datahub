{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_CERTIFICATE only. Original precedence comments are kept below (from stitch_v20_party).
-- CENTRAL VIEW v20_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_DT_MEM (opus_health_legacy_v4)
--   BA_HCP_DT_MEM_COV (opus_health_legacy_v4)
--   BA_HCP_DT_POL_COV (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_CARD_DTLS (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GENERIC_LOADER_LOG_TABLE (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_ILLNESS_BASES_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_PARTY_CLAIM_HISTORY
--   SAT_POLICY_CERTIFICATE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_ROLE
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__ba_hcp_dt_mem') }}
-- depends_on: {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
-- depends_on: {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
-- depends_on: {{ ref('stg_health__bgil_gmc_final_instl_data') }}
-- depends_on: {{ ref('stg_health__bjaz_card_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_generic_loader_log_table') }}
-- depends_on: {{ ref('stg_health__bjaz_gp_hospital_cash') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hc_part_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
-- depends_on: {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_inward_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_orphan_reg') }}
-- depends_on: {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_illness_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(policy_ref),''))) || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': "nullif(trim(policy_ref),'')", 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'doj', 'tgt': 'policy_certificate__enrolment_date'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_mem',
      'alias': 't1',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_MEM',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'mem_status', 'tgt': 'policy_certificate__member_status'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_mem_cov',
      'alias': 't2',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_MEM_COV',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'mem_add_flag', 'tgt': 'policy_certificate__joining_type'},
        {'src': 'mem_status', 'tgt': 'policy_certificate__member_status'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_dt_pol_cov',
      'alias': 't3',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_POL_COV',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'mem_add_flag', 'tgt': 'policy_certificate__joining_type'},
        {'src': 'mem_status', 'tgt': 'policy_certificate__member_status'}
      ]
    },
    {
      'model': 'stg_health__bgil_gmc_final_instl_data',
      'alias': 't4',
      'key_column': "policy_no || '|' || coalesce(emp_code, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BGIL_GMC_FINAL_INSTL_DATA',
      'columns': [
        {'src': 'policy_no', 'tgt': 'policy_bk'},
        {'src': 'emp_code', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'annual_premium', 'tgt': 'policy_certificate__member_premium'},
        {'src': 'sum_inusred', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_card_dtls',
      'alias': 't5',
      'key_column': "policy_ref || '|' || coalesce(emp_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CARD_DTLS',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': 'emp_no', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't6',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'effetive_date', 'tgt': 'policy_certificate__coverage_start_date'},
        {'src': 'premium', 'tgt': 'policy_certificate__member_premium'},
        {'src': 'status', 'tgt': 'policy_certificate__member_status'}
      ]
    },
    {
      'model': 'stg_health__bjaz_generic_loader_log_table',
      'alias': 't7',
      'key_column': "pmasterpolicynumber || '|' || coalesce(empno, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GENERIC_LOADER_LOG_TABLE',
      'columns': [
        {'src': 'pmasterpolicynumber', 'tgt': 'policy_bk'},
        {'src': 'empno', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gp_hospital_cash',
      'alias': 't8',
      'key_column': "master_policy_no || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GP_HOSPITAL_CASH',
      'columns': [
        {'src': 'master_policy_no', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_id_mem_detls',
      'alias': 't9',
      'key_column': "contract_id || '|' || coalesce(member_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_ID_MEM_DETLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'member_no', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'join_date', 'tgt': 'policy_certificate__enrolment_date'},
        {'src': 'premium', 'tgt': 'policy_certificate__member_premium'},
        {'src': 'status', 'tgt': 'policy_certificate__member_status'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't10',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'to_date', 'tgt': 'policy_certificate__coverage_end_date'},
        {'src': 'from_date', 'tgt': 'policy_certificate__coverage_start_date'},
        {'src': 'premium', 'tgt': 'policy_certificate__member_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hc_part_extn',
      'alias': 't11',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HC_PART_EXTN',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'premium', 'tgt': 'policy_certificate__member_premium'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hdfc_sec_fhpp',
      'alias': 't12',
      'key_column': "reference_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HDFC_SEC_FHPP',
      'columns': [
        {'src': 'reference_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hlt_ensure_mem_dtls',
      'alias': 't13',
      'key_column': "contract_id || '|' || coalesce(member_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HLT_ENSURE_MEM_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'member_no', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_coinsu_clm_dtls',
      'alias': 't14',
      'key_column': "policy_ref || '|' || coalesce(emp_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_COINSU_CLM_DTLS',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': 'emp_no', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't15',
      'key_column': "policy || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'policy', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'premium', 'tgt': 'policy_certificate__member_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_inward_dtls',
      'alias': 't16',
      'key_column': "policy_ref || '|' || coalesce(certificate_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_INWARD_DTLS',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': 'certificate_no', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'certificate_no', 'tgt': 'policy_certificate__certificate_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_dtls',
      'alias': 't17',
      'key_column': "contract_id || '|' || coalesce(member_id, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'member_id', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'premium', 'tgt': 'policy_certificate__member_premium'},
        {'src': 'member_status', 'tgt': 'policy_certificate__member_status'},
        {'src': 'suminsured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_orphan_reg',
      'alias': 't18',
      'key_column': "policy_number || '|' || coalesce(idcardno, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_ORPHAN_REG',
      'columns': [
        {'src': 'policy_number', 'tgt': 'policy_bk'},
        {'src': 'idcardno', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'suminsured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ihg_mem_dtls_extn',
      'alias': 't19',
      'key_column': "contract_id || '|' || coalesce(member_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_IHG_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'member_no', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'effetive_date', 'tgt': 'policy_certificate__coverage_start_date'},
        {'src': 'premium', 'tgt': 'policy_certificate__member_premium'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_illness_bases_extn',
      'alias': 't20',
      'key_column': "contract_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ILLNESS_BASES_EXTN',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_sh_mem_dtls_extn',
      'alias': 't21',
      'key_column': "contract_id || '|' || coalesce(member_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_SH_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': 'member_no', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'effetive_date', 'tgt': 'policy_certificate__coverage_start_date'},
        {'src': 'premium', 'tgt': 'policy_certificate__member_premium'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't22',
      'key_column': "policy_no || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'policy_no', 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_certificate__certificate_number_ck'},
        {'src': 'sum_insured', 'tgt': 'policy_certificate__member_sum_insured'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'policy_certificate__certificate_number_ck',
    'policy_certificate__enrolment_date',
    'policy_certificate__member_status',
    'policy_certificate__joining_type',
    'policy_certificate__member_premium',
    'policy_certificate__member_sum_insured',
    'policy_certificate__coverage_start_date',
    'policy_certificate__coverage_end_date',
    'policy_certificate__certificate_number'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22'],
    'policy_certificate__certificate_number_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22'],
    'policy_certificate__enrolment_date': ['t0', 't9'],
    'policy_certificate__member_status': ['t1', 't2', 't3', 't6', 't9', 't17'],
    'policy_certificate__joining_type': ['t2', 't3'],
    'policy_certificate__member_premium': ['t4', 't6', 't9', 't10', 't11', 't15', 't17', 't19', 't21'],
    'policy_certificate__member_sum_insured': ['t4', 't5', 't7', 't8', 't9', 't11', 't12', 't13', 't14', 't17', 't18', 't19', 't20', 't21', 't22'],
    'policy_certificate__coverage_start_date': ['t6', 't10', 't19', 't21'],
    'policy_certificate__coverage_end_date': ['t10'],
    'policy_certificate__certificate_number': ['t16']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_certificate_pk',
    target_sat='sat_policy_certificate'
) }}
